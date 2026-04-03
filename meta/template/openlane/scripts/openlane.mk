OPENLANE_DIR      := $(abspath $(BUILD_DIR))/$(PRJ_NAME)/openlane
OPENLANE_SAVE_DIR := $(abspath $(SAVE_DIR))/$(PRJ_NAME)

OPENLANE_RUNS_DIR    := $(OPENLANE_DIR)/runs
OPENLANE_SIGNOFF_DIR := $(OPENLANE_DIR)/signoff
OPENLANE_LIBS_DIR    := $(OPENLANE_DIR)/libs
OPENLANE_SYNTH_DIR   := $(OPENLANE_DIR)/net/synth
OPENLANE_LAYOUT_DIR  := $(OPENLANE_DIR)/net/layout

TAG      ?=
NEW_TAG  := $(shell date +%m-%d_%H-%M)
LAST_TAG := $(shell ls -t $(OPENLANE_RUNS_DIR) 2>/dev/null | head -n 1)

openlane:
ifeq ($(TAG),)
	python3 -m openlane --dockerized \
		--run-tag $(OPENLANE_RUNS_DIR)/$(NEW_TAG) \
		$(PRJ_DIR)/config.json
else
	python3 -m openlane --dockerized \
		--run-tag $(OPENLANE_RUNS_DIR)/$(TAG) \
		$(PRJ_DIR)/config.json
endif
.PHONY: openlane

openlane-save:
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

openlane-signoff:
	@echo "Copying Signing off folders..."
ifeq ($(TAG),)
	rm -rf $(OPENLANE_SIGNOFF_DIR)/$(LAST_TAG)
	@mkdir -p $(OPENLANE_SIGNOFF_DIR)/$(LAST_TAG)
	python3 scripts/signoff.py $(OPENLANE_RUNS_DIR)/$(LAST_TAG) $(OPENLANE_SIGNOFF_DIR)/$(LAST_TAG)
else
	rm -rf $(OPENLANE_SIGNOFF_DIR)/$(TAG)
	@mkdir -p $(OPENLANE_SIGNOFF_DIR)/$(TAG)
	python3 scripts/signoff.py $(OPENLANE_RUNS_DIR)/$(TAG) $(OPENLANE_SIGNOFF_DIR)/$(TAG)
endif
.PHONY: openlane-signoff

openlane-extract:
	@echo "Extracting nets & libs ..."
ifeq ($(TAG),)
	rm -rf $(OPENLANE_SIGNOFF_DIR)/$(LAST_TAG)
	@mkdir -p $(OPENLANE_SIGNOFF_DIR)/$(LAST_TAG)
	python3 scripts/extract.py $(OPENLANE_RUNS_DIR)/$(LAST_TAG) $(OPENLANE_DIR)
else
	rm -rf $(OPENLANE_SIGNOFF_DIR)/$(TAG)
	@mkdir -p $(OPENLANE_SIGNOFF_DIR)/$(TAG)
	python3 scripts/extract.py $(OPENLANE_RUNS_DIR)/$(TAG) $(OPENLANE_DIR)
endif
.PHONY: openlane-extract

openlane-clean:
	rm -rf $(OPENLANE_DIR)
.PHONY: openlane-clean

openlane-clean-save:
	rm -rf $(OPENLANE_SAVE_DIR)
.PHONY: openlane-clean-save
