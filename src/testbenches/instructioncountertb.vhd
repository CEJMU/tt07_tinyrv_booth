library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.commons.all;

entity instructioncountertb is
end entity;

architecture rtl of instructioncountertb is

  signal clk               : std_logic                             := '0';
  signal reset            : std_logic;
  signal pcflag         : std_logic                             := '0';
  signal s0                : std_logic                             := '0';
  signal s1                : std_logic                             := '0';
  signal pc_new          : std_logic_vector(15 downto 0)         := (others => '0');
  signal pc_offset          : std_logic_vector(15 downto 0)         := (others => '0');
  signal finished          : std_logic                             := '0';

  type instructiontest_vector is record
    --in
    pcflag  : std_logic;
    s1        : std_logic;
    s0        : std_logic;
    pc_offset  : std_logic_vector(15 downto 0);
    -- out
    pc_new          : std_logic_vector(15 downto 0);
  end record;

  type instructiontest_vector_array is array (natural range <>) of instructiontest_vector;
  constant test_vectors    : instructiontest_vector_array          := (
    --   s1 s0 a0_to_a3 q0_to_q3
    ('1', '0', '0', (others => '0'), (others => '0')),    -- Indirekter Sprung mit q = 0 und a = 0
    ('1', '0', '0', "0000000000000011", x"0003"),  -- Indirekter Sprung mit q = 0 und a = 3 d.h. q = 3
    ('1', '0', '0', "0000000000000011", x"0006"),  -- Indirekter Sprung mit q = 0 und a = 3 d.h. q = 3
    ('1', '0', '0', "0000000000001000", x"000E"),  -- Indirekter Sprung mit q = 0 und a = 3 d.h. q = 3

    ('0', '0', '1', "0000100010000001", x"000E"),  -- Fetchnew = 0

    ('1', '0', '1', "0000000000101010", x"002A"),  -- Direkter Sprung mit q = 0 und a = 3 d.h. q = 3
    ('1', '0', '1', "0000100000000011", x"0803"),  -- Direkter Sprung mit q = 0 und a = 3 d.h. q = 3

    ('0', '0', '1', "0000100010000001", x"0803"),  -- Fetchnew = 0


    ('1', '1', '1', "0000001000100011", (others => '0')),   -- Reset
    -- ('0', '1', '1', "100010000001", (others => '0')),   -- Reset nach merge

    ('0', '0', '0', "0000001000100011", (others => '0')),  -- Fetchnew = 0

    ('1', '1', '0', "0000000000000000", x"0004"),  -- Inkrementieren
    ('1', '1', '0', "0000100010000001", x"0008"),  -- Inkrementieren
    ('1', '1', '0', "0000001000100011", x"000C"),  -- Inkrementieren
    ('1', '1', '0', "0000100010000001", x"0010"),  -- Inkrementieren
    ('1', '1', '0', "0000001000100011", x"0014"),  -- Inkrementieren

    ('0', '0', '1', "0000100010000001", x"0014")  -- Fetchnew = 0





    );

begin
  dut : entity work.instructioncounter(rtl)
    port map(
      clk         => clk,
      reset => reset,
      s1         => s1,
      pcflag => pcflag,
      s0         => s0,

      pc_offset   => pc_offset,
      pc_new   => pc_new
      );

  tb : process
  begin
    -- Initial reset

    reset <= '1';
    wait for period;
    reset <= '0';

    wait for period;

    for i in test_vectors'range loop
      pcflag   <= test_vectors(i).pcflag;
      s1         <= test_vectors(i).s1;
      s0         <= test_vectors(i).s0;
      pc_offset   <= test_vectors(i).pc_offset;

      wait for period;

      assert (pc_new = test_vectors(i).pc_new)
        report "Test " & integer'image(i) & " failed: Expected pc_new = " & slv_to_hexstring(test_vectors(i).pc_new) & " but was " & slv_to_hexstring(pc_new)
        severity error;

    end loop;

    report "Testbench finished running";
    finished <= '1';
    wait;
  end process;

  clk <= not clk after half_period when finished = '0';
end rtl;
