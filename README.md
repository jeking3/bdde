# Boost Docker Development Environment (BDDE)

Provides a docker container for linux development of Boost containing:

1. All of the required and optional dependencies for boost repositories.
2. All of the documentation build dependencies.
3. A known good version of clang, currently 6.0.
4. A known good version of gcc, currently 8.2.
5. TODO: Cross-compilation tools for gcc.
6. Components for static code analysis (cppcheck, ubsan, valgrind).
7. Both libstdc++ and libc++ are provided.
8. Standardized toolset definitions (in user-config.jam).

## Building the Docker Container

### Prerequisites

You need a docker container runtime environment capable of running a linux
docker container.

You provide boost by setting the environment variable `BOOST_ROOT`, or
if you do not have boost you can run `make source` to put it into the
subdirectory `boost` which this repository then ignores.

### Linux

Build the docker container:

    make image

Build Boost.Build (bjam, b2):

    make bootstrap

Open a shell:

    make shell

To build something inside the docker container shell, follow this example:

    ./b2 -a -q -j3 toolset=clang cxxflags=-stdlib=libc++ cxxstd=17 libs/assign

Run `make clean` occasionally to get rid of crufty container remnants.
