library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.commons.all;
entity spi_slave_tt06tb is
end entity spi_slave_tt06tb;

architecture rtl of spi_slave_tt06tb is

  -- To test set slck_modif to 3 
  signal CLK         : std_logic := '0';
  signal reset       : std_logic;
  signal sclk        : std_logic := '0';
  signal cs          : std_logic;
  signal mosi        : std_logic := '0';
  signal miso        : std_logic := '0';
  signal data_to_memory  : std_logic_vector(31 downto 0);
  signal data_in     : std_logic_vector(31 downto 0);
  signal addr_to_memory     : std_logic_vector(15 downto 0);

  signal addr_read   : std_logic := '0';
  signal data_written : std_logic := '0';
  signal data_from_memory : std_logic_vector(31 downto 0);
  signal mode_select_memory : std_logic;


  signal finished      : std_logic := '0';

  type spi_master_test_vector is record
    addr     : std_logic_vector(15 downto 0);
    data_in  : std_logic_vector(31 downto 0);
    mode_select: std_logic;
    miso     : std_logic_vector(31 downto 0);
  end record;

  type spitest_vector_array is array (natural range <>) of spi_master_test_vector;
  constant test_vectors : spitest_vector_array := (
    -- addr_in   data_in      data_out     miso
    ("1010101010101010", x"F0000000", '1', x"AAAAAAAA"),
    ("1010101010101010", x"10BAC109", '1', x"AAAAAAAA"),
    ("1010101010101010", x"F0000000", '1', x"AAAAAAAA"),
    ("1010101010101010", x"10BAC109", '1', x"AAAAAAAA"),
    ("1010101010101010", x"F0000000", '1', x"AAAAAAAA"),
    ("1010101010101010", x"10BAC109", '1', x"AAAAAAAA"),
    ("1010101010101010", x"F0000000", '1', x"AAAAAAAA"),
    ("1010101010101010", x"10BAC109", '1', x"AAAAAAAA"),
    ("1010101010101010", x"F0000000", '1', x"AAAAAAAA"),
    ("1010101010101010", x"10BAC109", '1', x"AAAAAAAA")
  );

begin

  dut : entity work.spi_slave_tt06(rtl)
    port map
    (
     
      sclk        => clk,
      cs          => cs,
      mosi        => mosi,
      miso        => miso,
      data_to_memory => data_to_memory,
      data_from_memory     => data_from_memory,
      addr_to_memory => addr_to_memory,
      mode_select_memory => mode_select_memory,
      reset       => reset
    );
  -- 5 sclk period
  tb : process
  begin
    reset <= '1';
    wait for period;
    reset <= '0';
   

      wait for period;
      -- write mode
      cs <= '1';
      wait for period;
      wait for period;
      cs <= '0';
      wait for period;
      wait for period;

      for i in 16 downto 0 loop
        mosi <= '1';
        wait for period;
        end loop;

      for i in 33 downto 0 loop
            mosi <= '1';
            wait for period;
            end loop;
        cs <= '1';
 
    finished <= '1';
    wait;

  end process;

  clk <= not clk after half_period when finished = '0';

end architecture rtl;
