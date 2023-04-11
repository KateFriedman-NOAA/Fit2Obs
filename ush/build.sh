#!/bin/bash

set -eu

# Get the root of the cloned GFS-utils directory
readonly DIR_ROOT=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )/.." && pwd -P)

# User Options
BUILD_TYPE=${BUILD_TYPE:-"Release"}
CMAKE_OPTS=${CMAKE_OPTS:-}
COMPILER=${COMPILER:-"intel"}
BUILD_DIR=${BUILD_DIR:-"${DIR_ROOT}/build"}
INSTALL_PREFIX=${INSTALL_PREFIX:-"${DIR_ROOT}/install"}

#==============================================================================#

# Detect machine (sets MACHINE_ID)
source $DIR_ROOT/ush/detect_machine.sh

# Load modules
source $DIR_ROOT/ush/module-setup.sh
module use $DIR_ROOT/modulefiles
module load fit2obs_$MACHINE_ID
module list

# Collect BUILD Options
CMAKE_OPTS+=" -DCMAKE_BUILD_TYPE=$BUILD_TYPE"

# Install destination for built executables, libraries, CMake Package config
CMAKE_OPTS+=" -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DCMAKE_INSTALL_BINDIR=exec"

# Re-use or create a new BUILD_DIR (Default: create new BUILD_DIR)
[[ ${BUILD_CLEAN:-"YES"} =~ [yYtT] ]] && rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR && cd $BUILD_DIR

# Configure, build, install
set -x
cmake $CMAKE_OPTS $DIR_ROOT
make -j ${BUILD_JOBS:-8} VERBOSE=${BUILD_VERBOSE:-}
make install
set +x

# Move the exec files to were they were before cmake-ifying
rm -rf ${DIR_ROOT}/exec
mkdir -p ${DIR_ROOT}/exec
for execfile in $(ls ${DIR_ROOT}/install/exec); do
mv ${DIR_ROOT}/install/exec/$execfile ${DIR_ROOT}/exec/$execfile.x
done; rm -rf ${DIR_ROOT}/install

exit
