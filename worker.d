module worker;

import utils;

import core.memory;
import core.stdc.stdio;
import core.thread;

extern (C) void rt_moduleTlsCtor();
extern (C) void rt_moduleTlsDtor();

extern(C)
void* entry_point1(void*)
{
	printf("+entry_point1\n");
	scope (exit) printf("-entry_point1\n");

	// call method from utils
	test();

	// try collecting - GC must ignore this call because this thread
	// is not registered in runtime
	GC.collect();
	return null;
}

__gshared int[] data;

extern(C)
void* entry_point2(void*)
{
	printf("+entry_point2\n");
	scope (exit) printf("-entry_point2\n");

	// This thread gets registered in druntime, does some work and gets
	// unregistered to be cleaned up manually
	if (!thread_isMainThread()) // thread_attachThis will hang otherwise
	{
		printf("+entry_point2 - thread_attachThis()\n");
		thread_attachThis();
		rt_moduleTlsCtor();
	}

	// simulate some GC work
	foreach(_; 0..10)
	{
		data = new int[100];
	}
	GC.collect();

	if (!thread_isMainThread())
	{
		printf("+entry_point2 - thread_detachThis()\n");
		rt_moduleTlsDtor();
		thread_detachThis();
	}
	return null;
}

shared static this()
{
	printf("worker shared static this\n");
}

shared static ~this()
{
	printf("worker shared static ~this\n");
}
