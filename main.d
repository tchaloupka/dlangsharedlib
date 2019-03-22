module main;

import core.stdc.stdio;
import core.stdc.stdlib;
import core.sys.posix.pthread;

alias FN = void* function(void*);
FN ep1;
FN ep2;

version (DYNAMIC) import core.sys.posix.dlfcn;
else
{
	extern(C)
	{
		void* entry_point1(void*);
		void* entry_point2(void*);
	}
}

extern(C) void* threadFun(void* arg)
{
	FN fn = cast(FN)arg;
	foreach(_; 0..5) fn(null);
	return null;
}

shared static this() { printf("main shared static this\n"); }
shared static ~this() { printf("main shared static ~this\n"); }

void main()
{
	printf("+main()\n");

	// allocate some garbage
	auto x = new int[1000];

	version (DYNAMIC)
	{
		void* lh = dlopen("libworker.so", RTLD_LAZY);
		if (!lh)
		{
			fprintf(stderr, "dlopen error: %s\n", dlerror());
			exit(1);
		}
		printf("libworker.so is loaded\n");

		scope (exit)
		{
			printf("unloading libworker.so\n");
			dlclose(lh);
		}

		ep1 = cast(FN)dlsym(lh, "entry_point1");
		char* error = dlerror();
		if (error)
		{
			fprintf(stderr, "dlsym error: %s\n", error);
			exit(1);
		}
		printf("entry_point1() function is found\n");

		ep2 = cast(FN)dlsym(lh, "entry_point2");
		error = dlerror();
		if (error)
		{
			fprintf(stderr, "dlsym error: %s\n", error);
			exit(1);
		}
		printf("entry_point2() function is found\n");
	}
	else
	{
		ep1 = cast(FN)&entry_point1;
		ep2 = cast(FN)&entry_point2;
	}

	{
		pthread_t thread;
		auto status = pthread_create(&thread, null, &threadFun, cast(void*)ep1);
		assert(status == 0);
		pthread_join(thread, null);
	}

	{
		pthread_t thread;
		auto status = pthread_create(&thread, null, &threadFun, cast(void*)ep2);
		assert(status == 0);
		pthread_join(thread, null);
	}

	printf("-main()\n");
}
