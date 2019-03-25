# workaround

This is a workaround for not working GC with foreign threads.

It uses D's `Thread` to execute the work and `@nogc` method to invoke the work.

It uses global variables, mutexes and conditions to synchronize between one worker thread and multiple foreign callers.
