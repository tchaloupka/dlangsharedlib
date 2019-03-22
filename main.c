#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
#include <assert.h>
#include <pthread.h>

typedef void* (*FN)(void*);

#ifdef DYNAMIC
#else
extern void* entry_point1(void*);
extern void* entry_point2(void*);
extern int rt_init(void);
extern int rt_term(void);
#endif

void* threadFun(void* arg)
{
	FN fn = arg;
	for (int i=0; i<5; i++) fn(NULL);
	return NULL;
}

int main(int argc, char* argv[]) {

	printf("+main()\n");

	#ifdef DYNAMIC
		void *w = dlopen("libworker.so", RTLD_LAZY);
		assert(w != NULL);
		printf("libworker.so is loaded\n");

		int (*rt_init)(void) = dlsym(w, "rt_init");
		int (*rt_term)(void) = dlsym(w, "rt_term");
		void* (*ep1)(void*) = dlsym(w, "entry_point1");
		void* (*ep2)(void*) = dlsym(w, "entry_point2");
	#else
		FN ep1 = &entry_point1;
		FN ep2 = &entry_point2;
	#endif

	// init druntime
	assert(rt_init() == 1);

	{
		pthread_t thread;
		int status = pthread_create(&thread, NULL, &threadFun, ep1);
		assert(status == 0);
		pthread_join(thread, NULL);
	}

	{
		pthread_t thread;
		int status = pthread_create(&thread, NULL, &threadFun, ep2);
		assert(status == 0);
		pthread_join(thread, NULL);
	}

	assert(rt_term() == 1);

	#ifdef DYNAMIC
	printf("unloading libworker.so\n");
	dlclose(w);
	#endif

	printf("-main()\n");
}
