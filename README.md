# Boost Docker Development Environment (BDDE)

Provides a docker container for development of Boost that is easy to use
and accelerates development, testing, and debugging:

- Containers marked 'complete' include all optional dependencies for boost to build completely,
  and can run asan, tsan, ubsan, valgrind.
- Most of the containers are nearly complete in terms of including dependencies.
- Multiarch containers allow you to build and test easily against other architectures.
- Provides a canonical list of package dependencies for each distribution.

Supported combinations of architecture and OS:

| DEFAULT | DISTRO | EDITION | ARCH    | Endian | Complete? | Clang | GCC  | CMake | Cppcheck | Valgrind |
| ------- | ------ | ------- | ------- | ------ | --------- | ----- | ---  | ----- | -------- | -------- |
|         | alpine | edge    | ppc64le | little | No        |  17.0 | 13.2 |  3.29 |     2.14 |     3.23 |
|         | alpine | edge    | x86_64  | little | No        |  17.0 | 13.2 |  3.29 |     2.14 |     3.23 |
|         | fedora | 34      | ppc64le | little | No        |  12.1 | 11.3 |  3.20 |     2.6  |     3.18 |
|         | fedora | 34      | s390x   | big    | No        |  12.1 | 11.3 |  3.20 |     2.6  |     3.18 |
|         | fedora | 34      | x86_64  | little | Yes       |  12.1 | 11.3 |  3.20 |     2.6  |     3.18 |
|         | ubuntu | focal   | arm64   | little | No        |  10.0 |  9.4 |  3.16 |     1.90 |     3.15 |
|         | ubuntu | focal   | ppc64el | little | No        |  10.0 |  9.4 |  3.16 |     1.90 |     3.15 |
|         | ubuntu | focal   | s390x   | big    | No        |  10.0 |  9.4 |  3.16 |     1.90 |     3.15 |
|         | ubuntu | focal   | x86_64  | little | No        |  10.0 |  9.4 |  3.16 |     1.90 |     3.15 |
|   yes   | ubuntu | noble   | x86_64  | little | Yes       |  18.1 | 13.2 |  3.28 |     2.13 |     3.22 |

To use any image that is not native to your host architecture and endianness,
you must satisfy the prerequisites of running a
[multiarch](https://github.com/multiarch/qemu-user-static) docker container:

1. Install the binfmt-support and qemu-user-static packages.
2. Run `bdde-multiarch`.

Due to the performance decrease when running multiarch emulation, the CI script does not attempt
to run asan, tsan, ubsan, or build all of boost on every platform.  The GitHub workflow file defines
which tests run on each container so you can easily identify what works and what probably does not.
There may be missing packages for specific libraries on some packages.  Add an issue in GitHub if you
find one.  When adding a new distribution, recommend starting with x86_64 to prove out the package list.

## Tag naming convention

This project uses the form `<distro>-<edition>-<arch>-<version>` to tag images.
Given a release tag such as `v3.0.0`, the following images will exist on Docker Hub:

- ubuntu-noble-x86_64-v3.0.0
- ubuntu-noble-x86_64-latest

## Status

| Branch          | GitHub Actions |
| :-------------: | -------------- |
| [`main`](https://github.com/jeking3/bdde) | [![Build Status](https://github.com/jeking3/bdde/actions/workflows/ci.yml/badge.svg)](https://github.com/jeking3/bdde/actions) |

## Make targets

Running `make all` will build all the containers locally (or pull them).  It does not test the containers, but the CI script does.

## Adding Platforms

1. Modify the Dockerfile(s) as needed.  Follow existing patterns of re-use.
2. A new make target will be available named `image-<distro>-<edition>-<arch>` automatically.  Use this to test the image build.
3. Modify `.github/workflows/ci.yml` - note that only branches in the repository itself can properly test these changes.
4. Add the platform to this README.

### Releasing

1. Create a pre-release tag in the repository to generate prerelease images.  This will run tests.
2. Promote the pre-release to a release.  This will build the images again and publish the release version and latest tags.

## Upgrading

In version 2.x and earlier the "latest" container was simply named by the
`<distro>-<edition>.<arch>`.  Starting with version 3.x the naming convention
is `<distro>-<edition>-<arch>-<version>`.

## Future Plans

* Support for a Visual Studio 20xx Build Tools environment is planned,
  enabling Windows containerized builds with all of the required and
  optional dependencies prepared.

## Linux Development

Linux development is possible on any platform with a linux-capable
docker container environment.  Complete containers include:

1. All of the required and optional dependencies for boost repositories.
2. All of the documentation build dependencies.
3. Both libstdc++ and libc++ are provided.
4. Components for static code analysis (cppcheck, ubsan, valgrind).

BDDE will either use `BOOST_ROOT`, or determine it automatically based
on your current working directory inside a boost source tree.

BDDE maps your user into the container by mounting the passwd, group, and
shadow files into the container.  This allows the directory containing boost
to be mounted and accessed with your identity.

### Usage

Unless specified, the `ubuntu-noble-x86_64-latest` container is the one that will
be used.  See the Environment Variables section below to learn how to
control which container is used.

Add the `bin/linux` path to your environment (or do this in your .profile
to make it permanent):

    user@ubuntu:~/bdde$ export PATH=$(pwd)/bin/linux:$PATH

Pull or build the linux docker image for the architecture you want, for example:

    user@ubuntu:~/bdde$ bdde-pull

If you do not have the boost source tree locally, obtain it:

    user@ubuntu:~$ export BOOST_ROOT=~/boost
    user@ubuntu:~$ bdde-clone

The entire boost source collection is downloaded into `BOOST_ROOT`, and
the `develop` branch is checked out.  Each sub-repository in `libs/` and
'tools/' will be set to a detached head, with the git commit synchronized
with the top level.

Now navigate to a location within your boost source tree and use `bdde`
to jump into a docker container at that location where you can start a build.

    user@ubuntu:~$ cd $BOOST_ROOT
    user@ubuntu:~/boost$ bdde

Now you are inside a docker container.  Anything you do inside the `/boost`
directory will be preserved to your BOOST_ROOT.  Anything you do outside of
the `/boost` directory is destroyed when you exit the docker container shell
prompt.  Type `exit` to leave the container and go back to your host prompt.

Boost provides its own build system, Boost.Build, previously known as Boost
Jam.  You need to build it one time using the bootstrap shell script.  By adding
bdde in front of the command you want to run, whatever follows is run inside
the development container.  This will generate the b2 executable:

    user@ubuntu:~/boost$ bdde bootstrap.sh

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

https://www.boost.org/doc/libs/1_78_0/more/getting_started/unix-variants.html

#### ASAN, TSAN, UBSAN, Valgrind

BDDE provides a convenience to make it easy to run anything under a sanitizer.
This is a modification of the b2 command with options added to invoke the
sanitizer and to print a stacktrace on error:

    user@ubuntu:~/boost/libs/format$ bdde-asan
    user@ubuntu:~/boost/libs/format$ bdde-tsan
    user@ubuntu:~/boost/libs/format$ bdde-ubsan
    user@ubuntu:~/boost/libs/format$ bdde-valgrind

## Environment

The following environment variables control the behavior of bdde:

| Variable | Default | Meaning |
| -------- | ------- | ------- |
| BDDE_ARCH | `x86_64` | The architecture to use. |
| BDDE_DISTRO | `ubuntu` | The distribution to use. |
| BDDE_DOCK |  | Additional options to pass to docker when launching the container.  Not commonly used. |
| BDDE_EDITION | `noble` | The distribution's edition to use. |
| BDDE_REBUILD | `false` | Force container images to be rebuilt. |
| BDDE_REGISTRY | `docker.io` | The container registry to use. |
| BDDE_REPO | `jeking/bdde3` | The container repository to use. |
| BDDE_SHELL | `/bin/bash` | The shell to use inside the container. |
| BDDE_VERSION | `latest` | The container version to use. |
| BOOST_ROOT | `$(pwd)/boost-root` | The directory containing (or planned to contain) the boostorg clone. |

## Example

This is an example of running a big-endian ppc64 Fedora based image
on a little-endian x86_64 host running Ubuntu Bionic:

### Installing Prerequisites

    user@ubuntu:~$ sudo apt-get install -y binfmt-support qemu-user-static
    user@ubuntu:~$ bdde-multiarch

### Running a unit test in Boost.Predef while emulating a big-endian system

    user@ubuntu:~/boost$ export BDDE_DISTRO=fedora
    user@ubuntu:~/boost$ export BDDE_EDITION=34
    user@ubuntu:~/boost$ export BDDE_ARCH=s390x
    user@ubuntu:~/boost$ export BOOST_ROOT=$HOME/boost-root
    user@ubuntu:~/boost$ bdde bootstrap.sh
    + docker run --rm --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -v /home/jking/boost-root:/boost:rw -v /home/jking/jking/bdde:/bdde:ro -v /home/jking/.vimrc:/home/boost/.vimrc:ro --workdir /boost/. -it jeking3/bdde:fedora-34-s390x-latest /bin/bash -c 'bootstrap.sh'
    ###
    ###
    ### Using 'gcc' toolset.
    ###
    ###

    g++ (GCC) 11.2.1 20210728 (Red Hat 11.2.1-1)
    Copyright (C) 2021 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions.  There is NO
    warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


    ###
    ###

    > g++ -x c++ -std=c++11 -O2 -s -DNDEBUG builtins.cpp class.cpp command.cpp compile.cpp constants.cpp cwd.cpp debug.cpp debugger.cpp execcmd.cpp execnt.cpp execunix.cpp filesys.cpp filent.cpp fileunix.cpp frames.cpp function.cpp glob.cpp hash.cpp hcache.cpp hdrmacro.cpp headers.cpp jam_strings.cpp jam.cpp jamgram.cpp lists.cpp make.cpp make1.cpp md5.cpp mem.cpp modules.cpp native.cpp object.cpp option.cpp output.cpp parse.cpp pathnt.cpp pathsys.cpp pathunix.cpp regexp.cpp rules.cpp scan.cpp search.cpp startup.cpp subst.cpp sysinfo.cpp timestamp.cpp variable.cpp w32_getreg.cpp modules/order.cpp modules/path.cpp modules/property-set.cpp modules/regex.cpp modules/sequence.cpp modules/set.cpp -o b2
    > cp b2 bjam
    tools/build/src/engine/b2
    Unicode/ICU support for Boost.Regex?... not found.
    Backing up existing B2 configuration in project-config.jam.14
    Generating B2 configuration in project-config.jam for gcc...

    Bootstrapping is done. To build, run:

        ./b2
    
    To generate header files, run:

        ./b2 headers

    The configuration generated uses gcc to build by default. If that is
    unintended either use the --with-toolset option or adjust configuration, by
    editing 'project-config.jam'.
    
    ...

    # hop into the container in a specific
    user@ubuntu:~/boost$ cd libs/predef/test
    user@ubuntu:~/boost/libs/predef/test$ bdde
    [boost@b36ab70f591f test]$ b2 toolset=gcc stdlib=gnu11 -a info_as_cpp
    MPI auto-detection failed: unknown wrapper compiler mpic++
    You will need to manually configure MPI support.
    Performing configuration checks

        - default address-model    : 64-bit [1]
        - default architecture     : s390x [1]
        - symlinks supported       : yes

    [1] gcc-11
    ...found 40 targets...
    ...updating 11 targets...
    mklink-or-dir ../../../boost
    mklink-or-dir ../../../boost/predef
    ...patience...
    link.mklink ../../../boost/predef.h
    gcc.compile.c++ ../../../bin.v2/libs/predef/test/info_as_cpp.test/gcc-11/debug/stdlib-gnu11/threading-multi/visibility-hidden/info_as_cpp.o
    gcc.link ../../../bin.v2/libs/predef/test/info_as_cpp.test/gcc-11/debug/stdlib-gnu11/threading-multi/visibility-hidden/info_as_cpp
    testing.capture-output ../../../bin.v2/libs/predef/test/info_as_cpp.test/gcc-11/debug/stdlib-gnu11/threading-multi/visibility-hidden/info_as_cpp.run
    **passed** ../../../bin.v2/libs/predef/test/info_as_cpp.test/gcc-11/debug/stdlib-gnu11/threading-multi/visibility-hidden/info_as_cpp.test
    ...updated 12 targets...
    [boost@b36ab70f591f test]$ ../../../bin.v2/libs/predef/test/info_as_cpp.test/gcc-11/debug/stdlib-gnu11/threading-multi/visibility-hidden/info_as_cpp | head -10
    ** Detected **
    BOOST_ARCH_SYS390 = 1 (0,0,1) | System/390
    BOOST_ARCH_WORD_BITS = 32 (0,0,32) | Word Bits
    BOOST_ARCH_WORD_BITS_32 = 1 (0,0,1) | 32-bit Word Size
    BOOST_COMP_GNUC = 110200001 (11,2,1) | Gnu GCC C/C++
    BOOST_ENDIAN_BIG_BYTE = 1 (0,0,1) | Byte-Swapped Big-Endian
    BOOST_LANG_STDC = 1 (0,0,1) | Standard C
    BOOST_LANG_STDCPP = 470300001 (47,3,1) | Standard C++
    BOOST_LIB_C_GNU = 23300000 (2,33,0) | GNU
    BOOST_LIB_STD_GNU = 510700028 (51,7,28) | GNU
