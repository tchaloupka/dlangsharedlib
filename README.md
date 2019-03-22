# dlangsharedlib
dlang shared library testing repository

This repository is just for testing how to call Dlang library from D or C the "right" way.
Main point is to test the interaction with foreign threads and to have some reference how this can be achieved.

See `Makefile` for targets, but in short:

* `make staticd` - tests static linked library called from D main
* `make dynamicd` - tests shared library dynamically loaded from D main
* `make staticc` - tests static linked library called from C main
* `make dynamicc` - tests shared library dynamically loaded from C main
