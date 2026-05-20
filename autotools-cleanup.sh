#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


[ -f Makefile ] && make clean
rm -rf autom4te.cache
rm -f {config.h.in,config.h}
rm -f {Makefile.in,Makefile}
rm -f config.status
rm -f configure
rm -f stamp*
rm -f aclocal.m4
rm -f compile
rm -f missing
rm -f install-sh
