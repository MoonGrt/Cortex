VERILATOR := verilator
GTKWARE   := gtkwave
CXX       := g++

VERILATE_DIR    := $(abspath $(BUILD_DIR))/$(PRJ_NAME)/verilate
VERILATE_TARGET := $(VERILATE_DIR)/sim
VERILATE_WAVE   := $(VERILATE_DIR)/wave.vcd

ifeq ($(SIM_MODE), behavioral)
VTOP ?= tb_demo
VSRCS := $(shell find $(PRJ_DIR)/rtl -type f -name "*.v")
else

VSRCS := $(shell find $(OPENLANE_LIBS_DIR)/rtl -type f -name "*.v")
ifeq ($(SIM_MODE), post-synthesis)
VSRCS += $(shell find $(OPENLANE_SYNTH_DIR)/rtl -type f -name "*.v")
else ifeq ($(SIM_MODE), post-layout)
VSRCS += $(shell find $(OPENLANE_LAYOUT_DIR)/rtl -type f -name "*.v")
else
$(error Unknown SIM_MODE)
endif

$(error Unknown SIM_MODE)
endif

VSRCS += $(shell find $(PRJ_DIR)/sim -type f -name "*.v")
CSRCS := $(shell find $(PRJ_DIR)/sim -type f -name "*.cpp")

VBUILD := $(VERILATE_DIR)/obj_dir
VLIB   := $(VBUILD)/libV$(VTOP).a
VROOT  := /usr/local/share/verilator
VINC   := -I$(VROOT)/include -I$(VROOT)/include/vltstd

VERILATOR_ARGS := -Wno-fatal
# VERILATOR_ARGS := -Wall
$(VBUILD)/V$(VTOP).mk: $(VSRCS)
	@echo "---------------------- Verilator ----------------------"
	mkdir -p $(dir $@)
	$(VERILATOR) --timing --cc --trace --top-module $(VTOP) \
		-DFUNCTIONAL -DUNIT_DELAY=\#0 \
		$(VERILATOR_ARGS) \
		-Mdir $(VBUILD) $(VSRCS) -j$(nproc)
	$(MAKE) -C $(VBUILD) -f V$(VTOP).mk

$(VLIB): $(VBUILD)/V$(VTOP).mk
	@$(MAKE) -C $(VBUILD) -f V$(VTOP).mk
	@ar rcs $@ $(VBUILD)/*.o

$(VERILATE_TARGET): $(VLIB) $(CSRCS)
	@echo "---------------------- Simulation ----------------------"
	@mkdir -p $(dir $@)
	$(CXX) -I$(VBUILD) $(VINC) \
		$(CSRCS) $(VLIB) -o $@
verilate-sim: $(VERILATE_TARGET)

$(VERILATE_WAVE): $(VERILATE_TARGET)
	@echo "\033[33m>>> Build SIM_MODE = $(SIM_MODE)\033[0m"
	VERILATE_WAVE=$@ $(VERILATE_TARGET)
verilate-run: $(VERILATE_WAVE)

verilate-wave: $(VERILATE_WAVE)
	$(GTKWARE) $(VERILATE_WAVE) &
.PHONY: verilate-wave

clean-verilate:
	rm -rf $(VERILATE_DIR)
.PHONY: clean-verilate
