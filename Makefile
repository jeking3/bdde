#
# Copyright (C) 2018 James E. King III
#
# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#

.PHONY: bootstrap build clean image prompt run shell source test

bootstrap: must-define-BOOST_ROOT
	docker run -v ${BOOST_ROOT}:/boost:rw -it boost/bdde:latest /bin/bash -c "./bootstrap.sh"

build: must-define-BOOST_ROOT
	docker run -v ${BOOST_ROOT}:/boost:rw -it boost/bdde:latest /bin/bash -c "./b2 -a -q -j3"

clean:
	docker rm $(docker ps -a -q)
	docker rmi $(docker images -q -f dangling=true)`
	docker run -v ${BOOST_ROOT}:/boost:rw -it boost/bdde:latest /bin/bash -c "./b2 clean"

image:
	docker build -t boost/bdde:latest .

minimal:
	@ if [ ! -d boost ]; then git clone https://github.com/boostorg/boost.git; fi
	cd boost && git submodule update --init tools/build
	cd boost && git submodule update --init libs/predef
	BOOST_ROOT=$(pwd)/boost

must-define-%:
	@ if [ -z "${${*}}" ]; then exit 1; fi

prompt: shell
run:    shell
shell:  must-define-BOOST_ROOT
	docker run -v ${BOOST_ROOT}:/boost:rw -it boost/bdde:latest /bin/bash

source:
	git clone https://github.com/boostorg/boost.git
	cd boost && git checkout -t origin/develop && git submodule update --init --recursive

test:   image minimal bootstrap
	docker run -v ${BOOST_ROOT}:/boost:rw -it boost/bdde:latest /bin/bash -c "./b2 -a -q libs/predef/test"
