RTL_DIR   := $(PRJ_DIR)/rtl
RTL_TOP   := pm32
RTL_FILES := $(RTL_DIR)/demo.v
SIM_DIR   := $(PRJ_DIR)/sim
SIM_TOP   := tb_demo
SIM_FILES := $(SIM_DIR)/tb_demo.v

# other
VERILATOR_EXE := $(SIM_DIR)/tb_demo.cpp
VIVADO_XDC    := $(PRJ_DIR)/xdc/genesys2.xdc
