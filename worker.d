module worker;

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

	// try collecting - GC must ignore this call because this thread
	// is not registered in runtime
	GC.collect();
	return null;
}

extern(C)
void* entry_point2(void*)
{
	printf("+entry_point2\n");
	scope (exit) printf("-entry_point2\n");

	// This thread gets registered in druntime, does some work and gets
	// unregistered to be cleaned up manually
	thread_attachThis();
	rt_moduleTlsCtor();

	// simulate GC work
	auto x = new int[100];

	GC.collect();

	rt_moduleTlsDtor();
	thread_detachThis();
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
