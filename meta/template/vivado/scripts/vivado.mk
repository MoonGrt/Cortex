###################################################################
# 
# Parameters:
# WORK_DIR			- 构建时的输出路径, 默认=build
# CONFIG			- 用户配置 Makefile
# PROJECT			- 项目名称, 默认=vivado
# RTL_TOP			- 顶层模块名, 默认=fpga
# SIM_TOP			- 仿真部分的顶层模块
# SIM_MODE 			- 仿真模式, 默认=behavioral
# SIM_TYPE			- 仿真类型, 默认=
# XILINX_PART		- XILINX 设备
# XILINX_BOARD		- XILINX 板子
# RTL_FILES			- 可综合源文件
# SIM_FILES			- 仿真文件
# INC_FILES			- 要包含的文件
# XDC_FILES			- 约束文件
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
# XDC_FILES    := xdc/genesys2.xdc
# RTL_TOP = dut_pipeline
# RTL_FILES = rtl/dut.v
# SIM_TOP = tb_chain
# SIM_FILES = sim/tb_chain.v
# MODE = batch
# 
###################################################################

# phony targets
.PHONY: fpga clean program config synth impl flash sim

# prevent make from deleting intermediate files and reports
.PRECIOUS: %.xpr %.bit %.mcs %.prm
.SECONDARY:

CONFIG ?= config.mk
-include $(CONFIG)

RTL_TOP ?= fpga
PROJECT ?= vivado
WORK_DIR ?= work

MODE   ?= gui
VIVADO ?= vivado
VIVADO_OPTS += -nojournal -nolog -tempDir $(WORK_DIR) -mode $(MODE)

BPREFIX = $(WORK_DIR)/$(PROJECT)

SIM_MODE ?= behavioral
SIM_TYPE ?=
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
all: fpga

fpga: $(BPREFIX).bit

prj: $(BPREFIX).xpr
	$(VIVADO) $(VIVADO_OPTS) $(BPREFIX).xpr

clean:
	rm -rf $(WORK_DIR)

###################################################################
# Target implementations
###################################################################

# Vivado project file
$(WORK_DIR)/create_project.tcl: makefile $(XCI_FILES) $(IP_TCL_FILES)
	mkdir -p $(WORK_DIR)
	rm -rf $(WORK_DIR)/defines.v
	touch $(WORK_DIR)/defines.v
	for x in $(DEFS); do 
		echo '`define' 
		$$x >> $(WORK_DIR)/defines.v
	done
	@cat << EOF > $@
		create_project -force -part $(XILINX_PART) $(PROJECT) $(WORK_DIR)
	EOF
	if [ "$(XILINX_BOARD)" ]; then echo "set_property board_part $(XILINX_BOARD) [current_project]" >> $@; fi
	if [ "$(RTL_FILES)" ]; then echo "add_files -fileset sources_1 $(RTL_FILES)" >> $@; fi
	if [ "$(XDC_FILES)" ]; then echo "add_files -fileset constrs_1 $(XDC_FILES)" >> $@; fi
	if [ "$(SIM_FILES)" ]; then echo "add_files -fileset sim_1 $(SIM_FILES)" >> $@; fi
	if [ "$(IP_REPO_PATHS)" ]; then
		echo "set_property ip_repo_paths [concat $(IP_REPO_PATHS)] [current_project]" >> $@; fi
	for x in $(XCI_FILES); 			do echo "import_ip $$x"	>> $@; done
	for x in $(IP_TCL_FILES); 		do echo "source $$x" 	>> $@; done
	for x in $(CONFIG_TCL_FILES); 	do echo "source $$x" 	>> $@; done
	for x in $(BD_TCL_FILES); 		do 
		echo "source $$x" 	>> $@;
		echo "make_wrapper -files [get_files [glob $(BPREFIX).srcs/sources_1/bd/**/*.bd]] -top" >> $@
		echo "add_files -fileset sources_1 [glob $(BPREFIX).gen/sources_1/bd/**/hdl/*wrapper.v]" >> $@
	done
	if [ "$(RTL_TOP)" ]; then echo "set_property top $(RTL_TOP) [get_filesets sources_1]" >> $@; fi
	if [ "$(SIM_TOP)" ]; then echo "set_property top $(SIM_TOP) [get_filesets sim_1]" >> $@; fi
	echo "exit" >> $@

$(WORK_DIR)/update_config.tcl: $(CONFIG_TCL_FILES) $(RTL_FILES) $(INC_FILES) $(XDC_FILES)
	mkdir -p $(WORK_DIR)
	echo "open_project -quiet $(BPREFIX).xpr" 			> $@
	for x in $(CONFIG_TCL_FILES); do echo "source $$x" >> $@; done

$(BPREFIX).xpr: $(WORK_DIR)/create_project.tcl $(WORK_DIR)/update_config.tcl
	mkdir -p $(WORK_DIR)	
	$(VIVADO) $(VIVADO_OPTS) $(foreach x,$?,-source $x)

# synthesis run
$(BPREFIX).runs/synth_1/$(PROJECT).dcp: $(WORK_DIR)/create_project.tcl $(WORK_DIR)/update_config.tcl \
	$(RTL_FILES) $(INC_FILES) $(XDC_FILES) | $(BPREFIX).xpr
	@cat << EOF > $(WORK_DIR)/run_synth.tcl
		open_project $(BPREFIX).xpr
		reset_run synth_1
		launch_runs -jobs 4 synth_1
		wait_on_run synth_1
		exit
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source $(WORK_DIR)/run_synth.tcl

# implementation run
$(BPREFIX).runs/impl_1/$(PROJECT)_routed.dcp: $(BPREFIX).runs/synth_1/$(PROJECT).dcp
	@cat << EOF > $(WORK_DIR)/run_impl.tcl
		open_project $(BPREFIX).xpr
		reset_run impl_1
		launch_runs -jobs 4 impl_1
		wait_on_run impl_1
		open_run impl_1
		report_utilization -file $(BPREFIX)_utilization.rpt
		report_utilization -hierarchical -file $(BPREFIX)_utilization_hierarchical.rpt
		exit
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source $(WORK_DIR)/run_impl.tcl

# bit file
$(BPREFIX).bit $(BPREFIX).ltx: $(BPREFIX).runs/impl_1/$(PROJECT)_routed.dcp
	@cat << EOF > $(WORK_DIR)/generate_bit.tcl
		open_project $(BPREFIX).xpr
		open_run impl_1
		write_bitstream -force $(BPREFIX).runs/impl_1/$(PROJECT).bit
		write_debug_probes -force $(BPREFIX).runs/impl_1/$(PROJECT).ltx
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source $(WORK_DIR)/generate_bit.tcl

	cp -pv $(BPREFIX).runs/impl_1/$(PROJECT).bit $(WORK_DIR)
	if [ -e $(BPREFIX).runs/impl_1/$(PROJECT).ltx ]; then 
		cp -pv $(BPREFIX).runs/impl_1/$(PROJECT).ltx $(WORK_DIR)
	fi

	mkdir -p $(WORK_DIR)/rev
	COUNT=100

	while [ -e $(WORK_DIR)/rev/$(PROJECT)_rev$$COUNT.bit ]; do 
		COUNT=$$((COUNT+1)) 
	done

	cp -pv $(BPREFIX).runs/impl_1/$(PROJECT).bit $(WORK_DIR)/rev/$(PROJECT)_rev$$COUNT.bit
	if [ -e $(BPREFIX).runs/impl_1/$(PROJECT).ltx ]; then 
		cp -pv $(BPREFIX).runs/impl_1/$(PROJECT).ltx $(WORK_DIR)/rev/$(PROJECT)_rev$$COUNT.ltx
	fi

config: $(BPREFIX).xpr
	make $<

synth: $(BPREFIX).runs/synth_1/$(PROJECT).dcp
	make $<

impl: $(BPREFIX).runs/synth_1/$(PROJECT).dcp
	make $<

program: $(WORK_DIR)/$(RTL_TOP).bit
	@cat << EOF > $(WORK_DIR)/program.tcl
		open_hw_manager
		connect_hw_server
		open_hw_target
		current_hw_device [lindex [get_hw_devices] 1]
		refresh_hw_device -update_hw_probes false [current_hw_device]  
		set_property PROGRAM.FILE {$<} [current_hw_device]
		program_hw_devices [current_hw_device]
		exit
	EOF
	@$(VIVADO) $(VIVADO_OPTS) -source $(WORK_DIR)/program.tcl

sim:
	@cat << EOF > $(WORK_DIR)/sim.tcl
		open_project $(BPREFIX).xpr
		launch_simulation $(SIM_OPTS)
		restart
		open_vcd wave.vcd
		log_vcd [get_objects -r *]
		run all
		close_vcd
		exit
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source $(WORK_DIR)/sim.tcl

%.mcs %.prm: %.bit
	@cat << EOF > $(WORK_DIR)/generate_mcs.tcl
		write_cfgmem -force -format mcs -size 128 -interface SPIx4 -loadbit {up 0x01002000 $*.bit} -checksum -file $*.mcs
		exit
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source $(WORK_DIR)/generate_mcs.tcl

	mkdir -p $(WORK_DIR)/rev
	COUNT=100
	while [ -e $(WORK_DIR)/rev/$*_rev$$COUNT.bit ]; do 
		COUNT=$$((COUNT+1)) 
	done
	COUNT=$$((COUNT-1))
	for x in .mcs .prm; do
		cp $*$$x $(WORK_DIR)/rev/$*_rev$$COUNT$$x
		echo "Output: $(WORK_DIR)/rev/$*_rev$$COUNT$$x" 
	done

ip_gen: $(BPREFIX).xpr
	@cat << EOF > $(WORK_DIR)/ip_gen.tcl
		open_project $(BPREFIX).xpr
		ipx::package_project -import_files -force -root_dir ../../ip_gen/$(RTL_TOP)

		# 设置 ip 属性和信息
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
	$(VIVADO) $(VIVADO_OPTS) -source $(WORK_DIR)/ip_gen.tcl

flash: $(WORK_DIR)/$(RTL_TOP).mcs $(WORK_DIR)/$(RTL_TOP).prm
	@cat << EOF > $(WORK_DIR)/flash.tcl
		open_hw
		connect_hw_server
		open_hw_target
		current_hw_device [lindex [get_hw_devices] 0]
		refresh_hw_device -update_hw_probes false [current_hw_device]
		create_hw_cfgmem -hw_device [current_hw_device] [lindex [get_cfgmem_parts {mt25qu01g-spi-x1_x2_x4}] 0]
		current_hw_cfgmem -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM [current_hw_device]]
		set_property PROGRAM.FILES [list \"$(WORK_DIR)/$(RTL_TOP).mcs\"] [current_hw_cfgmem]
		set_property PROGRAM.PRM_FILES [list \"$(WORK_DIR)/$(RTL_TOP).prm\"] [current_hw_cfgmem]
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
		exit
	EOF
	$(VIVADO) $(VIVADO_OPTS) -source flash.tcl
