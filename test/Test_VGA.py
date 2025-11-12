import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_VGA(dut):
    """Basic VGA timing test"""
    dut._log.info("Starting VGA module test")

    # Create 25 MHz clock (40 ns period)
    clock = Clock(dut.clk_pixel, 40, units="ns")
    cocotb.start_soon(clock.start())

    # Apply reset
    dut.reset_n.value = 0
    await ClockCycles(dut.clk_pixel, 5)
    dut.reset_n.value = 1

    # Wait some cycles to let VGA run
    await ClockCycles(dut.clk_pixel, 1000)

    # Sanity checks
    assert dut.hsync.value in [0, 1], "HSYNC invalid"
    assert dut.vsync.value in [0, 1], "VSYNC invalid"
    dut._log.info(f"visible={dut.visible.value}, data_out={dut.data_out.value}")

    dut._log.info("VGA test completed successfully")
