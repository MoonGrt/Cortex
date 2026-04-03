BUILD_DIR := build
SAVE_DIR  := save
ICD_DIR   := icd
PRJ_NAME  := demo
PRJ_DIR   := $(ICD_DIR)/$(PRJ_NAME)

# behavioral post-synthesis post-layout
SIM_MODE ?= behavioral
# functional timing
SIM_TYPE ?=

include scripts/openlane.mk
include scripts/verilate.mk
include scripts/vcs.mk

clean-all:
	rm -rf $(BUILD_DIR)
.PHONY: clean-all
