#
# Copyright (C) 2018 - 2019 James E. King III
#
# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#

.PHONY: all clean image test deb-arm64 deb-x86_64 red-ppc64 test

all: deb-arm64 deb-x86_64 red-ppc64

clean:
	@ if [ ! -z "$(docker ps -a -q)" ]; then docker rm $(docker ps -a -q); fi
	@ if [ ! -z "$(docker images -q -f dangling=true)" ]; then docker rmi $(docker images -q -f dangling=true); fi
	bin/linux/bdde-clean-image deb-arm64
	bin/linux/bdde-clean-image deb-x86_64
	bin/linux/bdde-clean-image red-ppc64

deb-arm64:
	cp -p /usr/bin/qemu-arm64-static .
	BDDE_OS=deb BDDE_ARCH=arm64 bin/linux/bdde-build-image

deb-x86_64:
	cp -p /usr/bin/qemu-x86_64-static .
	BDDE_OS=deb BDDE_ARCH=x86_64 bin/linux/bdde-build-image

red-ppc64:
	cp -p /usr/bin/qemu-ppc64-static .
	BDDE_OS=red BDDE_ARCH=ppc64 bin/linux/bdde-build-image

# unit tests for some shell code; not much to this...
test:
	./bin/linux/test/bash_unit/bash_unit -f tap ./bin/linux/test/test_*.sh

verify:
	BDDE_OS=deb BDDE_ARCH=arm64 BDDE_SHELL="uname -a" bdde | grep aarch64
	BDDE_OS=deb BDDE_ARCH=x86_64 BDDE_SHELL="uname -a" bdde | grep x86_64
	BDDE_OS=red BDDE_ARCH=ppc64 BDDE_SHELL="uname -a" bdde | grep ppc64
