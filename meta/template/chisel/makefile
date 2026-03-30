BUILD_TOOL ?= mill
RTL_DIR = rtl

ifeq ($(BUILD_TOOL), mill)
	RUN_TEST = mill -i chisel.test
	RUN_MAIN = mill -i chisel.runMain demo.GCD --target-dir $(RTL_DIR)
	HELP_CMD = mill --help
	CLEAN_CMD = -mill clean
else ifeq ($(BUILD_TOOL), sbt)
	RUN_TEST = sbt test
	RUN_MAIN = sbt "runMain demo.GCD --target-dir $(RTL_DIR)"
	HELP_CMD = sbt help
	CLEAN_CMD = -sbt clean
else
$(error Unsupported BUILD_TOOL=$(BUILD_TOOL))
endif

test:
	$(RUN_TEST)

rtl:
	mkdir -p $(RTL_DIR)
	$(RUN_MAIN)

help:
	$(HELP_CMD)

clean:
	-rm -rf $(RTL_DIR)

clean-all:
	-rm -rf $(RTL_DIR)
	$(CLEAN_CMD)

.PHONY: test rtl help clean clean-all
