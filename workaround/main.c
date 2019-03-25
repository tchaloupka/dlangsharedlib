#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
#include <assert.h>
#include <pthread.h>

typedef int (*FN)(int);
#define NUM_THREADS 2

FN workerFn;
pthread_t threads[NUM_THREADS];
char* thread_names[NUM_THREADS];

void* threadFun(void* arg)
{
	long i = (long)arg;
	thread_names[i] = malloc(3);
	thread_names[i][0] = 'T';
	thread_names[i][1] = '0' + i;
	thread_names[i][2] = '\0';
	pthread_setname_np(threads[i], thread_names[i]);

	printf("+ %s: pthread start\n", thread_names[i]);
	for (int i=0; i < 10; i++)
	{
		int res = workerFn(i);
		assert(res == i + 42);
	}
	printf("- %s: pthread end\n", thread_names[i]);
}

int main(int argc, char* argv[]) {

	printf("+main()\n");

	void *w = dlopen("libworker.so", RTLD_LAZY);
	assert(w != NULL);
	printf("libworker.so is loaded\n");
	int (*lib_init)(void) = dlsym(w, "lib_init");
	int (*lib_term)(void) = dlsym(w, "lib_term");
	int (*do_work)(int) = dlsym(w, "do_work");

	workerFn = do_work;

	assert(lib_init());

	// start threads
	for(long i=0; i < NUM_THREADS; i++) {
		int status = pthread_create(&threads[i], NULL, &threadFun, (void*)i);
		assert(status == 0);
	}

	// join threads
	for(int i=0; i < NUM_THREADS; i++) {
		pthread_join(threads[i], NULL);
		free(thread_names[i]);
	}

	// cleanup
	assert(lib_term());

	printf("-main()\n");
}
