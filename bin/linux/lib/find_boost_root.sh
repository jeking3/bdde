#!/usr/bin/env bash
#
# Copyright (C) 2018 James E. King III
#
# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#

#
# Locate the boost root.  If the user defines BOOST_ROOT we use that.
# Otherwise we walk back the current path until we find a directory
# that looks like it could be a BOOST_ROOT.
#
# Input:
#   $1 [optional] a path to investigate, default BOOST_ROOT or $(pwd)
#
# Output:
#   If found, prints the path to BOOST_ROOT on stdout and returns success
#   otherwise, prints an error message to stderr and returns failure
#
# Usage:
#   local boostroot=$(find_boost_root)
#   if [ $? ]; then
#      handle_error
#   fi
# 
function find_boost_root
{
    local checkpath=${1:-${BOOST_ROOT:-`pwd`}}
    if [ -e "${checkpath}/bootstrap.sh" ] && [ -d "${checkpath}/libs" ]; then
        echo "${checkpath}"
        return 0
    elif [ "${checkpath}" == "/" ]; then
        >&2 echo "ERROR: boost not located along the current working directory."
        >&2 echo "       try defining the environment variable BOOST_ROOT."
        return 2 # ENOENT
    elif [ ! -z "${BOOST_ROOT}" ]; then
        >&2 echo "ERROR: BOOST_ROOT does not contain content from boostorg/boost."
        return 5 # EINVAL
    else
        find_boost_root $(dirname ${checkpath})
    fi
}
