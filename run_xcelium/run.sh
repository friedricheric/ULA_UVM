#!/bin/bash

export UVMHOME="/tools/cadence/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d/"

echo "THIS: $(dirname -- $(readlink -fn -- "$0"))"

export CURRENT_PATH=$(dirname -- $(readlink -fn -- "$0"))

# seed=$(((RANDOM % 999999999 )  + 100000000))
seed=10

echo "Running seed: $seed"

if [ -z $1 ]
then
  VERBOSITY="+UVM_VERBOSITY=UVM_MEDIUM"
else
  VERBOSITY="+UVM_VERBOSITY=$1"
fi

# xrun -lwdgen -access rwc -uvm -uvmhome $UVMHOME -svseed $seed -coverage all -covoverwrite \
#   -cflags -I/usr/lib \
#   -v93 -f file_list_vhd.f -sv -f file_list_sv.f -f file_list_c.f ${VERBOSITY}

xrun -lwdgen -access rwc -uvm -uvmhome $UVMHOME -svseed $seed -coverage all -covoverwrite \
  -sv -f ${CURRENT_PATH}/../uvm/file_list_sv.f ${VERBOSITY}
