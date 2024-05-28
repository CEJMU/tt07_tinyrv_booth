library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.commons.all;
entity spi_mastertb is
end entity spi_mastertb;

architecture rtl of SPI_Mastertb is

  -- To test set slck_modif to 3 
  signal CLK         : std_logic := '0';
  signal reset       : std_logic;
  signal sclk        : std_logic := '0';
  signal cs          : std_logic;
  signal mosi        : std_logic := '0';
  signal miso        : std_logic := '0';
  signal mode_select : std_logic;
  signal data_out    : std_logic_vector(31 downto 0);
  signal data_in     : std_logic_vector(31 downto 0);
  signal addr        : std_logic_vector(15 downto 0);

  signal data_valid : std_logic := '0';

  signal finished      : std_logic := '0';
  constant half_period : time      := 10 ns;

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

  dut : entity work.spi_master(rtl)
    port map
    (
      clk         => clk,
      sclk        => sclk,
      cs          => cs,
      mosi        => mosi,
      miso        => miso,
      data_out    => data_out,
      data_in     => data_in,
      mode_select => mode_select,
      data_valid  => data_valid,
      addr        => addr,
      reset       => reset
    );
  -- 5 sclk period
  tb : process
  begin
    reset <= '1';
    wait for sclK_period;
    reset <= '0';
   

      wait for sclK_period;
      -- write mode

    for j in test_vectors'range loop

      

      cs <= '1';
      wait for sclk_period;
      wait for sclk_period;
      cs <= '0';
      mode_select <= test_vectors(j).mode_select;
      addr        <= test_vectors(j).addr;
      data_in     <= test_vectors(j).data_in;
      wait for sclk_period;
      wait for sclk_period;
     
      if(test_vectors(j).mode_select = '1')then
      write_addr_1 : for i in 16 downto 0 loop
        if(i = 16)then

          assert(mode_select = mosi)
          report "Test failed during writing addr in write mode at bit : " & integer'image(i) & " in Test " & integer'image(j) & " was " & std_logic'image(mosi)
          severity error;
          else

        assert(addr(i) = mosi)
        report "Test failed during writing addr in write mode at bit : " & integer'image(i) & " in Test " & integer'image(j) & " was " & std_logic'image(mosi)
          severity error;
          end if;
        wait for sclk_period;
      end loop;

      write_data : for i in 31 downto 0 loop     
        assert(data_in(i) = mosi)
        report "Test failed during writing data in write mode at bit: " & integer'image(i) & " in Test " & integer'image(j) & " was " & std_logic'image(mosi)
          severity error;
        wait for sclk_period;
      end loop;
          else
          write_addr_2 : for i in 16 downto 0 loop
            if(i = 16)then
    
              assert(mode_select = mosi)
              report "Test failed during writing addr in write mode at bit : " & integer'image(i) & " in Test " & integer'image(j) & " was " & std_logic'image(mosi)
              severity error;
              else
            assert(addr(i) = mosi)
            report "Test failed during writing addr in write mode at bit : " & integer'image(i) & " in Test " & integer'image(j) & " was " & std_logic'image(mosi)
            severity error;
            if(i = 0)then
              miso <= test_vectors(j).miso(31);   
              end if;
              end if;
            wait for sclk_period;
          end loop;
    
          read_data : for i in 30 downto 0 loop
            
            miso <= test_vectors(j).miso(i);     
            --assert(data_in(i) = mosi)
            --report "Test failed during writing data in write mode at bit: " & integer'image(i) & " in Test " & integer'image(j) & " was " & std_logic'image(mosi)
             -- severity error;
            wait for sclk_period;
          end loop;
          


          end if;
    end loop;
    finished <= '1';
    wait;

  end process;

  clk <= not clk after half_period when finished = '0';

end architecture rtl;
