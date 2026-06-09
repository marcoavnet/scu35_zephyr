#!/bin/bash
export TRD_HOME=$PWD/../

export ZEPHYR_BASE=$TRD_HOME/sw/src/kernel/zephyr
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR=$TRD_HOME/sw/tools/zephyr-sdk-0.16.8

source $TRD_HOME/sw/bld/zephyr-venv/bin/activate

cd "$ZEPHYR_BASE"
