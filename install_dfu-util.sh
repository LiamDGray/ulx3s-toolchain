#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"
# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks (optional 1 keyowrd)
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

#"***************************************************************************************************"
# install the dfu-util form from ulx3s
#"***************************************************************************************************"
echo "***************************************************************************************************"
echo " dfu-util. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
if [ ! -d "$WORKSPACE"/dfu-util ]; then
  git clone --recursive https://github.com/ulx3s/dfu-util.git     2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
  cd dfu-util
else
  cd dfu-util
  git fetch                                                       2>&1 | tee -a "$THIS_LOG"
  git pull                                                        2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

# See INSTALL file for building

# Generate build system files (requires autoconf from autotools)
./autogen.sh

# Generate makefiles
./configure

# Build executables
make

# Install executables and manual pages (optional)
sudo make install


cd $SAVED_CURRENT_PATH

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
