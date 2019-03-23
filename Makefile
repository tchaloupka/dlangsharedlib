PHONY: all clean staticlib dynamiclib staticc staticd dynamicc dynamicd

clean:
	rm -f *.so
	rm -f *.a
	rm -f *.o
	rm -f main

staticlib: clean
	dmd -c worker.d -g -debug

dynamiclib: clean
	dmd -c worker.d -fPIC -g -debug
	dmd -oflibworker.so worker.o -shared -defaultlib=libphobos2.so

staticd: staticlib
	dmd main.d worker.o -g -debug
	./main

dynamicd: dynamiclib
	dmd -c main.d -version=DYNAMIC
	dmd main.o -L-ldl -defaultlib=libphobos2.so
	./main

staticc: staticlib
	gcc -o main -g main.c worker.o -lphobos2 -ldl -lpthread
	./main

dynamicc: dynamiclib
	gcc -o main main.c -D DYNAMIC -ldl -lpthread
	./main

all: staticd dynamicd staticc dynamicc
