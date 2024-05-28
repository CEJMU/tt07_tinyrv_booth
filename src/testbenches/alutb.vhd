library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.commons.all;
use work.constants.all;

entity alutb is
end entity;

architecture rtl of alutb is

  signal clk : std_logic := '0';
  signal reset : std_logic := '0';
  signal a : std_logic_vector(31 downto 0) := (others => '0');
  signal b : std_logic_vector(31 downto 0) := (others => '0');
  signal instruction : std_logic_vector(16 downto 0) := (others => '0');
  signal rd : std_logic_vector(31 downto 0) := (others => '0');

  signal finished : std_logic := '0';

  type alutest_vector is record
    instruction : std_logic_vector(16 downto 0);
    -- in
    a : std_logic_vector(31 downto 0);
    b : std_logic_vector(31 downto 0);
    -- out
    rd : std_logic_vector(31 downto 0);
  end record;

  type alutest_vector_array is array (natural range <>) of alutest_vector;
  constant test_vectors : alutest_vector_array := (
    --  instr       a            b                rd
    (INST_ADD, x"00000001", x"00000100", x"00000101"),  -- ADD normal
    (INST_ADD, x"0001E692", x"00000856", x"0001EEE8"),
    (INST_ADD, x"9B342A10", x"B12BD999", x"4C6003A9"),
    (INST_ADDI, x"FFFFFFFF", x"00000001", x"00000000"),  -- ADDI with overflow
    (INST_ADDI, x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFE"),  -- ADDI with negative numbers
    (INST_ADDI, x"0001E692", x"FFFFF856", x"0001DEE8"),  -- ADDI with negative numbers

    (INST_AND, x"FFF0FFFF", x"0FFFFFFF", x"0FF0FFFF"),  -- AND normal
    (INST_AND, x"00000000", x"0FCAF92F", x"00000000"),  -- AND normal
    (INST_AND, x"A912BC4F", x"000AB142", x"0002B042"),  -- AND normal
    (INST_ANDI, x"FFF0FFFF", x"0FFFFFFF", x"0FF0FFFF"),  -- AND normal
    (INST_ANDI, x"00000000", x"0FCAF92F", x"00000000"),  -- AND normal
    (INST_ANDI, x"A912BC4F", x"000AB142", x"0002B042"),  -- AND normal

    (INST_OR, x"FFF0FFFF", x"0FFFFFFF", x"FFFFFFFF"),  -- OR normal
    (INST_OR, x"00000000", x"0FCAF92F", x"0FCAF92F"),  -- OR normal
    (INST_OR, x"A912BC4F", x"000AB142", x"A91ABD4F"),  -- OR normal
    (INST_ORI, x"FFF0FFFF", x"0FFFFFFF", x"FFFFFFFF"),  -- OR normal
    (INST_ORI, x"00000000", x"0FCAF92F", x"0FCAF92F"),  -- OR normal
    (INST_ORI, x"A912BC4F", x"000AB142", x"A91ABD4F"),  -- OR normal

    (INST_XOR, x"FFF0FFFF", x"0FFFFFFF", x"F00F0000"),  -- XOR normal
    (INST_XOR, x"00000000", x"0FCAF92F", x"0FCAF92F"),  -- XOR normal
    (INST_XOR, x"A912BC4F", x"000AB142", x"A9180D0D"),  -- XOR normal
    (INST_XORI, x"FFF0FFFF", x"0FFFFFFF", x"F00F0000"),  -- XOR normal
    (INST_XORI, x"00000000", x"0FCAF92F", x"0FCAF92F"),  -- XOR normal
    (INST_XORI, x"A912BC4F", x"000AB142", x"A9180D0D"),  -- XOR normal

    (INST_MUL, x"00000011", x"00000003", x"00000033"),  -- MUL normal
    (INST_MUL, x"FFFFFF11", x"FFFFFFF3", x"00000C23"),  -- MUL with overflow

    (INST_SLL, x"00A0010D", x"00000001", x"0140021a"),  -- SLL by 1
    (INST_SLL, x"00A0010D", x"FFFFFF00", x"00A0010D"),  -- SLL by 0(since only 4:0 relevant)
    (INST_SLL, x"00A0010D", x"FFFFFF20", x"00A0010D"),  -- SLL by 0(since only 4:0 relevant)
    (INST_SLL, x"00000001", x"0000001F", x"80000000"),  -- SLL by 31
    (INST_SLLI, x"00A0010D", x"00000001", x"0140021a"),  -- SLL by 1
    (INST_SLLI, x"00A0010D", x"FFFFFF00", x"00A0010D"),  -- SLL by 0(since only 4:0 relevant)
    (INST_SLLI, x"00A0010D", x"FFFFFF20", x"00A0010D"),  -- SLL by 0(since only 4:0 relevant)
    (INST_SLLI, x"00000001", x"0000001F", x"80000000"),  -- SLL by 31

    (INST_SRA, x"00000ABC", x"00000003", x"00000157"),  -- postive SRA by 3
    (INST_SRA, x"000392F0", x"0000000F", x"00000007"),  -- postive SRA by 15
    (INST_SRA, x"000000F0", x"0000001F", x"00000000"),  -- postive SRA by 31
    (INST_SRA, x"000000F0", x"00000000", x"000000F0"),  -- postive SRA by 0
    (INST_SRA, x"FFFFC80F", x"00000005", x"FFFFFE40"),  -- negative SRA by 5
    (INST_SRAI, x"00000ABC", x"00000003", x"00000157"),  -- postive SRA by 3
    (INST_SRAI, x"000392F0", x"0000000F", x"00000007"),  -- postive SRA by 15
    (INST_SRAI, x"000000F0", x"0000001F", x"00000000"),  -- postive SRA by 31
    (INST_SRAI, x"000000F0", x"00000000", x"000000F0"),  -- postive SRA by 0
    (INST_SRAI, x"FFFFC80F", x"00000005", x"FFFFFE40"),  -- negative SRA by 5

    (INST_SRL, x"00000ABC", x"00000003", x"00000157"),  -- postive SRL by 3
    (INST_SRL, x"000392F0", x"0000000F", x"00000007"),  -- postive SRL by 15
    (INST_SRL, x"000000F0", x"0000001F", x"00000000"),  -- postive SRL by 31
    (INST_SRL, x"000000F0", x"00000000", x"000000F0"),  -- postive SRL by 0
    (INST_SRL, x"FFFFC80F", x"00000005", x"07FFFE40"),  -- negative SRL by 5
    (INST_SRLI, x"00000ABC", x"00000003", x"00000157"),  -- postive SRL by 3
    (INST_SRLI, x"000392F0", x"0000000F", x"00000007"),  -- postive SRL by 15
    (INST_SRLI, x"000000F0", x"0000001F", x"00000000"),  -- postive SRL by 31
    (INST_SRLI, x"000000F0", x"00000000", x"000000F0"),  -- postive SRL by 0
    (INST_SRLI, x"FFFFC80F", x"00000005", x"07FFFE40"),  -- negative SRL by 5

    (INST_LW, x"FFFFFFFF", x"00000001", x"00000000"),  -- LW with overflow
    (INST_LW, x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFE"),  -- LW with negative numbers
    (INST_LW, x"0001E692", x"FFFFF856", x"0001DEE8"),  -- LW with negative numbers

    (INST_SW, x"FFFFFFFF", x"00000001", x"00000000"),  -- SW with overflow
    (INST_SW, x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFE"),  -- SW with negative numbers
    (INST_SW, x"0001E692", x"FFFFF856", x"0001DEE8"),  -- SW with negative numbers

    (INST_SLT, x"00000000", x"00000001", x"00000001"),
    (INST_SLT, x"00000001", x"00000001", x"00000000"),
    (INST_SLT, x"00000001", x"00000000", x"00000000"),
    (INST_SLT, x"00000111", x"00000010", x"00000000"),
    (INST_SLT, x"01000111", x"01001010", x"00000001"),
    (INST_SLT, x"F1000111", x"00000010", x"00000001"),
    (INST_SLT, x"F0000111", x"F1000010", x"00000001"),
    (INST_SLTI, x"00000000", x"00000001", x"00000001"),
    (INST_SLTI, x"00000001", x"00000001", x"00000000"),
    (INST_SLTI, x"00000001", x"00000000", x"00000000"),
    (INST_SLTI, x"00000111", x"00000010", x"00000000"),
    (INST_SLTI, x"01000111", x"01001010", x"00000001"),
    (INST_SLTI, x"F1000111", x"00000010", x"00000001"),
    (INST_SLTI, x"F0000111", x"F1000010", x"00000001"),

    (INST_SLTU, x"00000000", x"00000001", x"00000001"),
    (INST_SLTU, x"00000001", x"00000001", x"00000000"),
    (INST_SLTU, x"00000001", x"00000000", x"00000000"),
    (INST_SLTU, x"00000111", x"00000010", x"00000000"),
    (INST_SLTU, x"01000111", x"01001010", x"00000001"),
    (INST_SLTU, x"F1000111", x"00000010", x"00000000"),
    (INST_SLTU, x"F0000111", x"F1000010", x"00000001"),
    (INST_SLTIU, x"00000000", x"00000001", x"00000001"),
    (INST_SLTIU, x"00000001", x"00000001", x"00000000"),
    (INST_SLTIU, x"00000001", x"00000000", x"00000000"),
    (INST_SLTIU, x"00000111", x"00000010", x"00000000"),
    (INST_SLTIU, x"01000111", x"01001010", x"00000001"),
    (INST_SLTIU, x"F1000111", x"00000010", x"00000000"),
    (INST_SLTIU, x"F0000111", x"F1000010", x"00000001"),

    -- (INST_JAL, x"F0000111", x"F1000010", x"00000001"),
    (INST_JALR, x"00000111", x"00000010", x"00010120"),

    (INST_LUI, x"00000111", x"00000010", x"00000010"),
    (INST_LUI, x"00000111", x"000F0010", x"000F0010"),

    -- (INST_AUIPC, x"00000111", x"00000010", x"00001000"),
    -- (INST_AUIPC, x"00000111", x"000F0010", x"000F0010"),

    (INST_BNE, x"00000000", x"00000000", x"00020000"),  -- BNE (no jump)
    (INST_BNE, x"12345678", x"12345678", x"00020000"),  -- BNE (no jump)
    (INST_BNE, x"ABDC29B2", x"ABDC29B2", x"00020000"),  -- BNE (no jump)
    (INST_BNE, x"0000000A", x"0000000A", x"00020000"),  -- BNE (no jump)
    (INST_BNE, x"AB193BD1", x"13948201", x"00000000"),  -- BNE (jump)
    (INST_BNE, x"10283010", x"AB19DDE9", x"00000000"),  -- BNE (jump)
    (INST_BNE, x"FFF19390", x"018001BC", x"00000000"),  -- BNE (jump)

    (INST_BEQ, x"00000000", x"00000000", x"00000000"),
    (INST_BEQ, x"12345678", x"12345678", x"00000000"),
    (INST_BEQ, x"10283010", x"AB19DDE9", x"00020000"),
    (INST_BEQ, x"FFF19390", x"018001BC", x"00020000"),

    (INST_BLT, x"00000000", x"00000000", x"00020000"),
    (INST_BLT, x"12345678", x"12345678", x"00020000"),
    (INST_BLT, x"10283010", x"AB19DDE9", x"00020000"),
    (INST_BLT, x"FFF19390", x"018001BC", x"00000000"),

    (INST_BGE, x"00000000", x"00000000", x"00000000"),
    (INST_BGE, x"12345678", x"12345678", x"00000000"),
    (INST_BGE, x"10283010", x"AB19DDE9", x"00000000"),
    (INST_BGE, x"FFF19390", x"018001BC", x"00020000"),

    (INST_BLTU, x"00000000", x"00000000", x"00020000"),
    (INST_BLTU, x"12345678", x"12345678", x"00020000"),
    (INST_BLTU, x"10283010", x"AB19DDE9", x"00000000"),
    (INST_BLTU, x"FFF19390", x"018001BC", x"00020000"),

    (INST_BGEU, x"00000000", x"00000000", x"00000000"),
    (INST_BGEU, x"12345678", x"12345678", x"00000000"),
    (INST_BGEU, x"10283010", x"AB19DDE9", x"00020000"),
    (INST_BGEU, x"FFF19390", x"018001BC", x"00000000")
    );

begin
  dut : entity work.alu(rtl)
    port map(
      clk => clk,
      reset => reset,
      a => a,
      b => b,
      instruction => instruction,
      rd => rd
      );

  tb : process
  begin
    -- Initial reset
    reset <= '1';
    wait for period;
    reset <= '0';

    for i in test_vectors'range loop
      instruction <= test_vectors(i).instruction;
      a <= test_vectors(i).a;
      b <= test_vectors(i).b;

      wait for period;
      assert (rd = test_vectors(i).rd)
        report "Test " & integer'image(i) & " failed: Expected rd = " & slv_to_hexstring(test_vectors(i).rd) & " but was " & slv_to_hexstring(rd)
        severity error;

    end loop;

    report "Testbench finished running";
    finished <= '1';
    wait;
  end process;

  clk <= not clk after half_period when finished = '0';
end rtl;
