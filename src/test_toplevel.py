#!/usr/bin/env python3

import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.binary import BinaryValue

mem = {
    0: 0b00000000010100001000000010010011,
    1: 0b00000000001000000000000100010011,
    2: 0b00000000000100010000000110110011,
    3: 0b00000000001100000010001110100011,
    4: 0b00000000011100000010001000000011,
    5: 0b11111110000100000001011011100011,
}

counter = 18
addr = BinaryValue(0, 16)
data = BinaryValue(0, 32)
state = "addr"
write = False


async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(1000):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1

        if cycle > 1:
            do_spi(dut)

        await Timer(1, units="ns")


def do_spi(dut):
    global mem
    global addr
    global data
    global state
    global write
    global counter

    # dut._log.info("my_signal_1 is %s", dut.uo_out.value[2])
    mosi = dut.uo_out.value[7]
    if dut.uo_out.value[5] == 0:
        # Recv address
        if state == "addr":
            if counter >= 16:
                if mosi == 1:
                    write = True
                else:
                    write = False

                counter -= 1
            elif counter == 0:
                addr[15 - counter] = mosi.integer
                print(mosi)
                counter = 31

                print("================")
                print(addr)
                print("================")

                if write:
                    state = "rx"
                    counter = 32
                else:
                    state = "tx"
            else:
                print(mosi)
                addr[15 - counter] = mosi.integer
                counter -= 1

        # Recv data
        elif state == "rx":
            if counter > 31:
                counter -= 1

            elif counter == 0:
                data[31 - counter] = mosi.integer
                state = "addr"
                counter = 18

                mem[addr.integer] = data
            else:
                data[31 - counter] = mosi.integer
                counter -= 1

        # Trx data
        else:
            if counter > 31:
                counter -= 1

            elif counter == 0:
                dut.ui_in.value = int(bin(mem[addr.integer])[2:].zfill(32)[31 - counter])
                state = "addr"
                counter = 18
            else:
                dut.ui_in.value = int(bin(mem[addr.integer])[2:].zfill(32)[31 - counter])
                counter -= 1
    else:
        counter = 18
        addr = BinaryValue(0, 16)
        data = BinaryValue(0, 32)
        state = "addr"
        write = False


def reg(dut, addr):
    return dut.cpu_inst.regs_inst.registers.value[addr]


def i_add(dut, old_reg, rd, rs1, rs2):
    return reg(dut, rd) == old_reg[rs1] + old_reg[rs2]


def i_and(dut, rd, rs1, rs2):
    return reg(dut, rd) == reg(dut, rs1) & reg(dut, rs2)


def i_xor(dut, rd, rs1, rs2):
    return reg(dut, rd) == reg(dut, rs1) ^ reg(dut, rs2)


def i_sw(dut, rs1, rs2, imm):
    global mem
    print("sw: ================")
    print(mem)
    print("================")
    return mem[reg(dut, rs1) + imm] == reg(dut, rs2)


def i_lw(dut, rd, rs1, imm):
    global mem
    print("lw: ================")
    print(mem)
    print("================")
    return reg(dut, rd) == mem[reg(dut, rs1) + imm]


def i_addi(dut, old_reg, rd, rs1, imm):
    return reg(dut, rd) == old_reg[rs1] + imm


def i_jal(dut, rd, pc, pc_old, imm):
    return reg(dut, rd) == pc_old + 4 and pc == pc_old + imm


def i_jr(dut, pc, rs1):
    return pc == reg(dut, rs1)


def i_bne(dut, pc_old, rs1, rs2, imm):
    pc = dut.cpu_inst.instruction_inst.pc_new.value
    if not reg(dut, rs1) == reg(dut, rs2):
        return pc == pc_old + imm

    return pc == pc_old + 4


async def test_instruction(dut, assertion, mem_access=False):
    while not dut.cpu_inst.control_inst.currstate.value == 5:
        await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    assert assertion()


@cocotb.test()
async def cpu_test_1(dut):
    dut.ui_in.value = 0
    await cocotb.start(generate_clock(dut))

    # dut._log.info("my_signal_1 is %s", dut.data_out.value[0])
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    dut.reset.value = 0

    for i in range(2):
        old_reg = dut.cpu_inst.regs_inst.registers.value.copy()
        await test_instruction(dut, lambda: i_addi(dut, old_reg, 1, 1, 5))
        old_reg = dut.cpu_inst.regs_inst.registers.value.copy()
        await test_instruction(dut, lambda: i_addi(dut, old_reg, 2, 0, 2))
        old_reg = dut.cpu_inst.regs_inst.registers.value.copy()
        await test_instruction(dut, lambda: i_add(dut, old_reg, 3, 2, 1))
        await test_instruction(dut, lambda: i_sw(dut, 0, 3, 7))
        await test_instruction(dut, lambda: i_lw(dut, 4, 0, 7))
        pc_old = dut.cpu_inst.instruction_inst.pc_new.value
        await test_instruction(dut, lambda: i_bne(dut, pc_old, 1, 0, -20))
