# Boost Docker Development Environment (BDDE)

Provides a docker container for linux development of Boost that is
easy to use.

This container provides all of the required and optional dependencies
necessary to build boost completely, including documentation.

## Future Plans

* Cross-compilation with gcc on the linux container.  The goal is to
  work towards providing more continuous integration coverage options
  allowing systems such as Travis CI to simulate a sparc or vax build.

* Support for a Visual Studio 2017 Build Tools environment is planned,
  enabling Windows containerized builds with all of the required and
  optional dependencies prepared.

## Linux Development

Linux development is possible on any platform with a linux-capable
docker container environment.  The linux build container includes:

1. All of the required and optional dependencies for boost repositories.
2. All of the documentation build dependencies.
3. A known good version of clang, currently 6.0.
   clang does not support side-by-side installation.
4. Many known good versions of gcc, currently:
   4.8.2, 5.x, 6.x, 7.3.0, 8.2.0.
5. Both libstdc++ and libc++ are provided.
6. Components for static code analysis (cppcheck, ubsan, valgrind).

BDDE will either use `BOOST_ROOT`, or determine it automatically based
on your current working directory inside a boost source tree.

BDDE creates a docker container with the boost sources mounted into `/boost`,
using a regular user named `boost` with a sudo password of `boost`.  The
use of a regular user ensures there are no root dependencies for building
boost.

### Usage

Pull or build the linux docker image:

    user@ubuntu:~/bdde$ make image

Add the `bin/linux` path to your environment for example:

    user@ubuntu:~/bdde$ export PATH=$(pwd)/bin/linux:$PATH

If you do not have the boost source tree locally, obtain it:

    user@ubuntu:~$ bdde-clone

The entire boost source collection is downloaded into `BOOST_ROOT`, and
the `develop` branch is checked out.  Each sub-repository in `libs/` and
'tools/' will be set to a detached head, with the git commit synchronized
with the top level.

Now navigate to a location within your boost source tree and use `bdde`
to jump into a docker container at that location where you can start a build.

    user@ubuntu:~$ cd ~/boost
    user@ubuntu:~/boost$ bdde

Now you are in the docker container.  Anything you do inside the `/boost`
directory will be preserved.  Anything you do outside of the `/boost`
directory is destroyed when you exit the docker container shell prompt.

Boost provides its own build system, Boost.Build, previously known as Boost
Jam.  You need to build it one time using the bootstrap shell script.

    boost@47ee8d52a242:/boost$ ./bootstrap.sh

#### Building

BDDE makes it easy to jump into and out of the docker build container.  When
you run `bdde` from a subdirectory in your `BOOST_ROOT`, the shell within
the container is set to the same working directory.  For example:

    user@ubuntu:~/boost/libs/uuid$ bdde
    boost@47ee8d52a242:/boost/libs/uuid$
    
The top level boost directory is added to your path inside the container
allowing you to run b2 without using relative paths back to `BOOST_ROOT`.
To build something inside the docker container shell, follow this example:

    boost@47ee8d52a242:/boost/libs/uuid$ b2 -q -j3 variant=debug cxxstd=11

More information on building boost with Boost.Build can be found at:

https://www.boost.org/doc/libs/1_68_0/more/getting_started/unix-variants.html

#### UBSAN

BDDE provides a convenience to make it easy to run anything under UBSAN, for
example an entire project:

    boost@47ee8d52a242:/boost/libs/uuid$ ubsan -q -j3 cxxstd=03

or just one test:

    boost@47ee8d52a242:/boost/libs/uuid$ cd test
    boost@47ee8d52a242:/boost/libs/uuid/test$ ubsan -q -j3 cxxstd=11 test_uuid

