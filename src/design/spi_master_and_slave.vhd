library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spi_master_and_slave is

    port
    (

        clk         : in std_logic;  -- FPGA CLK
        mode_select : in std_logic;  -- Read := 0 or Write:= 1

        reset : in std_logic;
        mosi  : out std_logic;
        cs    : in std_logic; -- needed for one clk cycle

        data_out_Master : out std_logic_vector(31 downto 0);

        data_in : in std_logic_vector(31 downto 0);
        addr    : in std_logic_vector(15 downto 0);

        data_valid : out std_logic;

        data_out_Slave : out std_logic_vector(31 downto 0)

        
    );
end entity spi_master_and_slave;

architecture rtl of spi_master_and_slave is


    signal sclk_zw : std_logic;
    signal data_valid_zw : std_logic;
    signal mosi_zw : std_logic;
    signal miso_zw : std_logic;
    signal addr_to_memory_zw : std_logic_vector(15 downto 0);

    begin


        master : entity work.spi_master(rtl)
        port map (

          clk => clk,
          sclk => sclk_zw,                  -- geht an den SPI_Slave
          mode_select => mode_select,       -- kommt von außen
          reset => reset,                   -- kommt von außen
          miso => miso_zw,                  -- kommt vom slave 
          mosi => mosi_zw,                  -- geht an den Slave
          cs => cs,                         -- kommt von außen
          data_out => data_out_Master,      -- geht nach außen
          data_in => data_in,               -- kommt von außen
          addr => addr,                     -- kommt von außen
          data_valid => data_valid_zw       -- geht nach außen

          );

          slave : entity work.spi_slave_tt06(rtl)
          port map (
  
            sclk => sclk_zw,                   -- kommt vom master
            mosi => mosi_zw,                   -- kommt vom master 
            reset => reset,                    -- macht bisher noch nix
            miso => miso_zw,                   -- kommt vom slave 
            cs => cs,                          -- von außen
            data_to_memory => data_out_Slave,  -- nach außen
            data_from_memory  => data_in,            --  
            addr_to_memory => addr_to_memory_zw
            ); 




end architecture rtl;
