#!/usr/bin/env bash
#
# Copyright (C) 2018 James E. King III
#
# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#

. ../lib/find_boost_root.sh

function setup_suite
{
    TEMPDIR=$(mktemp -d)
    mkdir -p ${TEMPDIR}/valid/libs/uuid
    touch ${TEMPDIR}/valid/bootstrap.sh
    mkdir -p ${TEMPDIR}/invalid-no-libs
    touch ${TEMPDIR}/invalid-no-libs/bootstrap.sh
    mkdir -p ${TEMPDIR}/invalid-no-bootstrap/libs
}

function teardown_suite
{
    rm -rf ${TEMPDIR}
}

function test_find_boost_root
{
    assert_equals "${TEMPDIR}/valid" $(BOOST_ROOT=${TEMPDIR}/valid find_boost_root)
    assert_status_code 5 "BOOST_ROOT=${TEMPDIR}/valid/libs/uuid find_boost_root"
    assert_status_code 5 "BOOST_ROOT=${TEMPDIR}/invalid-no-libs find_boost_root"
    assert_status_code 5 "BOOST_ROOT=${TEMPDIR}/invalid-no-bootstrap find_boost_root"

    assert_equals "${TEMPDIR}/valid" $(unset BOOST_ROOT && cd ${TEMPDIR}/valid/libs/uuid && find_boost_root)
    assert_status_code 2 "unset BOOST_ROOT && cd ${TEMPDIR}/invalid-no-libs && find_boost_root"
    assert_status_code 2 "unset BOOST_ROOT && cd ${TEMPDIR}/invalid-no-bootstrap/libs && find_boost_root"
}
