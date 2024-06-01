#!/usr/bin/env bash
#
# Copyright (C) 2018 - 2024 James E. King III
#
# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# Boost Docker Development Environment
#

# Defaults
BDDE_ARCH=${BDDE_ARCH:-x86_64}
BDDE_DISTRO=${BDDE_DISTRO:-ubuntu}
BDDE_EDITION=${BDDE_EDITION:-noble}
BDDE_REGISTRY=${BDDE_REGISTRY:-docker.io/}
BDDE_REPO=${BDDE_REPO:-jeking3/bdde}
BDDE_SHELL=${BDDE_SHELL:-/bin/bash}
BDDE_VERSION=${BDDE_VERSION:-latest}

# The slug is the image tag name
BDDE_SLUG=${BDDE_DISTRO}-${BDDE_EDITION}-${BDDE_ARCH}-${BDDE_VERSION}

# The full image name: registry, repository, tag
BDDE_IMAGE=${BDDE_REGISTRY}${BDDE_REPO}:${BDDE_SLUG}

# This allows for INCLUDE+ which is really, really useful!
export DOCKER_BUILDKIT=1
