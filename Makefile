#
# Copyright (C) 2018 James E. King III
#
# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#

clean:
	@ if [ ! -z "$(docker ps -a -q)" ]; then docker rm $(docker ps -a -q); fi
	@ if [ ! -z "$(docker images -q -f dangling=true)" ]; then docker rmi $(docker images -q -f dangling=true); fi

image:
	docker pull jeking3/bdde:linux || docker build -t jeking3/bdde:linux -f Dockerfile.linux .

test:
	./bin/linux/test/bash_unit/bash_unit ./bin/linux/test/test_*.sh
