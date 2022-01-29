#
# Copyright (C) 2018 - 2022 James E. King III
#
# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#

.PHONY: all images test verify

images:
	BDDE_DISTRO=ubuntu BDDE_EDITION=focal BDDE_ARCH=arm64 bin/linux/bdde-build
	BDDE_DISTRO=ubuntu BDDE_EDITION=focal BDDE_ARCH=x86_64 bin/linux/bdde-build
	BDDE_DISTRO=fedora BDDE_EDITION=34 BDDE_ARCH=s390x bin/linux/bdde-build

# unit tests for some shell code; not much to this...
test:
	./bin/linux/test/bash_unit/bash_unit -f tap ./bin/linux/test/test_*.sh

verify:
	BDDE_DISTRO=ubuntu BDDE_EDITION=focal BDDE_ARCH=arm64 BDDE_SHELL="uname -a" bin/linux/bdde | grep aarch64
	BDDE_DISTRO=ubuntu BDDE_EDITION=focal BDDE_ARCH=x86_64 BDDE_SHELL="uname -a" bin/linux/bdde | grep x86_64
	BDDE_DISTRO=fedora BDDE_EDITION=34 BDDE_ARCH=s390x BDDE_SHELL="uname -a" bin/linux/bdde | grep s390x
