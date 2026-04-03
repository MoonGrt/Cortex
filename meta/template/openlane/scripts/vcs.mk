# vcs.mk

VCS_DIR := $(abspath $(BUILD_DIR))/$(PRJ_NAME)/vcs

# 创建 VCS_DIR
$(VCS_DIR):
	mkdir -p $(VCS_DIR)

# 根据 SIM_MODE 和 SIM_TYPE 设置输入目录和 testbench
ifeq ($(SIM_MODE),behavioral)
    VCS_INPUT_DIR := $(OPENLANE_RTL_DIR)
    TB := tb_demo
else ifeq ($(SIM_MODE),post-synthesis)
    VCS_INPUT_DIR := $(OPENLANE_SYNTH_DIR)
    ifeq ($(SIM_TYPE),functional)
        TB := tb_demo
    else ifeq ($(SIM_TYPE),timing)
        TB := tb_demo_timing
    endif
else ifeq ($(SIM_MODE),post-layout)
    VCS_INPUT_DIR := $(OPENLANE_LAYOUT_DIR)
    ifeq ($(SIM_TYPE),functional)
        TB := tb_demo
    else ifeq ($(SIM_TYPE),timing)
        TB := tb_demo_timing
    endif
else
    $(error Unknown SIM_MODE $(SIM_MODE))
endif

# file_list.f 路径
FILE_LIST := $(VCS_DIR)/file_list.f

# 自动生成 file_list.f
$(FILE_LIST): $(VCS_DIR)
	@echo "Generating file list in $(FILE_LIST)"
	@find $(VCS_INPUT_DIR) -name '*.v' > $(FILE_LIST)

# VCS 编译规则
vcs: $(FILE_LIST)
	@echo "SIM_MODE=$(SIM_MODE), SIM_TYPE=$(SIM_TYPE)"
	@echo "Input directory: $(VCS_INPUT_DIR)"
	@echo "Testbench: $(TB)"
	# 使用 tcsh source synopsys_cshrc，并在 VCS_DIR 下生成所有中间文件
	@tcsh -c "cd $(VCS_DIR); \
	           source ../../scripts/synopsys_cshrc; \
	           vcs -full64 -sverilog -debug_pp \
	           -f $(FILE_LIST) \
	           -top $(TB) \
	           -o simv \
	           -Mdir=$(VCS_DIR)/csrc"

.PHONY: vcs