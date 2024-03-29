#!/usr/bin/env bash
#
# Copyright (C) 2018 - 2022 James E. King III
#
# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# Boost Docker Development Environment
#

BDDE_ARCH=${BDDE_ARCH:-x86_64}
BDDE_DISTRO=${BDDE_DISTRO:-ubuntu}
BDDE_EDITION=${BDDE_EDITION:-focal}
BDDE_REPO=${BDDE_REPO:-jeking3/bdde}
BDDE_SHELL=${BDDE_SHELL:-/bin/bash}
BDDE_SLUG=${BDDE_DISTRO}-${BDDE_EDITION}.${BDDE_ARCH}

export DOCKER_BUILDKIT=1
