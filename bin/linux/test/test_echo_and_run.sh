#!/usr/bin/env bash
#
# Copyright (C) 2018 James E. King III
#
# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#

. ../lib/echo_and_run.sh

function test_echo_and_run
{
    assert_equals "true" $(echo_and_run true)
    assert_status_code 0 "echo_and_run true"
    assert_equals "false" $(echo_and_run false)
    assert_fail "echo_and_run false"
}
