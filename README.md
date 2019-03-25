# dlangsharedlib
dlang shared library testing repository

This repository is just for testing how to call Dlang library from D or C the "right" way.
Main point is to test the interaction with foreign threads and to have some reference how this can be achieved.

See `Makefile` for targets, but in short:

* `make staticd` - tests static linked library called from D main
* `make dynamicd` - tests shared library dynamically loaded from D main
* `make staticc` - tests static linked library called from C main
* `make dynamicc` - tests shared library dynamically loaded from C main

**NOTE**: Currently these are buggy and unreliable. See `workaround` folder for possible workaround, which seems to at least work, but is ugly..

Some resources I've put this together from:
* https://github.com/dlang/druntime/commit/f60eb358ccbc14a1a5fc1774eab505ed0132e999
* https://dlang.org/articles/dll-linux.html
* https://forum.dlang.org/post/ounui4$171a$1@digitalmars.com
* https://forum.dlang.org/post/ontmtemtmwlmalejbuyb@forum.dlang.org
* https://forum.dlang.org/post/nibvodewzbzwmmvdortd@forum.dlang.org
