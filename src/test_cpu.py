#!/usr/bin/env python3

import cocotb
from cocotb.triggers import Timer, RisingEdge


async def generate_clock(dut, mem):
    """Generate clock pulses."""

    for cycle in range(1000):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1

        addr = int(dut.addr_out.value)
        if addr in mem:
            dut.data_in.value = mem[addr]
        else:
            dut.data_in.value = 0

        if dut.write_en == 1:
            mem[addr] = dut.data_out.value

        await Timer(1, units="ns")


def reg(dut, addr):
    return dut.regs_inst.registers.value[addr]


def i_add(dut, old_reg, rd, rs1, rs2):
    return reg(dut, rd) == old_reg[rs1] + old_reg[rs2]


def i_and(dut, rd, rs1, rs2):
    return reg(dut, rd) == reg(dut, rs1) & reg(dut, rs2)


def i_xor(dut, rd, rs1, rs2):
    return reg(dut, rd) == reg(dut, rs1) ^ reg(dut, rs2)


def i_sw(dut, mem, rs1, rs2, imm):
    return mem[reg(dut, rs1) + imm] == reg(dut, rs2)


def i_lw(dut, mem, rd, rs1, imm):
    return reg(dut, rd) == mem[reg(dut, rs1) + imm]


def i_addi(dut, old_reg, rd, rs1, imm):
    return reg(dut, rd) == old_reg[rs1] + imm


def i_jal(dut, rd, pc, pc_old, imm):
    return reg(dut, rd) == pc_old + 4 and pc == pc_old + imm


def i_jr(dut, pc, rs1):
    return pc == reg(dut, rs1)


def i_bne(dut, pc_old, rs1, rs2, imm):
    pc = dut.instruction_inst.pc_new.value
    if not reg(dut, rs1) == reg(dut, rs2):
        return pc == pc_old + imm

    return pc == pc_old + 4


async def test_instruction(dut, assertion, mem_access=False):
    while not dut.control_inst.currstate.value == 5:
        await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    assert assertion()


@cocotb.test()
async def cpu_test_1(dut):

    mem = {
        0: 0b00000000010100001000000010010011,
        1: 0b00000000001000000000000100010011,
        2: 0b00000000000100010000000110110011,
        3: 0b00000000001100000010001110100011,
        4: 0b00000000011100000010001000000011,
        5: 0b11111110000100000001011011100011,
    }

    await cocotb.start(generate_clock(dut, mem))

    # dut._log.info("my_signal_1 is %s", dut.data_out.value[0])
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    dut.reset.value = 0

    for i in range(2):
        old_reg = dut.regs_inst.registers.value.copy()
        await test_instruction(dut, lambda: i_addi(dut, old_reg, 1, 1, 5))
        old_reg = dut.regs_inst.registers.value.copy()
        await test_instruction(dut, lambda: i_addi(dut, old_reg, 2, 0, 2))
        old_reg = dut.regs_inst.registers.value.copy()
        await test_instruction(dut, lambda: i_add(dut, old_reg, 3, 2, 1))
        await test_instruction(dut, lambda: i_sw(dut, mem, 0, 3, 7))
        await test_instruction(dut, lambda: i_lw(dut, mem, 4, 0, 7))
        pc_old = dut.instruction_inst.pc_new.value
        await test_instruction(dut, lambda: i_bne(dut, pc_old, 1, 0, -20))
    # assert dut.my_signal_2.value[0] == 0, "my_signal_2[0] is not 0!"
    print(mem)
