#!/bin/bash
#"***************************************************************************************************"
#  ensure all the scripts here are executable
#"***************************************************************************************************"
chmod +x install_set_permissions.sh
./install_set_permissions.sh

#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"
# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

#"***************************************************************************************************"
#  check for minimum system resources needed (typically 40GB new Ubuntu VM with 5GB RAM)
#"***************************************************************************************************"
if [ $(free | grep Mem | awk '{ print $2 }') -lt "$MIN_ULX3S_MEMORY" ]; then
  echo ""
  echo "System memory found:"
  free
  echo ""
  read -p "Warning: At least $MIN_ULX3S_MEMORY bytes of memory is needed. Press a key to continue"
fi

if [ $(df $PWD | awk '/[0-9]%/{print $(NF-2)}' ) -lt "$MIN_ULX3S_DISK" ]; then
  echo ""
  echo "Disk space found in $PWD"
  df $PWD
  echo ""
  read -p "Warning: At least $MIN_ULX3S_DISK bytes of free disk space is needed. Press a key to continue"
fi

echo "Install all ULX3S toolchains. Edit parameters in init.sh"
echo ""
echo "logs saved to $LOG_DIRECTORY"
echo ""
echo ""
read -p "Press enter to continue, or Ctrl-C to abort."

cd $SAVED_CURRENT_PATH

# system updates and dependencies
./install_system.sh

# pre-compiled binaries
./install_ulx3s-bin.sh

# ESP32
./install_esp32.sh
./install_openocd-esp32.sh

# RISC-V
./install_riscv-gnu-toolchain-rv32i.sh
./install_picorv32_riscv32i.sh
./install_openocd.sh

# yosys / prjtrellis / nextpnr
./install_yosys.sh
./install_prjtrellis.sh
./install_nextpnr.sh

# verilator and icestorm
./install_verilator.sh
./install_icestorm.sh

# litex
./install_litex.sh

# not maintained anymore, but arachne-pnr needs icestorm
./install_arachne-pnr.sh

# more examples and tools
./install_rxrbln-picorv32.sh
./install_ujprog.sh
./install_blinky.sh
./install_fpga_odysseus.sh

./install_ulx3s.sh
./install_ulx3s-misc.sh
./install_ulx3s-examples.sh

# run a synthesis
./install_litex-ulx3s.sh

echo "***************************************************************************************************"
echo "update current system again. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
sudo apt-get upgrade --assume-yes        2>&1 | tee -a "$THIS_LOG"

if [ "$(sudo cat /etc/sudoers | grep timestamp_timeout)" != "" ]; then
  echo ""
  echo "WARNING: timestamp_timeout found in /etc/sudoers"
  echo ""
  echo "If you did this in order to install the toolchain unattended, consider removing it now with: sudo visudo"
  echo ""
fi

echo ""
echo "See logs in $LOG_DIRECTORY"
echo ""


echo "Completed $0 " | tee -a "$THIS_LOG"