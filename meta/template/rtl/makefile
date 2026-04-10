ICD_DIR   := icd
PRJ_NAME  := demo
PRJ_DIR   := $(ICD_DIR)/$(PRJ_NAME)
BUILD_DIR := build
PRJ_BUILD_DIR := $(BUILD_DIR)/$(PRJ_NAME)
SAVE_DIR  := save

# top-level module
SIM_TOP ?= tb_demo
RTL_TOP ?= pm32
# behavioral post-synthesis post-layout
SIM_MODE ?= behavioral
# functional timing
SIM_TYPE ?=

include $(PRJ_DIR)/config.mk
include scripts/openlane.mk
include scripts/verilate.mk
include scripts/vcs.mk
include scripts/vivado.mk

clean-prj:
	rm -rf $(BUILD_DIR)
.PHONY: clean-prj

clean-all:
	rm -rf $(BUILD_DIR)
.PHONY: clean-all
