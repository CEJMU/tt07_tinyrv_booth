library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.commons.all;

entity memorytb is
end entity;

architecture rtl of memorytb is

  constant addr_width   : natural                                   := 14;
  signal clk            : std_logic                                 := '0';
  signal reset          : std_logic                                 := '0';
  signal addr           : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
  signal datain         : std_logic_vector(31 downto 0)             := (others => '0');
  signal write_en       : std_logic                                 := '1';
  signal dataout        : std_logic_vector(31 downto 0);

  signal finished       : std_logic                                 := '0';

  type memtest_vector is record
    write_en : std_logic;
    -- in
    -- using natural to make addr easier to read. Conversion happens below
    addr : natural range 0 to ((2**addr_width) - 1);
    datain : std_logic_vector(31 downto 0);
    -- out
    dataout : std_logic_vector(31 downto 0);
  end record;

  type memtest_vector_array is array (natural range <>) of memtest_vector;
  constant test_vectors : memtest_vector_array                      := (
    -- write_en addr   datain       dataout
    ('0', 00005, x"00000000", x"00000000"), -- Check some default values
    ('0', 00010, x"00000000", x"00000000"), -- ...
    ('0', 16383, x"00000000", x"00000000"), -- ...

    ('0', 00015, x"00000015", x"00000000"), -- Checking if write_en disables writing
    ('0', 00015, x"00000000", x"00000000"), -- Checking if write_en disables writing

    ('1', 00000, x"00000001", x"00000000"), -- Writing to memory (W)
    ('0', 00000, x"00000000", x"00000001"), -- Verifying previously written value (R)
    ('1', 00002, x"00000002", x"00000000"), -- W
    ('0', 00002, x"00000000", x"00000002"), -- R
    ('1', 00009, x"00000009", x"00000000"), -- W
    ('0', 00009, x"00000000", x"00000009"), -- R
    ('1', 16383, x"00001023", x"00000000"), -- W
    ('0', 16383, x"00000000", x"00001023"), -- R

    ('0', 00002, x"00000000", x"00000002"), -- Verifying all past values again
    ('0', 00009, x"00000000", x"00000009"), -- R
    ('0', 16383, x"00000000", x"00001023")  -- R
    );

begin

  dut : entity work.memory(simulation)
    port map(
      clk => clk,
      reset => reset,
      addr => addr,
      datain => datain,
      write_en => write_en,
      dataout => dataout
      );

  tb: process
  begin
    -- Initial reset
    reset <= '1';
    wait for period;
    reset <= '0';

    for i in test_vectors'range loop
      write_en <= test_vectors(i).write_en;
      -- converting to slv as required by memory
      addr <= std_logic_vector(to_unsigned(test_vectors(i).addr, addr_width));
      datain <= test_vectors(i).datain;

      wait for period;
      assert (dataout = test_vectors(i).dataout)
        report "Test " & integer'image(i) & " failed: Expected dataout = " & slv_to_hexstring(test_vectors(i).dataout) & " but was " & slv_to_hexstring(dataout)
        severity error;

    end loop;

    report "Testbench finished running";
    finished <= '1';
    wait;
  end process;

  clk <= not clk after half_period when finished = '0';

end architecture;
