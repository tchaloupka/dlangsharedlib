module utils;

import core.stdc.stdio;

shared static this()
{
	printf("utils shared static this\n");
}

shared static ~this()
{
	printf("utils shared static ~this\n");
}

void test()
{
	printf("utils test\n");
}
