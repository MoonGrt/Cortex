#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vtb_demo.h"

int main(int argc, char **argv, char **env) {
    Verilated::commandArgs(argc, argv);

    // 创建 DUT
    Vtb_demo* top = new Vtb_demo;

    // 打开 trace
    Verilated::traceEverOn(true);  // 必须先打开 trace
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);  // 99 是 trace 层级，通常够用
    const char* path = getenv("VERILATE_WAVE");
    // printf("path = %s\n", path ? path : "(null)");
    tfp->open(path ? path : "wave.vcd"); // 输出 VCD 文件

    // 开始仿真
    while (!Verilated::gotFinish()) {
        // printf("main_time = %lld\n", Verilated::time());
        top->eval();
        // 每个时钟周期或者每次 eval 后 dump 时间
        tfp->dump(Verilated::time());
        Verilated::timeInc(1);
    }

    // 关闭 trace
    tfp->close();
    delete tfp;
    delete top;
    return 0;
}