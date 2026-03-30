#!/usr/bin/env bash
set -euo pipefail

error_handler() {
  echo "[error] Installation failed."
  echo "Please refer to Verilator official website:"
  echo "https://www.verilator.org/"
}

trap error_handler ERR

if [[ $EUID -ne 0 ]]; then
  sudo -v || exit 1
fi

install_verilator() {
  echo "=== Install Verilator ==="
  sudo apt update && sudo apt install -y make autoconf g++ flex libfl-dev bison help2man
  git clone https://github.com/verilator/verilator.git
  cd verilator && git pull
  unset VERILATOR_ROOT
  autoconf && ./configure
  make -j $(nproc)
  sudo make install
  cd .. && rm -rf verilator
}

install_verilator

echo "=== Done ==="
