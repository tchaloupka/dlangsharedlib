module worker;

import core.memory;
import core.stdc.stdio;
import core.runtime;
import core.time;
import core.thread;
import core.sys.posix.pthread;

__gshared int res; // to write result from worker
__gshared int req; // request parameter for worker to work with
__gshared bool cancel; // to cancel worker

__gshared pthread_mutex_t mutex; // to synchronize worker/caller on work
__gshared pthread_mutex_t req_mutex; // to synchronize multiple callers
__gshared pthread_cond_t condition_c; // condition to wake up caller
__gshared pthread_cond_t condition_w; // condition to wake up worker

extern(C) @nogc int pthread_getname_np(pthread_t thread, char *name, size_t len); // not defined in core.sys.posix.pthread
__gshared int[] data;
void worker() // worker run in D's thread
{
	printf("Starting worker thread\n");
	while (true)
	{
		assert(pthread_mutex_lock(&mutex) == 0);

		if (req == -1) pthread_cond_wait(&condition_w, &mutex); // wait for new work

		if (cancel) // terminate thread
		{
			printf("Terminating worker thread\n");
			pthread_mutex_unlock(&mutex);
			break;
		}

		printf("Working on %i\n", req);

		// use some garbage
		foreach(_; 0..100) data = new int[1000];
		GC.collect();

		res = req + 42; // set result
		printf("Working on %i finished\n", req);
		req = -1; // clean request

		pthread_cond_signal(&condition_c); // notify caller to wake up
		assert(pthread_mutex_unlock(&mutex) == 0);
	}
}

extern(C) int lib_init()
{
	printf("+lib_init()\n");
	scope (exit) printf("-lib_init()\n");
	assert(Runtime.initialize());

	// init worker condition and mutex
	// init mutex and condition variables
	pthread_mutex_init(&mutex, null);
	pthread_mutex_init(&req_mutex, null);
	pthread_cond_init(&condition_c, null);
	pthread_cond_init(&condition_w, null);

	// init worker thread
	new Thread(&worker).start();

	return true;
}

extern(C) int lib_term()
{
	printf("+lib_term()\n");
	scope (exit) printf("-lib_term()\n");

	// shutdown worker thread
	pthread_mutex_lock(&mutex);
	cancel = true;
	pthread_cond_signal(&condition_w); // notify worker to wake up
	pthread_mutex_unlock(&mutex);

	// terminate runtime
	assert(Runtime.terminate());

	// cleanup mutex and conditions
	pthread_mutex_destroy(&mutex);
	pthread_mutex_destroy(&req_mutex);
	pthread_cond_destroy(&condition_c);
	pthread_cond_destroy(&condition_w);

	return true;
}

extern(C) int do_work(int val) @nogc // we don't want to do anything with GC here
{
	int r;
	char[16] tname;
	pthread_getname_np(pthread_self(), &tname[0], tname.length);

	assert(pthread_mutex_lock(&req_mutex) == 0);
	assert(pthread_mutex_lock(&mutex) == 0);
	{
		printf("+ %s: do_work(%i)\n", &tname[0], val);
		scope (exit) printf("- %s: do_work(%i)\n", &tname[0], val);

		req = val; // set work
		pthread_cond_signal(&condition_w); // notify worker to wake up
		printf("  %s: wait for result\n", &tname[0]);
		pthread_cond_wait(&condition_c, &mutex); // wait for worker to be finished
		r = res;
	}
	assert(pthread_mutex_unlock(&mutex) == 0);
	assert(pthread_mutex_unlock(&req_mutex) == 0);

	return r;
}

shared static this()
{
	printf("worker shared static this\n");
}

shared static ~this()
{
	printf("worker shared static ~this\n");
}
