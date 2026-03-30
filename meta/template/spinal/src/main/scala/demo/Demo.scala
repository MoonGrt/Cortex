package demo

import spinal.core._
import spinal.core.sim._

object Config {
  def spinal = SpinalConfig(
    targetDirectory = "rtl",
    defaultConfigForClockDomains = ClockDomainConfig(
      resetActiveLevel = HIGH
    ),
    onlyStdLogicVectorAtTopLevelIo = false
  )
  def sim = SimConfig.withConfig(spinal).withFstWave
}

case class Demo() extends Component {
  val io = new Bundle {
    val cond0 = in  Bool()
    val cond1 = in  Bool()
    val flag  = out Bool()
    val state = out UInt(8 bits)
  }
  val counter = Reg(UInt(8 bits)) init 0
  when(io.cond0) { counter := counter + 1 }
  io.state := counter
  io.flag := (counter === 0) | io.cond1
}

object DemoVerilog extends App {
  Config.spinal.generateVerilog(Demo())
}

object DemoVhdl extends App {
  Config.spinal.generateVhdl(Demo())
}
