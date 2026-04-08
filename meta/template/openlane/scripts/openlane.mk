OPENLANE_DIR      := $(abspath $(BUILD_DIR))/$(PRJ_NAME)/openlane
OPENLANE_SAVE_DIR := $(abspath $(SAVE_DIR))/$(PRJ_NAME)

OPENLANE_RUNS_DIR    := $(OPENLANE_DIR)/runs
OPENLANE_SIGNOFF_DIR := $(OPENLANE_DIR)/signoff
OPENLANE_LIBS_DIR    := $(OPENLANE_DIR)/libs
OPENLANE_SYNTH_DIR   := $(OPENLANE_DIR)/nets/synth
OPENLANE_LAYOUT_DIR  := $(OPENLANE_DIR)/nets/layout

TAG      ?=
NEW_TAG  := $(shell date +%m-%d_%H-%M)
LAST_TAG := $(shell ls -t $(OPENLANE_RUNS_DIR) 2>/dev/null | head -n 1)

OPENLANE ?= python3 -m openlane --dockerized
OPENLANE_CONFIG ?= $(PRJ_DIR)/config.json
$(OPENLANE_RUNS_DIR)/$(LAST_TAG):$(OPENLANE_CONFIG)
ifeq ($(TAG),)
	$(OPENLANE) $(OPENLANE_CONFIG) \
		--run-tag $(OPENLANE_RUNS_DIR)/$(NEW_TAG)
else
	$(OPENLANE) $(OPENLANE_CONFIG) \
		--run-tag $(OPENLANE_RUNS_DIR)/$(TAG)
endif
openlane: $(OPENLANE_RUNS_DIR)/$(LAST_TAG)
.PHONY: openlane

DOT ?= coarse
ifeq ($(DOT),coarse)
DOT_FILE := hierarchy.dot
else
DOT_FILE := primitive_techmap.dot
endif
XDOT ?= xdot
openlane-plot: $(OPENLANE_RUNS_DIR)/$(LAST_TAG) $(OPENLANE_RUNS_DIR)/$(TAG)
	@echo "Plotting view ..."
ifeq ($(TAG),)
	$(XDOT) $(wildcard $(OPENLANE_RUNS_DIR)/$(LAST_TAG)/*-yosys-synthesis)/$(DOT_FILE)
else
	$(XDOT) $(wildcard $(OPENLANE_RUNS_DIR)/$(TAG)/*-yosys-synthesis)/$(DOT_FILE)
endif
.PHONY: openlane-plot

LAYOUT ?= klayout
ifeq ($(LAYOUT),klayout)
LAYOUT_FLAGS := --flow openinklayout
else
LAYOUT_FLAGS := --flow openinopenroad
endif
openlane-layout: $(OPENLANE_RUNS_DIR)/$(LAST_TAG) $(OPENLANE_RUNS_DIR)/$(TAG)
	@echo "Displaying layout ..."
ifeq ($(TAG),)
	python3 -m openlane --dockerized $(OPENLANE_CONFIG) --run-tag $(OPENLANE_RUNS_DIR)/$(LAST_TAG) $(LAYOUT_FLAGS)
else
	python3 -m openlane --dockerized $(OPENLANE_CONFIG) --run-tag $(OPENLANE_RUNS_DIR)/$(TAG) $(LAYOUT_FLAGS)
endif
.PHONY: openlane-layout

openlane-save: $(OPENLANE_RUNS_DIR)/$(LAST_TAG) $(OPENLANE_RUNS_DIR)/$(TAG)
	@echo "Saving view ..."
ifeq ($(TAG),)
	rm -rf  $(OPENLANE_SAVE_DIR)/$(LAST_TAG)
	@mkdir -p $(OPENLANE_SAVE_DIR)/$(LAST_TAG)
	cp -r $(OPENLANE_RUNS_DIR)/$(LAST_TAG)/final $(OPENLANE_SAVE_DIR)/$(LAST_TAG)
else
	rm -rf $(OPENLANE_SAVE_DIR)/$(TAG)
	@mkdir -p $(OPENLANE_SAVE_DIR)/$(TAG)
	cp -r $(OPENLANE_RUNS_DIR)/$(TAG)/final $(OPENLANE_SAVE_DIR)/$(TAG)
endif
.PHONY: openlane-save

ifeq ($(TAG),)
TAG_DIR := $(OPENLANE_RUNS_DIR)/$(LAST_TAG)
SIGNOFF_DIR := $(OPENLANE_SIGNOFF_DIR)/$(LAST_TAG)
else
TAG_DIR := $(OPENLANE_RUNS_DIR)/$(TAG)
SIGNOFF_DIR := $(OPENLANE_SIGNOFF_DIR)/$(TAG)
endif
SIGNOFF_TARGETS := magic-drc klayout-drc netgen-lvs openroad-stapostpnr openroad-checkantennas-1 final
openlane-signoff: $(OPENLANE_RUNS_DIR)/$(LAST_TAG) $(OPENLANE_RUNS_DIR)/$(TAG)
	@echo "Running signoff ..."
	@mkdir -p $(SIGNOFF_DIR)
	@$(foreach target,$(SIGNOFF_TARGETS), \
	    $(eval MATCHED := $(wildcard $(TAG_DIR)/*-$(target) $(TAG_DIR)/$(target))) \
	    $(if $(MATCHED), \
	        echo "Copying: $(notdir $(MATCHED)) -> $(SIGNOFF_DIR)"; \
	        rm -rf $(SIGNOFF_DIR)/$(notdir $(MATCHED)); \
	        cp -r $(MATCHED) $(SIGNOFF_DIR)/; \
	    , \
	        echo "Warning: no directory found for *-$(target)"; \
	    ) \
	)
.PHONY: openlane-signoff

openlane-extract: $(OPENLANE_RUNS_DIR)/$(LAST_TAG) $(OPENLANE_RUNS_DIR)/$(TAG)
	@echo "Extracting nets & libs ..."
ifeq ($(TAG),)
	python3 scripts/extract.py $(OPENLANE_RUNS_DIR)/$(LAST_TAG) $(OPENLANE_DIR)
else
	python3 scripts/extract.py $(OPENLANE_RUNS_DIR)/$(TAG) $(OPENLANE_DIR)
endif
.PHONY: openlane-extract

openlane-clean:
	rm -rf $(OPENLANE_DIR)
.PHONY: openlane-clean

openlane-clean-save:
	rm -rf $(OPENLANE_SAVE_DIR)
.PHONY: openlane-clean-save
