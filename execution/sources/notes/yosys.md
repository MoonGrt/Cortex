---
type: [note]
tags: [EDA] [yosys] [sv2v]
---

`show`: `sudo apt-get update && sudo apt-get install -y xdot`

`test/yosys` 文件夹中:
```bash
yosys alu.v
```
```yosys
# Step1 细化(Elaboration)
# 细化阶段的工作包括解析模块间的实例化关系, /
# 计算模块实例的参数, 完成模块实例化的实例名和端口绑定等.
hierarchy -check -top alu
# 可视化
show

# Step2 粗粒度综合(Coarse-grain synthesis)
# 采用字级单元(word-level cells)来描述设计:
# $add, $and, $or, $not, $mux, $mem, $dff, $latch, $sr ...
proc; opt; fsm; opt; memory; opt
# 可视化
show

# Step3 细粒度综合(Fine-grain synthesis)
techmap; opt
# 可视化
show

# Step4 写出中间网表
write_verilog alu.rtlil

# Step5 工艺映射(Technology mapping)
# 工艺映射是指从工艺无关的电路表示映射到具体工艺的实现.
dfflibmap -liberty cell.lib
read_liberty -lib cell.lib
# 可视化
show
abc -liberty cell.lib
# 可视化
show

# Step6 网表和报告生成
write_verilog alu.netlist
stat -liberty cell.lib
```

### sv2v

#### Installation

```bash
wget https://github.com/zachjs/sv2v/releases/download/v0.0.13/sv2v-Linux.zip
unzip sv2v-Linux.zip
sudo mv sv2v-Linux/sv2v /usr/local/bin/
rm -rf sv2v-Linux*
```

#### Usage

[用 sv2v+yosys 把 fpnew 转为 verilog 网表](https://jia.je/hardware/2022/03/30/sv2v-fpnew/)

```bash
# verilator 进行预处理 (把一堆 sv 文件合成一个)
cat a.sv b.sv c.sv > test.sv
verilator -E test.sv > merged.sv
# sed 去掉行号信息
sed -i '/^`line/d' merged.sv
# sv2v 转换
sv2v merged.sv > merge.v
# sed 去掉 $fatal 
sed -i '/\$$fatal/d' merge.v
# yosys 处理
yosys -p 'read_verilog -defer merge.v' -p 'hierarchy -p fpnew_top' -p 'proc' -p 'opt' -p 'write_verilog -noattr output.v'
```

> 注意这里要用 read_verilog -defer
> 否则 yosys 会遇到 TAG_WIDTH=0 默认参数就直接例化，然后就会出现 [0:-1]。
