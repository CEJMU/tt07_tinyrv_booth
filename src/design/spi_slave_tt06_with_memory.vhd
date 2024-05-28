library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave_tt06_with_memory is

    port
    (

        sclk : in std_logic;                         

        reset : in std_logic; 

        mosi : in std_logic;
        miso : out std_logic;
        cs   : in std_logic

        --addr_read    : out std_logic;
        --data_written : out std_logic;
        --mode_select_memory : out std_logic

    );
end entity spi_slave_tt06_with_memory;

architecture rtl of spi_slave_tt06_with_memory is

    signal sclK_zw : std_logic;
    signal data_to_memory_zw : std_logic_vector(31 downto 0);
    signal addr_to_memory_zw : std_logic_vector(15 downto 0);

    signal data_from_memory_zw : std_logic_vector(31 downto 0);

    signal addr_read_zw : std_logic; 
    signal data_written_zw : std_logic; 
    signal mode_select_memory_zw : std_logic;





    begin
        slave : entity work.spi_slave_tt06(rtl)
          port map (
  
            sclk => sclk_zw,                   -- kommt vom master
            mosi => mosi,                   -- kommt vom master 
            reset => reset,                    -- macht bisher noch nix
            miso => miso,                   -- kommt vom slave 
            cs => cs,                          -- von außen
            data_to_memory => data_to_memory_zw,  -- nach außen
            data_from_memory  => data_from_memory_zw,            
            addr_to_memory => addr_to_memory_zw,
            --addr_read => addr_read_zw,
            --data_written =>  data_written_zw,
            mode_select_memory => mode_select_memory_zw
            ); 


            memory : entity work.memory(simulation)
            port map (
    
              clk => sclk_zw,                   -- kommt vom master                -- kommt vom master 
              reset => reset,                    -- macht bisher noch nix
              addr => addr_to_memory_zw,
              datain => data_to_memory_zw,
              dataout => data_from_memory_zw,
              write_en => mode_select_memory_zw
              ); 


        end architecture;
