#!/usr/bin/env bash
set -euo pipefail

CHOICE=""
OPENLANE_METHOD=""

error_handler() {
  echo "[error] Installation failed."
  case "$CHOICE" in
    1)
      echo "Please refer to Openlane official website:"
      echo "https://openlane2.readthedocs.io/"
      ;;
    2)
      echo "Please refer to Verilator official website:"
      echo "https://www.verilator.org/"
      ;;
    *)
      echo "Unknown option."
      ;;
  esac
}

trap error_handler ERR

# Ensure sudo
if [[ $EUID -ne 0 ]]; then
  sudo -v || exit 1
fi

echo "Select installation option:"
echo "1) Install Openlane"
echo "2) Install Verilator"
read -p "Enter choice [1-2]: " CHOICE

install_openlane_nix() {
  echo "=== Installing OpenLane using Nix ==="
  sudo apt-get update
  sudo apt-get install -y curl git

  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm --extra-conf "
    extra-substituters = https://openlane.cachix.org
    extra-trusted-public-keys = openlane.cachix.org-1:qqdwh+QMNGmZAuyeQJTH9ErW57OWSvdtuwfBKdS254E="
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

  # Enable Cachix
  nix-env -f "<nixpkgs>" -iA cachix
  sudo env PATH="$PATH" cachix use openlane
  sudo pkill nix-daemon

  # Clone OpenLane2
  git clone https://github.com/efabless/openlane2/ ~/openlane2
  cd ~/openlane2
  git submodule update --init --recursive

  # Enter nix-shell and run smoke test
  nix-shell --pure ~/openlane2/shell.nix --run \
    "openlane --log-level ERROR --condensed --show-progress-bar --smoke-test --pdk gf180mcu"
}

install_openlane_docker() {
  echo "=== Installing OpenLane using Docker ==="
  sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg lsb-release build-essential \
    python3 python3-venv python3-pip python3-tk make git

  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  # Add user to docker group
  sudo groupadd docker || true
  sudo usermod -aG docker $USER
  echo "Docker installed. Please log out and log in again (or reboot) to use docker without sudo."
  # Install OpenLane via pip and run smoke test
  python3 -m pip install --upgrade pip
  python3 -m pip install openlane
  echo "NiX Openlane is installed. Please run the following command to run smoke test, after logging out and logging in again:"
  echo "openlane --log-level ERROR --condensed --show-progress-bar --smoke-test --pdk gf180mcu"
}

install_verilator() {
  echo "=== Installing Verilator ==="
  sudo apt update
  sudo apt install -y make autoconf g++ flex libfl-dev bison help2man
  git clone https://github.com/verilator/verilator.git
  cd verilator
  git pull
  unset VERILATOR_ROOT
  autoconf
  ./configure
  make -j $(nproc)
  sudo make install
  cd ..
  rm -rf verilator
}

case $CHOICE in
  1)
    echo "Select OpenLane installation method:"
    echo "1) Nix"
    echo "2) Docker"
    read -p "Enter choice [1-2]: " OPENLANE_METHOD
    case $OPENLANE_METHOD in
      1) install_openlane_nix ;;
      2) install_openlane_docker ;;
      *) echo "Invalid method"; exit 1 ;;
    esac
    ;;
  2)
    install_verilator
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

echo "=== Done ==="
