PHONY: all lib clean

clean:
	rm -f *.so
	rm -f *.o
	rm -f main

lib: clean
	dmd -c worker.d -fPIC -g -debug
	dmd -oflibworker.so worker.o -shared -defaultlib=libphobos2.so

all: lib
	gcc -o main main.c -D_GNU_SOURCE -ldl -lpthread
	./main
