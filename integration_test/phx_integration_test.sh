#!/bin/bash
#set -x

LOG="../../integration_test/phx_integration_test.log"

function enter_cave {
    echo -e "\nDATE: $(date) OPTIONS: $@\n" >> $LOG
    mix phauxth.new $@
}

function run_tests {
    mix test >> $LOG
    MIX_ENV=test mix ecto.drop
}

function clean {
    cd ..
    rm -rf alibaba
}

function phauxth_project {
    cd alibaba || exit $?
    enter_cave $@
    mix deps.get
    run_tests
    clean
}

cd $(dirname "$0")/../tmp
echo y | mix phx.new alibaba
phauxth_project
echo y | mix phx.new alibaba
phauxth_project --confirm
echo y | mix phx.new alibaba --no-html --no-brunch
phauxth_project --api
echo y | mix phx.new alibaba --no-html --no-brunch
phauxth_project --api --confirm
echo "------------------------------------------------------------"
grep "test.*failure" ../integration_test/phx_integration_test.log
grep "error" ../integration_test/phx_integration_test.log
