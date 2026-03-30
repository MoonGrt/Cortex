BUILD_TOOL ?= mill
RTL_DIR = rtl

ifeq ($(BUILD_TOOL), mill)
	RUN_MAIN = mill -i spinal.runMain demo.DemoVerilog
	CLEAN_CMD = -mill clean
else ifeq ($(BUILD_TOOL), sbt)
	RUN_MAIN = sbt "runMain demo.DemoVerilog"
	CLEAN_CMD = -sbt clean
else
$(error Unsupported BUILD_TOOL=$(BUILD_TOOL))
endif

rtl:
	mkdir -p $(RTL_DIR)
	$(RUN_MAIN)

clean:
	-rm -rf $(RTL_DIR)

clean-all:
	-rm -rf $(RTL_DIR)
	$(CLEAN_CMD)

.PHONY: test rtl help clean clean-all
