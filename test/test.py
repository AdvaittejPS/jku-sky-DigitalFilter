# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start AI MAC Test")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test event-driven behavior")

    # 1. Send a non-zero event (e.g., 255)
    dut.ui_in.value = 255
    await ClockCycles(dut.clk, 1)

    # 2. Send zeros (Sparsity). The pipeline should freeze.
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 5)

    # Because the pipeline takes a few clock cycles to propagate,
    # and we froze it before the 255 could reach the end, the output 
    # should remain exactly what it was (0) during the freeze.
    assert dut.uo_out.value == 0
    
    dut._log.info("Sparsity freeze successful. Pipeline held state.")
