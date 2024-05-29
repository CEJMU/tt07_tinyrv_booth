#!/usr/bin/env python3

import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.binary import BinaryValue

mem = {
    0:  0b10010011100000000101000000000000,  # addi
    1:  0b00010011000000010010000000000000,  # addi
    2:  0b10110011000000010001000100000000,  # add
    3:  0b10110011010000100001000100000000,  # xor
    4:  0b00110011011100110001000100000000,  # and
    5:  0b10100011001001110011000000000000,  # sw
    6:  0b00000011001000101111000000000000,  # lw
    7:  0b11101111000000111000000000000000,  # jal x7, 8
    8:  0b10100011001001110000000000000000,  # sw 0 in mem[7]. This instruction should never execute
    9:  0b10010011000001000000000000000011,  # addi x9 = 12*4 = 48
    10: 0b01100111100000000000010000000000,  # jr x9
    11: 0b10100011001001110000000000000000,  # sw 0 in mem[7]. This instruction should never execute
    12: 0b01100011000000000001000000000000,  # bne endless
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
                # print(mosi)
                counter = 31

                # print("================")
                # print(addr)
                # print("================")

                if write:
                    state = "rx"
                    counter = 33
                else:
                    state = "tx"
                    # print("start neuer zyklus")

            else:
                # print(mosi)
                addr[15 - counter] = mosi.integer
                counter -= 1

        # Recv data
        elif state == "rx":
            if counter > 31:
                counter -= 1

            elif counter == 0:
                data[31 - counter] = mosi.integer
                state = "addr"

                mem[addr.integer] = data
            else:
                data[31 - counter] = mosi.integer
                counter -= 1

        # Trx data
        else:
            # print("addr trx: " + str(addr))
            if counter > 31:
                counter -= 1

            elif counter == 0:
                dut.ui_in.value = int(bin(mem[addr.integer])[2:].zfill(32)[31 - counter])
                # print(int(bin(mem[addr.integer])[2:].zfill(32)[31 - counter]))
                state = "addr"
            else:
                dut.ui_in.value = int(bin(mem[addr.integer])[2:].zfill(32)[31 - counter])
                # print(int(bin(mem[addr.integer])[2:].zfill(32)[31 - counter]))
                counter -= 1
    else:
        counter = 18
        addr = BinaryValue(0, 16)
        data = BinaryValue(0, 32)
        state = "addr"
        write = False


def reg(dut, addr, regs=None):
    start = addr*32
    end = start + 31
    # print("reg: ==========")
    # print(dut.top.cpu_inst.regs_inst.registers.value[start:end])
    # print("==========")
    if regs is None:
        return dut.top.cpu_inst.regs_inst.registers.value[start:end]
    else:
        return regs[start:end]


def i_add(dut, old_reg, rd, rs1, rs2):
    return reg(dut, rd) == reg(dut, rs1, old_reg) + reg(dut, rs2, old_reg)


def i_and(dut, rd, rs1, rs2):
    return reg(dut, rd) == reg(dut, rs1) & reg(dut, rs2)


def i_xor(dut, rd, rs1, rs2):
    return reg(dut, rd) == reg(dut, rs1) ^ reg(dut, rs2)


def i_sw(dut, rs1, rs2, imm):
    global mem
    print("sw: ================")
    print(mem)
    print("================")
    return mem[reg(dut, rs1) + imm] == to_little_endian(reg(dut, rs2))


def i_lw(dut, rd, rs1, imm):
    global mem
    print("lw: ================")
    print(mem)
    print("================")
    return to_little_endian(reg(dut, rd)) == mem[reg(dut, rs1) + imm]


def i_addi(dut, old_reg, rd, rs1, imm):
    print(reg(dut, rs1, old_reg))
    return reg(dut, rd) == reg(dut, rs1, old_reg) + imm


def i_jal(dut, rd, pc, pc_old, imm):
    return reg(dut, rd) == pc_old + 4 and pc == pc_old + imm


def i_jr(dut, pc, rs1):
    return pc == reg(dut, rs1)


def i_bne(dut, pc_old, rs1, rs2, imm):
    pc = dut.top.cpu_inst.instruction_inst.pc_new.value
    if not reg(dut, rs1) == reg(dut, rs2):
        return pc == pc_old + imm

    return pc == pc_old + 4


def to_little_endian(bits):
    return BinaryValue(str(bits[24:31]) + str(bits[16:23]) + str(bits[8:15]) + str(bits[0:7]))


async def test_instruction(dut, assertion, mem_access=False):
    while not dut.top.cpu_inst.control_inst.currstate.value == 5:
        await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    assert assertion()


@cocotb.test()
async def cpu_test_1(dut):
    global mem

    dut.ui_in.value = 0
    await cocotb.start(generate_clock(dut))

    # dut._log.info("my_signal_1 is %s", dut.data_out.value[0])
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1

    # for i in range(2):
    #     old_reg = copy.copy(dut.top.cpu_inst.regs_inst.registers.value)
    #     await test_instruction(dut, lambda: i_addi(dut, old_reg, 1, 1, 5))
    #     old_reg = copy.copy(dut.top.cpu_inst.regs_inst.registers.value)
    #     await test_instruction(dut, lambda: i_addi(dut, old_reg, 2, 0, 2))
    #     old_reg = copy.copy(dut.top.cpu_inst.regs_inst.registers.value)
    #     await test_instruction(dut, lambda: i_add(dut, old_reg, 3, 2, 1))
    #     await test_instruction(dut, lambda: i_sw(dut, 0, 3, 7))
    #     await test_instruction(dut, lambda: i_lw(dut, 4, 0, 7))
    #     pc_old = dut.top.cpu_inst.instruction_inst.pc_new.value
    #     await test_instruction(dut, lambda: i_bne(dut, pc_old, 1, 0, -20))

    for i in range(700):
        await RisingEdge(dut.clk)

    x1 = BinaryValue(0, 13, bigEndian=True)
    x1[8:12] = dut.uo_out.value[0:4].binstr
    x1[0:7] = dut.uio_out.value.binstr
    print(dut.uo_out.value[0:4])
    print(dut.uio_out.value)

    correct_mem = {
        0:  0b10010011100000000101000000000000,  # addi
        1:  0b00010011000000010010000000000000,  # addi
        2:  0b10110011000000010001000100000000,  # add
        3:  0b10110011010000100001000100000000,  # xor
        4:  0b00110011011100110001000100000000,  # and
        5:  0b10100011001001110011000000000000,  # sw
        6:  0b00000011001000101111000000000000,  # lw
        7:  0b11101111000000111000000000000000,  # jal x7, 8
        8:  0b10100011001001110000000000000000,  # sw 0 in mem[7]. This instruction should never execute
        9:  0b10010011000001000000000000000011,  # addi x9 = 12*4 = 48
        10: 0b01100111100000000000010000000000,  # jr x9
        11: 0b10100011001001110000000000000000,  # sw 0 in mem[7]. This instruction should never execute
        12: 0b01100011000000000001000000000000,  # bne endless
        15: 0b00000111000000000000000000000000
    }

    correct_x1 = 5

    # print("Mem: ")
    # print("{")
    # for addr, data in mem.items():
    #     print(f"\t{addr}: {data}")
    # print("}")
    #
    # print()
    # print("Regs: ")
    # for i in range(32):
    #     print(f"x{i}: {reg(dut, i).integer}")

    assert mem == correct_mem
    assert x1.integer == correct_x1
