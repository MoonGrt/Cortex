---
type: [note]
tags: [RISCV, CVA6]
---

## CVA6

https://ruak.github.io/2026/01/23/CVA6-Ubuntu%E5%AE%9E%E4%BE%8B%E5%8C%96%E4%BB%BF%E7%9C%9F/

### Setup

0. Setup the environment variables for the number of jobs.
```sh
# Set the number of jobs to use for compilation
echo 'export CAV6_HOME=$HOME/cva6/cva6' >> ~/.bashrc && source ~/.bashrc
echo 'export RISCV=$HOME/cva6/toolchain' >> ~/.bashrc && source ~/.bashrc
echo 'export PATH="$HOME/cva6/toolchain/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
echo 'export NUM_JOBS=$(nproc)' >> ~/.bashrc && source ~/.bashrc
# Prerequisites
sudo apt-get update
sudo apt-get install -y autoconf automake autotools-dev curl git libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool bc zlib1g-dev cmake help2man device-tree-compiler
```

1. Checkout the repository and initialize all submodules.
```sh
git clone https://github.com/openhwgroup/cva6.git
cd cva6
git submodule update --init --recursive
```

2. Install the GCC Toolchain
```sh
cd $CAV6_HOME/util/toolchain-builder
# 1. Select an installation location for the toolchain (here: the default RISC-V tooling directory $RISCV).
INSTALL_DIR=$RISCV
# 2. Fetch the source code of the toolchain (assumes Internet access.)
bash get-toolchain.sh
# 3. Build and install the toolchain (requires write+create permissions for $INSTALL_DIR.)
bash build-toolchain.sh $INSTALL_DIR
```

3. Install the riscv-dv requirements:
```sh
cd $CAV6_HOME
pip3 install -r verif/sim/dv/requirements.txt
```

4. Run these commands to install a custom Spike and Verilator (i.e. these versions must be used to simulate the CVA6) and [these](#running-regression-tests-simulations) tests suites.
```sh
cd $CAV6_HOME
# DV_SIMULATORS is detailed in the next section
export DV_SIMULATORS=veri-testharness,spike
# export TRACE_FAST=1
bash verif/regress/smoke-tests-cv32a65x.sh
```

5. Running standalone simulations
```sh
cd $CAV6_HOME
export DV_SIMULATORS=veri-testharness,spike
source verif/sim/setup-env.sh
cd $CAV6_HOME/verif/sim
python3 cva6.py --target cv32a60x --iss=$DV_SIMULATORS --iss_yaml=cva6.yaml \
--c_tests ../tests/custom/hello_world/hello_world.c \
--linker=../../config/gen_from_riscv_config/linker/link.ld \
--gcc_opts="-static -mcmodel=medany -fvisibility=hidden -nostdlib \
-nostartfiles -g ../tests/custom/common/syscalls.c \
../tests/custom/common/crt.S -lgcc \
-I../tests/custom/env -I../tests/custom/common"
```

6. Cleaning the build
```sh
make clean && make -C verif/sim clean_all
```

7. Overall setup:
```sh
mkdir cva6 && cd cva6

git clone https://github.com/openhwgroup/cva6.git
cd cva6
git submodule update --init --recursive

# Set the number of jobs to use for compilation
echo 'export CAV6_HOME=$HOME/cva6/cva6' >> ~/.bashrc && source ~/.bashrc
echo 'export RISCV=$HOME/cva6/toolchain' >> ~/.bashrc && source ~/.bashrc
echo 'export PATH="$HOME/cva6/toolchain/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
echo 'export NUM_JOBS=$(nproc)' >> ~/.bashrc && source ~/.bashrc
# Prerequisites
sudo apt-get update
sudo apt-get install -y autoconf automake autotools-dev curl git libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool bc zlib1g-dev cmake help2man device-tree-compiler

cd $CAV6_HOME/util/toolchain-builder
# 1. Select an installation location for the toolchain (here: the default RISC-V tooling directory $RISCV).
INSTALL_DIR=$RISCV
# 2. Fetch the source code of the toolchain (assumes Internet access.)
bash get-toolchain.sh
# 3. Build and install the toolchain (requires write+create permissions for $INSTALL_DIR.)
bash build-toolchain.sh $INSTALL_DIR

cd $CAV6_HOME
pip3 install -r verif/sim/dv/requirements.txt

cd $CAV6_HOME
# DV_SIMULATORS is detailed in the next section
export DV_SIMULATORS=veri-testharness,spike
bash verif/regress/smoke-gen_tests.sh
```

### Usage

1. Basic simulation

```bash
export DV_SIMULATORS=veri-testharness,spike
export TRACE_FAST=1
bash verif/regress/smoke-tests-cv32a65x.sh
```

2. Xilinx FPGA simulation

- 2.1. 安装vivado(18.3)
```bash
# 1. Dowload & unzip the Xilinx tools
tar -xvf Xilinx.tar
# 2. install the dependencies
sudo apt update && sudo apt install -y libncurses5
# 3. Install the Xilinx tools
./xsetup
# 4. Set the environment variables
echo 'source [your_path]/Xilinx/Vivado/2018.3/settings64.sh' \ 
    >> ~/.bashrc && source ~/.bashrc
```

- 2.2. 安装 genesys2 板级支持包
```bash
# 1. Download the repository
git clone https://github.com/Digilent/vivado-boards.git
# 2. Copy the board files to the Vivado installation directory.
cp -r vivado-boards/new/board_files/genesys2 Xilinx/Vivado/2018.3/data/boards/board_files
```

### Project Structure

#### cva6.py
