VIVADO_BOARD ?= genesys2
VIVADO_MODE  ?= batch

ifeq ($(VIVADO_BOARD), genesys2)
	XILINX_PART  := xc7k325tffg900-2
	XILINX_BOARD := digilentinc.com:genesys2:part0:1.1
else ifeq ($(VIVADO_BOARD), kc705)
	XILINX_PART  := xc7k325tffg900-2
	XILINX_BOARD := xilinx.com:kc705:part0:1.5
else
$(error Unknown board - please specify a supported FPGA board)
endif

###################################################################
#
# Parameters:
# VIVADO_DIR			- 构建时的输出路径, 默认=build
# CONFIG			- 用户配置 Makefile
# VIVADO_PRJ			- 项目名称, 默认=vivado
# RTL_TOP			- 顶层模块名, 默认=fpga
# SIM_TOP			- 仿真部分的顶层模块
# SIM_MODE 			- 仿真模式, 默认=behavioral
# SIM_TYPE			- 仿真类型, 默认=
# XILINX_PART		- XILINX 设备
# XILINX_BOARD		- XILINX 板子
# RTL_FILES			- 可综合源文件
# SIM_FILES			- 仿真文件
# INC_FILES			- 要包含的文件
# VIVADO_XDC			- 约束文件
# XCI_FILES			- xci 格式的 IP 文件
# IP_TCL_FILES		- tcl 格式的 IP 文件
# BD_TCL_FILES		- BD 设计文件
# IP_REPO_PATHS		- IP 仓库地址
# CONFIG_TCL_FILES	- tcl 配置文件
#
# Example:
#
# XILINX_PART  := xc7k325tffg900-2
# XILINX_BOARD := digilentinc.com:genesys2:part0:1.1
# VIVADO_XDC    := xdc/genesys2.xdc
# RTL_TOP = dut_pipeline
# RTL_FILES = rtl/dut.v
# SIM_TOP = tb_chain
# SIM_FILES = sim/tb_chain.v
# VIVADO_MODE = batch
#
###################################################################

# phony targets
.PHONY: vivado-fpga vivado-clean vivado-program vivado-config vivado-synth vivado-impl vivado-flash vivado-sim

# prevent make from deleting intermediate files and reports
.PRECIOUS: %.xpr %.bit %.mcs %.prm
.SECONDARY:

CONFIG ?= config.mk
-include $(CONFIG)

VIVADO      ?= vivado
VIVADO_PRJ  ?= vivado
VIVADO_DIR  := $(abspath $(PRJ_BUILD_DIR))/vivado
VIVADO_MODE ?= gui
VIVADO_OPTS += -nojournal -nolog -tempDir $(VIVADO_DIR) -mode $(VIVADO_MODE)
VIVADO_BPREFIX = $(VIVADO_DIR)/$(VIVADO_PRJ)

ifeq ($(VIVADO_MODE),gui)
VIVADO_EXIT :=
else
VIVADO_EXIT := exit
endif

ifeq ($(SIM_MODE),behavioral)
SIM_OPTS :=
else
SIM_OPTS := -mode $(SIM_MODE) -type $(SIM_TYPE)
endif

###################################################################
# Main Targets
#
# all: build everything
# clean: remove output files and project files
###################################################################
.ONESHELL:
vivado-all: vivado-fpga

vivado-fpga: $(VIVADO_BPREFIX).bit

vivado-prj: $(VIVADO_BPREFIX).xpr
	$(VIVADO) $(VIVADO_OPTS) $(VIVADO_BPREFIX).xpr

vivado-clean:
	rm -rf $(VIVADO_DIR)

###################################################################
# Target implementations
###################################################################

# Vivado project file
$(VIVADO_DIR)/create_project.tcl: makefile $(XCI_FILES) $(IP_TCL_FILES)
	mkdir -p $(VIVADO_DIR)
	cat << EOF > $@ ;
		create_project -force -part $(XILINX_PART) $(VIVADO_PRJ) $(VIVADO_DIR);
	EOF
	if [ "$(XILINX_BOARD)" ]; then echo "set_property board_part $(XILINX_BOARD) [current_project]" >> $@; fi
	if [ "$(RTL_FILES)" ]; then echo "add_files -fileset sources_1 $(RTL_FILES)" >> $@; fi
	if [ "$(VIVADO_XDC)" ]; then echo "add_files -fileset constrs_1 $(VIVADO_XDC)" >> $@; fi
	if [ "$(SIM_FILES)" ]; then echo "add_files -fileset sim_1 $(SIM_FILES)" >> $@; fi
	if [ "$(IP_REPO_PATHS)" ]; then
		echo "set_property ip_repo_paths [concat $(IP_REPO_PATHS)] [current_project]" >> $@; fi
	for x in $(XCI_FILES); 			do echo "import_ip $$x"	>> $@; done
	for x in $(IP_TCL_FILES); 		do echo "source $$x" 	>> $@; done
	for x in $(CONFIG_TCL_FILES); 	do echo "source $$x" 	>> $@; done
	for x in $(BD_TCL_FILES); 		do
		echo "source $$x" 	>> $@;
		echo "make_wrapper -files [get_files [glob $(VIVADO_BPREFIX).srcs/sources_1/bd/**/*.bd]] -top" >> $@
		echo "add_files -fileset sources_1 [glob $(VIVADO_BPREFIX).gen/sources_1/bd/**/hdl/*wrapper.v]" >> $@
	done
	if [ "$(RTL_TOP)" ]; then echo "set_property top $(RTL_TOP) [get_filesets sources_1]" >> $@; fi
	if [ "$(SIM_TOP)" ]; then echo "set_property top $(SIM_TOP) [get_filesets sim_1]" >> $@; fi
	@echo $(VIVADO_EXIT) >> $@

$(VIVADO_DIR)/update_config.tcl: $(CONFIG_TCL_FILES) $(RTL_FILES) $(INC_FILES) $(VIVADO_XDC)
	mkdir -p $(VIVADO_DIR)
	@echo "open_project -quiet $(VIVADO_BPREFIX).xpr" > $@
	for x in $(CONFIG_TCL_FILES); do echo "source $$x" >> $@; done

$(VIVADO_BPREFIX).xpr: $(VIVADO_DIR)/create_project.tcl $(VIVADO_DIR)/update_config.tcl
	mkdir -p $(VIVADO_DIR)
	$(VIVADO) $(VIVADO_OPTS) $(foreach x,$?,-source $x)

# synthesis run
$(VIVADO_BPREFIX).runs/synth_1/$(VIVADO_PRJ).dcp: $(VIVADO_DIR)/create_project.tcl $(VIVADO_DIR)/update_config.tcl \
	$(RTL_FILES) $(INC_FILES) $(VIVADO_XDC) | $(VIVADO_BPREFIX).xpr
	cat << EOF > $(VIVADO_DIR)/run_synth.tcl
		open_project $(VIVADO_BPREFIX).xpr
		reset_run synth_1
		launch_runs -jobs 4 synth_1
		wait_on_run synth_1
		$(VIVADO_EXIT)
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source $(VIVADO_DIR)/run_synth.tcl

# implementation run
$(VIVADO_BPREFIX).runs/impl_1/$(VIVADO_PRJ)_routed.dcp: $(VIVADO_BPREFIX).runs/synth_1/$(VIVADO_PRJ).dcp
	cat << EOF > $(VIVADO_DIR)/run_impl.tcl
		open_project $(VIVADO_BPREFIX).xpr
		reset_run impl_1
		launch_runs -jobs 4 impl_1
		wait_on_run impl_1
		open_run impl_1
		report_utilization -file $(VIVADO_BPREFIX)_utilization.rpt
		report_utilization -hierarchical -file $(VIVADO_BPREFIX)_utilization_hierarchical.rpt
		$(VIVADO_EXIT)
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source $(VIVADO_DIR)/run_impl.tcl

# bit file
$(VIVADO_BPREFIX).bit $(VIVADO_BPREFIX).ltx: $(VIVADO_BPREFIX).runs/impl_1/$(VIVADO_PRJ)_routed.dcp
	cat << EOF > $(VIVADO_DIR)/generate_bit.tcl
		open_project $(VIVADO_BPREFIX).xpr
		open_run impl_1
		write_bitstream -force $(VIVADO_BPREFIX).runs/impl_1/$(VIVADO_PRJ).bit
		write_debug_probes -force $(VIVADO_BPREFIX).runs/impl_1/$(VIVADO_PRJ).ltx
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source $(VIVADO_DIR)/generate_bit.tcl

	cp -pv $(VIVADO_BPREFIX).runs/impl_1/$(VIVADO_PRJ).bit $(VIVADO_DIR)
	if [ -e $(VIVADO_BPREFIX).runs/impl_1/$(VIVADO_PRJ).ltx ]; then
		cp -pv $(VIVADO_BPREFIX).runs/impl_1/$(VIVADO_PRJ).ltx $(VIVADO_DIR)
	fi

	mkdir -p $(VIVADO_DIR)/rev
	COUNT=100

	while [ -e $(VIVADO_DIR)/rev/$(VIVADO_PRJ)_rev$$COUNT.bit ]; do
		COUNT=$$((COUNT+1))
	done

	cp -pv $(VIVADO_BPREFIX).runs/impl_1/$(VIVADO_PRJ).bit $(VIVADO_DIR)/rev/$(VIVADO_PRJ)_rev$$COUNT.bit
	if [ -e $(VIVADO_BPREFIX).runs/impl_1/$(VIVADO_PRJ).ltx ]; then
		cp -pv $(VIVADO_BPREFIX).runs/impl_1/$(VIVADO_PRJ).ltx $(VIVADO_DIR)/rev/$(VIVADO_PRJ)_rev$$COUNT.ltx
	fi

vivado-config: $(VIVADO_BPREFIX).xpr
	make $<

vivado-synth: $(VIVADO_BPREFIX).runs/synth_1/$(VIVADO_PRJ).dcp
	make $<

vivado-impl: $(VIVADO_BPREFIX).runs/synth_1/$(VIVADO_PRJ).dcp
	make $<

vivado-program: $(VIVADO_DIR)/$(RTL_TOP).bit
	cat << EOF > $(VIVADO_DIR)/program.tcl
		open_hw_manager
		connect_hw_server
		open_hw_target
		current_hw_device [lindex [get_hw_devices] 1]
		refresh_hw_device -update_hw_probes false [current_hw_device]
		set_property PROGRAM.FILE {$<} [current_hw_device]
		program_hw_devices [current_hw_device]
		$(VIVADO_EXIT)
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source $(VIVADO_DIR)/program.tcl

vivado-sim: $(VIVADO_BPREFIX).xpr
	mkdir -p $(VIVADO_DIR)
	cat << EOF > $(VIVADO_DIR)/sim.tcl
		open_project $(VIVADO_BPREFIX).xpr
		launch_simulation $(SIM_OPTS)
		restart
		run all
		$(VIVADO_EXIT)
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source $(VIVADO_DIR)/sim.tcl

%.mcs %.prm: %.bit
	cat << EOF > $(VIVADO_DIR)/generate_mcs.tcl
		write_cfgmem -force -format mcs -size 128 -interface SPIx4 -loadbit {up 0x01002000 $*.bit} -checksum -file $*.mcs
		$(VIVADO_EXIT)
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source $(VIVADO_DIR)/generate_mcs.tcl

	mkdir -p $(VIVADO_DIR)/rev
	COUNT=100
	while [ -e $(VIVADO_DIR)/rev/$*_rev$$COUNT.bit ]; do
		COUNT=$$((COUNT+1))
	done
	COUNT=$$((COUNT-1))
	for x in .mcs .prm; do
		cp $*$$x $(VIVADO_DIR)/rev/$*_rev$$COUNT$$x
		echo "Output: $(VIVADO_DIR)/rev/$*_rev$$COUNT$$x"
	done

vivado-ip_gen: $(VIVADO_BPREFIX).xpr
	cat << EOF > $(VIVADO_DIR)/ip_gen.tcl
		open_project $(VIVADO_BPREFIX).xpr
		ipx::package_project -import_files -force -root_dir ../../ip_gen/$(RTL_TOP)

		set_property vendor              {xilinx.com}            [ipx::current_core]
		set_property library             {user}                  [ipx::current_core]
		set_property taxonomy            {{/demo}}               [ipx::current_core]
		set_property vendor_display_name {shino}                 [ipx::current_core]
		set_property company_url         {xilinx.com}            [ipx::current_core]
		set_property supported_families  {
			virtex7    Production \
			qvirtex7   Production \
			kintex7    Production \
			kintex7l   Production \
			qkintex7   Production \
			qkintex7l  Production \
			artix7     Production \
			artix7l    Production \
			aartix7    Production \
			qartix7    Production \
			zynq       Production \
			qzynq      Production \
			azynq      Production \
			zynquplus  Production
		} [ipx::current_core]

		ipx::save_core [ipx::current_core]
		close_project
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source $(VIVADO_DIR)/ip_gen.tcl

vivado-flash: $(VIVADO_DIR)/$(RTL_TOP).mcs $(VIVADO_DIR)/$(RTL_TOP).prm
	cat << EOF > $(VIVADO_DIR)/flash.tcl
		open_hw
		connect_hw_server
		open_hw_target
		current_hw_device [lindex [get_hw_devices] 0]
		refresh_hw_device -update_hw_probes false [current_hw_device]
		create_hw_cfgmem -hw_device [current_hw_device] [lindex [get_cfgmem_parts {mt25qu01g-spi-x1_x2_x4}] 0]
		current_hw_cfgmem -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM [current_hw_device]]
		set_property PROGRAM.FILES [list \"$(VIVADO_DIR)/$(RTL_TOP).mcs\"] [current_hw_cfgmem]
		set_property PROGRAM.PRM_FILES [list \"$(VIVADO_DIR)/$(RTL_TOP).prm\"] [current_hw_cfgmem]
		set_property PROGRAM.ERASE 1 [current_hw_cfgmem]
		set_property PROGRAM.CFG_PROGRAM 1 [current_hw_cfgmem]
		set_property PROGRAM.VERIFY 1 [current_hw_cfgmem]
		set_property PROGRAM.CHECKSUM 0 [current_hw_cfgmem]
		set_property PROGRAM.ADDRESS_RANGE {use_file} [current_hw_cfgmem]
		set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [current_hw_cfgmem]
		create_hw_bitstream -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM_BITFILE [current_hw_device]]
		program_hw_devices [current_hw_device]
		refresh_hw_device [current_hw_device]
		program_hw_cfgmem -hw_cfgmem [current_hw_cfgmem]
		boot_hw_device [current_hw_device]
		$(VIVADO_EXIT)
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source flash.tcl
