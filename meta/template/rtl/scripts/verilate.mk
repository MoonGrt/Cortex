VERILATOR := verilator
GTKWARE   := gtkwave
CXX       := g++

VERILATE_DIR    := $(abspath $(PRJ_BUILD_DIR))/verilate
VERILATE_TARGET := $(VERILATE_DIR)/$(PRJ_NAME)
VERILATE_WAVE   := $(VERILATE_DIR)/$(PRJ_NAME).vcd

ifeq ($(SIM_MODE), behavioral)
VSRCS := $(RTL_FILES)
else

VSRCS := $(shell find $(OPENLANE_LIBS_DIR) -type f -name "*.v")
ifeq ($(SIM_MODE), post-synthesis)
VSRCS += $(shell find $(OPENLANE_SYNTH_DIR) -type f -name "*.v")
else ifeq ($(SIM_MODE), post-layout)
VSRCS += $(shell find $(OPENLANE_LAYOUT_DIR) -type f -name "*.v")
else
$(error Unknown SIM_MODE)
endif

endif

VSRCS += $(SIM_FILES)
CSRCS := $(VERILATOR_EXE)

VBUILD := $(VERILATE_DIR)/obj_dir
VLIB   := $(VBUILD)/libV$(SIM_TOP).a
VROOT  := /usr/local/share/verilator
VINC   := -I$(VROOT)/include -I$(VROOT)/include/vltstd

VERILATOR_ARGS := -Wno-fatal
# VERILATOR_ARGS := -Wall
$(VBUILD)/V$(SIM_TOP).mk: $(VSRCS)
	@echo "---------------------- Verilator ----------------------"
	mkdir -p $(dir $@)
	$(VERILATOR) --timing --cc --trace --top-module $(SIM_TOP) \
		-DFUNCTIONAL -DUNIT_DELAY=\#0 \
		$(VERILATOR_ARGS) \
		-Mdir $(VBUILD) $(VSRCS) -j$(nproc)
	$(MAKE) -C $(VBUILD) -f V$(SIM_TOP).mk

$(VLIB): $(VBUILD)/V$(SIM_TOP).mk
	@$(MAKE) -C $(VBUILD) -f V$(SIM_TOP).mk
	@ar rcs $@ $(VBUILD)/*.o

$(VERILATE_TARGET): $(VLIB) $(CSRCS)
	@echo "---------------------- Simulation ----------------------"
	@mkdir -p $(dir $@)
	$(CXX) -I$(VBUILD) $(VINC) \
		$(CSRCS) $(VLIB) -o $@
verilate: $(VERILATE_TARGET)

$(VERILATE_WAVE): $(VERILATE_TARGET)
	@echo "\033[33m>>> Build SIM_MODE = $(SIM_MODE)\033[0m"
	VERILATE_WAVE=$@ $(VERILATE_TARGET)
verilate-run: $(VERILATE_WAVE)
.PHONY: verilate-run

verilate-wave: $(VERILATE_WAVE)
	$(GTKWARE) $(VERILATE_WAVE) &
.PHONY: verilate-wave

verilate-clean:
	rm -rf $(VERILATE_DIR)
.PHONY: verilate-clean
