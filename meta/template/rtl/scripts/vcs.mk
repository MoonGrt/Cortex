# make vcs-run SIM_MODE=post-layout SIM_TYPE=timing VCS_MODE=gui

VCS       := vcs
VCS_MODE  ?=
VCS_DIR   := $(abspath $(PRJ_BUILD_DIR))/vcs
VCS_FLAGS := -full64 +vc +v2k -sverilog -debug_all +librescan

VCS_SIM_DIR := $(SIM_DIR)
ifeq ($(SIM_MODE),behavioral)
    SIM_TYPE := functional
    VCS_SRC_DIR := $(RTL_DIR)
else ifeq ($(SIM_MODE),post-synthesis)
    VCS_SRC_DIR := $(abspath $(OPENLANE_SYNTH_DIR))
    VCS_LIB_DIR := $(abspath $(OPENLANE_LIBS_DIR))
    VCS_SDF_FILE ?= $(abspath $(OPENLANE_LAYOUT_DIR)/sdf/max_ff_n40C_1v95/pm32__max_ff_n40C_1v95.sdf)
else ifeq ($(SIM_MODE),post-layout)
    VCS_SRC_DIR := $(abspath $(OPENLANE_LAYOUT_DIR))
    VCS_LIB_DIR := $(abspath $(OPENLANE_LIBS_DIR))
    VCS_SDF_FILE ?= $(abspath $(OPENLANE_LAYOUT_DIR)/sdf/max_ff_n40C_1v95/pm32__max_ff_n40C_1v95.sdf)
else
    $(error Unknown SIM_MODE $(SIM_MODE), supported modes: "behavioral" "post-synthesis" "post-layout")
endif

VCS_DEFINES := +define+FUNCTIONAL +define+UNIT_DELAY=\#0
ifeq ($(SIM_TYPE),functional)
else ifeq ($(SIM_TYPE),timing)
	VCS_FLAGS += +neg_tchk -negdelay -sdf max:$(RTL_TOP):$(VCS_SDF_FILE)
else
    $(error Unknown SIM_TYPE $(SIM_TYPE), supported types: "functional" "timing")
endif

ifeq ($(VCS_MODE),gui)
    SIMV := simv -gui
else
    SIMV := simv
endif

FILE_LIST := $(VCS_DIR)/file_list.f
filelist:
	mkdir -p $(VCS_DIR)
	@echo "Generating file list in $(FILE_LIST)"
	@echo "Testbench: $(VCS_SIM_DIR)"
	@find $(VCS_SIM_DIR) -name '*.v' > $(FILE_LIST)
	@echo "Source: $(VCS_SRC_DIR)"
	@find $(VCS_SRC_DIR) -name '*.v' >> $(FILE_LIST)
ifneq ($(VCS_LIB_DIR),)
	@echo "Library: $(VCS_LIB_DIR)"
	@find $(VCS_LIB_DIR) -name '*.v' | sed '/\/primitives\.v$$/!s/^/-v /' >> $(FILE_LIST)
endif

VCS_TARGET := $(VCS_DIR)/simv
$(VCS_TARGET): filelist
	@echo "\033[33m SIM_MODE = $(SIM_MODE), SIM_TYPE=$(SIM_TYPE)\033[0m"
	tcsh -c "source scripts/synopsys_cshrc; \
	          cd $(VCS_DIR); \
	          $(VCS) $(VCS_FLAGS) $(VCS_DEFINES) \
	            -top $(SIM_TOP) \
	            -f $(FILE_LIST) \
	            -l compile.log"
vcs: $(VCS_TARGET)
.PHONY: vcs

vcs-run: $(VCS_TARGET)
	@echo "\033[33m SIM_MODE = $(SIM_MODE), SIM_TYPE=$(SIM_TYPE)\033[0m"
	tcsh -c "source scripts/synopsys_cshrc; \
	          cd $(VCS_DIR); \
	          $(SIMV)"
.PHONY: vcs-run

vcs-clean:
	rm -rf $(VCS_DIR)
.PHONY: vcs-clean
