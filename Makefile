#
# Copyright (C) 2018 - 2024 James E. King III
#
# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#

.DEFAULT: all
.PHONY: images # tests (not working yet)
all: images # tests (not working yet)

#
# Convert properly named Dockerfiles into targets
#

define make-targets
$(eval WORDS   = $(subst -, ,$(subst ., ,$1)))
$(eval DISTRO  = $(word 2, $(WORDS)))
$(eval EDITION = $(word 3, $(WORDS)))
$(eval ARCH    = $(word 4, $(WORDS)))
$(info discovered target $(DISTRO)-$(EDITION)-$(ARCH))
image-$(DISTRO)-$(EDITION)-$(ARCH):
	BDDE_DISTRO=$(DISTRO) BDDE_EDITION=$(EDITION) BDDE_ARCH=$(ARCH) bin/linux/bdde-build
images:: image-$(DISTRO)-$(EDITION)-$(ARCH)
test-$(DISTRO)-$(EDITION)-$(ARCH): image-$(DISTRO)-$(EDITION)-$(ARCH)
	BDDE_DISTRO=$(DISTRO) BDDE_EDITION=$(EDITION) BDDE_ARCH=$(ARCH) bdde ./bootstrap.sh
	BDDE_DISTRO=$(DISTRO) BDDE_EDITION=$(EDITION) BDDE_ARCH=$(ARCH) bdde b2 lib/format
tests:: test-$(DISTRO)-$(EDITION)-$(ARCH)
endef

DOCKERFILES = $(notdir $(wildcard $(PWD)/Dockerfile.[a-z0-9]*-[a-z0-9]*.[a-z0-9]*))
$(foreach DOCKERFILE,$(DOCKERFILES),$(eval $(call make-targets,$(DOCKERFILE))))

# unit tests for some shell code; not much to this...
test-bash:
	./bin/linux/test/bash_unit/bash_unit -f tap ./bin/linux/test/test_*.sh
tests:: test-bash
