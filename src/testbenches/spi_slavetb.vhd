library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.commons.all;

entity spi_slavetb is
end entity;

architecture rtl of spi_slavetb is

  signal clk              : std_logic            := '0';
  signal mosi             : std_logic            := '0';
  signal cs               : std_logic            := '1';

  signal addr_out         : std_logic_vector(13 downto 0);
  signal data_out         : std_logic_vector(31 downto 0);
  signal data_valid       : std_logic;

  signal finished         : std_logic            := '0';

  type spitest_vector is record
    addr     : std_logic_vector(13 downto 0);
    data_in  : std_logic_vector(31 downto 0);
    data_out : std_logic_vector(31 downto 0);
  end record;

  type spitest_vector_array is array (natural range <>) of spitest_vector;
  constant test_vectors   : spitest_vector_array := (
    -- addr_in          data_in      data_out
    ("00000000001001", x"A00000FF", x"FF0000A0"),
    ("00101010101000", x"10BAC109", x"09C1BA10"),
    ("11111111111111", x"FFFFFFFF", x"FFFFFFFF"),
    ("00100001001111", x"ADFB1391", x"9113FBAD"),
    ("00101010101111", x"ABADCC19", x"19CCADAB"),
    ("11000000111100", x"88192841", x"41281988"),
    ("00000000000010", x"A0000000", x"000000A0")
    );

begin

  dut : entity work.spi_slave(rtl)
    port map(
      sclk    => clk,
      mosi    => mosi,
      cs      => cs,
      addr    => addr_out,
      dataout => data_out,
      data_valid => data_valid
      );

  tb : process
  begin
    cs <= '1';
    wait for period;

    assert (data_valid = '0')
      report "data_valid is not 0 at before enabling the module!"
      severity error;

    cs <= '0';
    for i in test_vectors'range loop

      for j in 0 to 13 loop
        mosi <= test_vectors(i).addr(j);
        wait for period;
      end loop;

      for j in 0 to 31 loop
        mosi <= test_vectors(i).data_in(j);
        wait for period;
      end loop;

      assert (addr_out = test_vectors(i).addr)
        report "Test " & integer'image(i) & " failed: Expected addr = " & slv_to_hexstring(test_vectors(i).addr) & " but was " & slv_to_hexstring(addr_out)
        severity error;

      assert (data_out = test_vectors(i).data_out)
        report "Test " & integer'image(i) & " failed: Expected dataout = " & slv_to_hexstring(test_vectors(i).data_out) & " but was " & slv_to_hexstring(data_out)
        severity error;

      assert (data_valid = '1')
        report "data_valid is not 1 after transmitting data!"
        severity error;

    end loop;

    cs <= '1';
    wait for period;

    assert (data_valid = '0')
      report "data_valid is not 0 after setting cs = 1!"
      severity error;

    report "Testbench finished running";
    finished <= '1';
    wait;
  end process;

  clk <= not clk after half_period when finished = '0';

end architecture;
