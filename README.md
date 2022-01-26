# Boost Docker Development Environment (BDDE)

Provides a docker container for linux development of Boost that is
easy to use and accelerates development and debugging of C++
products.

The x86_64 container provides all of the required and optional dependencies
necessary to build boost completely, including documentation.  The other
containers are missing some (or many) things and are not marked as "complete"
below.

Supported combinations of architecture and OS:

| OS | Arch | Endian | Complete? | Notes |
| -- | ---- | ------ | --------- | ----- |
| deb | x86_64 | little | Yes | Ubuntu Bionic 18.04 LTS |
| deb | arm64 | little | No | Ubuntu Bionic 18.04 LTS |
| red | ppc64 | big | No | Fedora 25 |

To use any image that is not native to your host architecture and endianness,
you must satisfy the prerequisites of running a multiarch docker container.

1. Install the qemu-user-static package.
2. Run `docker run --rm --privileged multiarch/qemu-user-static:register --reset`

See each Dockerfile for specific prerequisites.  Some containers may have special
requirements.

## Status

| Branch          | Docker Hub | Travis |
| :-------------: | ---------- | ------ |
| [`master`](https://github.com/jeking3/bdde) | [![Build Status](https://img.shields.io/docker/build/jeking3/bdde.svg?style=plastic)](https://cloud.docker.com/repository/docker/jeking3/bdde) | [![Build Status](https://travis-ci.org/jeking3/bdde.svg?branch=master)](https://travis-ci.org/jeking3/bdde/branches) |

## Future Plans

* Support for a Visual Studio 201x Build Tools environment is planned,
  enabling Windows containerized builds with all of the required and
  optional dependencies prepared.

## Linux Development

Linux development is possible on any platform with a linux-capable
docker container environment.  The x86_64 container includes:

1. All of the required and optional dependencies for boost repositories.
2. All of the documentation build dependencies.
3. A known good version of clang, currently 6.0.
   (clang does not support side-by-side installation)
4. Many version of gcc from 5.x through 9.x.
5. Both libstdc++ and libc++ are provided.
6. Components for static code analysis (ubsan, valgrind).

BDDE will either use `BOOST_ROOT`, or determine it automatically based
on your current working directory inside a boost source tree.

BDDE creates a docker container with the boost sources mounted into `/boost`,
using a regular user named `boost` with a sudo password of `boost`.  The
use of a regular user ensures there are no root dependencies for building
boost.

### Usage

Add the `bin/linux` path to your environment (or do this in your .profile to make it permanent):

    user@ubuntu:~/bdde$ export PATH=$(pwd)/bin/linux:$PATH

Pull or build the linux docker image for the architecture you want, for exmaple:

    user@ubuntu:~/bdde$ make deb-x86_64

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
Jam.  You need to build it one time using the bootstrap shell script.  This
will generate the b2 executable:

    user@ubuntu:~/boost$ bdde bootstrap.sh

The previous example also demonstrates how to run a one-off command inside
the docker container from your current directory.

#### Shell

BDDE makes it easy to jump into and out of the docker build container.  When
you run `bdde` from a subdirectory in your `BOOST_ROOT`, the shell within
the container is set to the same working directory.  For example:

    user@ubuntu:~/boost/libs/uuid$ bdde
    boost@47ee8d52a242:/boost/libs/uuid$ b2 -q
    
The top level boost directory is added to your path inside the container
allowing you to run b2 without using relative paths back to `BOOST_ROOT`.

#### Invoking

You can invoke a command inside the container and then return to your shell
by adding arguments to the end of the bdde command:

    user@ubuntu:~/boost/libs/uuid$ bdde b2 -q -j3 variant=debug cxxstd=11
    ... build output ...
    user@ubuntu:~/boost/libs/uuid$ 

More information on building boost with Boost.Build can be found at:

https://www.boost.org/doc/libs/1_70_0/more/getting_started/unix-variants.html

#### UBSAN

BDDE provides a convenience to make it easy to run anything under UBSAN.
This is a modification of the b2 command with options added to invoke UBSAN
and to print a stacktrace on error:

    user@ubuntu:~/boost/libs/uuid/test$ bdde ubsan cxxstd=03 test_sha1

## Environment

The following environment variables control the behavior of bdde:

### `BDDE_ARCH`

Set the architecture to use in the container.  Choices are (* default):

- arm64
- ppc64
- x86_64 (*)

### `BDDE_DOCK`

Additional options to pass to docker.

### `BDDE_OS`

Set the operating system for the docker container.  Choices are (* default):

- deb (*) - Debian based
- red - RedHat based

### `BDDE_REPO`

Set the Docker Hub repository name to pull from or name the images for.
The default is `jeking3/bdde`.

### `BDDE_SHELL`

The shell to use.  The default is `/bin/bash`.

### `BOOST_ROOT`

This points to the boostorg/boost superproject cloned locally.  If this
is not set, it is determined automatically when entering the container.

## Example

This is an example of running a big-endian ppc64 Fedora based image
on a little-endian x86_64 host running Ubuntu Bionic:

### Installing Prerequisites

    root@ubuntu:~# apt-get install -y binfmt-support
    root@ubuntu:~# wget http://lug.mtu.edu/ubuntu/pool/universe/q/qemu/qemu-user-static_3.1+dfsg-2ubuntu3.1_amd64.deb
    root@ubuntu:~# dpkg -i qemu-user-static_3.1+dfsg-2ubuntu3.1_amd64.deb

    user@ubuntu:~$ docker run --rm --privileged multiarch/qemu-user-static:register --reset

### Running a unit test in Boost.Predef

    user@ubuntu:~/boost$ export BDDE_OS=red
    user@ubuntu:~/boost$ export BDDE_ARCH=ppc64
    user@ubuntu:~/boost$ bdde bootstrap.sh
    + docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -v /home/jking/boost:/boost:rw -v /home/jking/bdde:/bdde:ro -v /home/jking/.vimrc:/home/boost/.vimrc:ro --workdir /boost -it jeking3/bdde:red-ppc64 /bin/bash -c 'bootstrap.sh'
    Building Boost.Build engine with toolset gcc... tools/build/src/engine/b2
    Unicode/ICU support for Boost.Regex?... not found.
    Backing up existing Boost.Build configuration in project-config.jam.31
    Generating Boost.Build configuration in project-config.jam for gcc...
    
    Bootstrapping is done. To build, run:
    
        ./b2
    
    To generate header files, run:
    
        ./b2 headers
    
    To adjust configuration, edit 'project-config.jam'.
    Further information:
    
       - Command line help:
         ./b2 --help
    
       - Getting started guide:
         http://www.boost.org/more/getting_started/unix-variants.html
    
       - Boost.Build documentation:
         http://www.boost.org/build/
    
    user@ubuntu:~/boost$ cd libs/predef/test
    user@ubuntu:~/boost/libs/predef/test$ bdde
    boost@554276e34481:/boost/libs/predef/test$ b2 -a info_as_cpp
    Performing configuration checks
    
        - default address-model    : 64-bit
        - default architecture     : x86
        - symlinks supported       : yes
    ...patience...
    ...found 338 targets...
    ...updating 5 targets...
    link.mklink ../../../boost/predef.h
    gcc.compile.c++ ../../../bin.v2/libs/predef/test/info_as_cpp.test/gcc-7/debug/threading-multi/visibility-hidden/info_as_cpp.o
    gcc.link ../../../bin.v2/libs/predef/test/info_as_cpp.test/gcc-7/debug/threading-multi/visibility-hidden/info_as_cpp
    testing.capture-output ../../../bin.v2/libs/predef/test/info_as_cpp.test/gcc-7/debug/threading-multi/visibility-hidden/info_as_cpp.run
    **passed** ../../../bin.v2/libs/predef/test/info_as_cpp.test/gcc-7/debug/threading-multi/visibility-hidden/info_as_cpp.test
    ...updated 5 targets...
    boost@554276e34481:/boost/libs/predef/test$ ../../../bin.v2/libs/predef/test/info_as_cpp.test/gcc-7/debug/threading-multi/visibility-hidden/info_as_cpp | head -10
    ** Detected **
    BOOST_ARCH_PPC = 1 (0,0,1) | PowerPC
    BOOST_COMP_GNUC = 60400001 (6,4,1) | Gnu GCC C/C++
    BOOST_ENDIAN_BIG_BYTE = 1 (0,0,1) | Byte-Swapped Big-Endian
    BOOST_LANG_STDC = 1 (0,0,1) | Standard C
    BOOST_LANG_STDCPP = 440200001 (44,2,1) | Standard C++
    BOOST_LIB_C_GNU = 22400000 (2,24,0) | GNU
    BOOST_LIB_STD_GNU = 470700027 (47,7,27) | GNU
    BOOST_OS_LINUX = 1 (0,0,1) | Linux
    BOOST_OS_UNIX = 1 (0,0,1) | Unix Environment
