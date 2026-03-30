RTL_SOURCES = rtl/MiniRVSOC.sv vsrc/dpi.v
SC_MAIN = csrc/minirv.cpp
VTOP = MiniRVSOC
VERILATOR = verilator
CXX = g++

# 目标文件目录
BUILD_DIR := build
VBUILD    := $(BUILD_DIR)/obj_dir
VLIB      := $(VBUILD)/libV$(VTOP).a
VROOT     := /usr/local/share/verilator
VINC      := -I$(VROOT)/include -I$(VROOT)/include/vltstd

# 第一步：只编译RTL生成静态库
$(VBUILD)/V$(VTOP).mk: $(RTL_SOURCES)
	@mkdir -p $(dir $@)
	$(VERILATOR) --cc --trace-fst --top-module $(VTOP) \
		-Mdir $(VBUILD) $(RTL_SOURCES)
	$(MAKE) -C $(VBUILD) -f V$(VTOP).mk

$(VLIB): $(VBUILD)/V$(VTOP).mk
	@$(MAKE) -C $(VBUILD) -f V$(VTOP).mk
	@ar rcs $@ $(VBUILD)/*.o

# 第二步：链接RTL库和sc_main
sim: $(VLIB) $(SC_MAIN)
	@mkdir -p $(dir $@)
	$(CXX) -I$(VBUILD) $(VINC) \
		$(SC_MAIN) $(VLIB) -o $(BUILD_DIR)/sim -lz

# 第三步：运行
run: sim
	$(BUILD_DIR)/sim

# 只重新编译RTL
rtl_only: $(RTL_SOURCES)
	$(VERILATOR) --cc --exe --top-module $(VTOP) \
		-Mdir $(VBUILD) --build \
		-CFLAGS "-fPIC" $(RTL_SOURCES) dummy.cpp

clean_rtl:
	rm -rf $(VBUILD)

clean:
	rm -rf $(BUILD_DIR)
