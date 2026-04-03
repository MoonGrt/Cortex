BOARD ?= genesys2
MODE ?= batch

ifeq ($(BOARD), genesys2)
	XILINX_PART  := xc7k325tffg900-2
	XILINX_BOARD := digilentinc.com:genesys2:part0:1.1
	XDC_FILES    := xdc/genesys2.xdc
else ifeq ($(BOARD), kc705)
	XILINX_PART  := xc7k325tffg900-2
	XILINX_BOARD := xilinx.com:kc705:part0:1.5
	XDC_FILES    := xdc/kc705.xdc
else
$(error Unknown board - please specify a supported FPGA board)
endif

RTL_TOP = demo
RTL_FILES = $(shell find rtl -type f -name "*.v")
SIM_TOP = tb_demo
SIM_FILES = $(shell find sim -type f -name "*.v")
include ./scripts/vivado.mk

ITER    ?= 5
INPUT   := $(WORK_DIR)/sim/input.txt
OUTPUT  := $(WORK_DIR)/sim/output.txt
WAVEFIR := $(WORK_DIR)/sim/wave
sim_init:
	@mkdir -p $(WAVEFIR)
	@echo "0" > $(INPUT)
	@: > $(OUTPUT)
sim_repeat: sim_init
	@cat << EOF > $(WORK_DIR)/sim_repeat.tcl
		open_project $(BPREFIX).xpr
		launch_simulation $(SIM_OPTS)
		for {set i 0} {\$$i < $(ITER)} {incr i} {
			puts "=== Simulation Run \$$i ==="
			restart
			open_vcd "$(abspath $(WAVEFIR))/wave\$$i.vcd"
			log_vcd [get_objects -r *]
			run all
			close_vcd
			puts "Wave file: $(abspath $(WAVEFIR))/wave\$$i.vcd"
		}
		exit
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source $(WORK_DIR)/sim_repeat.tcl
.PHONY: sim_repeat
