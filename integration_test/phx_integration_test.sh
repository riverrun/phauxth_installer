#!/bin/bash
#set -x

LOG="../../integration_test/phx_integration_test.log"

function setup_phx {
    echo y | mix phx.new alibaba $@
    cp -r alibaba alibaba_confirm
    cd alibaba
}

function phauxth_project {
    start_log $@
    mix deps.get
    run_tests
}

function start_log {
    echo -e "\nDATE: $(date) OPTIONS: $@\n" >> $LOG
    mix phauxth.new $@
}

function run_tests {
    mix test >> $LOG
    MIX_ENV=test mix ecto.drop
}

function integration_test {
    phauxth_project $@
    cd .. && rm -rf alibaba
    cd alibaba_confirm
    phauxth_project $@ --confirm
    cd .. && rm -rf alibaba_confirm
}

cd $(dirname "$0")/../tmp

setup_phx
integration_test
setup_phx --no-html --no-brunch
integration_test --api

echo "------------------------------------------------------------"
echo "Report for Phauxth integration test - $(date)"
grep "test.*failure" ../integration_test/phx_integration_test.log
grep "error" ../integration_test/phx_integration_test.log || echo "No errors"
echo "------------------------------------------------------------"
