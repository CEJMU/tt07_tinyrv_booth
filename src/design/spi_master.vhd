library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spi_master is

    port
    (

        clk         : in std_logic;  -- FPGA CLK
        sclk        : out std_logic; -- SPI_CLK
        mode_select : in std_logic;  -- Read := 0 or Write:= 1

        reset : in std_logic;
        mosi  : out std_logic;
        miso  : in std_logic;
        cs    : in std_logic; -- needed for one clk cycle

        data_out : out std_logic_vector(31 downto 0);

        data_in : in std_logic_vector(31 downto 0);
        addr    : in std_logic_vector(15 downto 0);

        data_valid : out std_logic
    );
end entity spi_master;

architecture rtl of spi_master is

    -- cs=0 halten bis datavalid = 1, dann cs = 1 bis zur nächsten Übertragung

    -- constant sclk_modify : integer := 8;                -- To modify sclk
    -- variable counter : integer := 1;
    signal clock_polarity : std_logic := '0';

    signal data_reg : std_logic_vector(31 downto 0);

    signal mode_select_zw : std_logic;

    signal write_adress_counter : integer := 16;
    signal read_adress_counter  : integer := 33;

    type states is (rst, send_adress, write_data, read_data, data);
    signal currstate : states;
begin

    -- SCLK Generator

--     process (clk, reset)
--         constant sclk_modif   : integer := 3; -- To modify sclk : sclk = sclk_modify * clk_period/2
--         variable sclk_counter : integer := 0;
--     begin

--         --if (reset = '1') then
--         --  clock_polarity <= '0';

--         if (rising_edge(clk)) then
--             --if (currstate /= rst) then
--             if (reset = '1') then
--                 clock_polarity <= '0';
--             else if (sclk_counter = sclk_modif - 1) then
--                 clock_polarity <= (clock_polarity xor '1');
--                 sclk_counter := 0;

--             else sclk_counter := sclk_counter + 1;
--             end if;
--         end if;
--         --else clock_polarity <= '0';
--         --end if;

--     elsif (falling_edge(clk)) then
--         --if (currstate /= rst) then
--         if (sclk_counter = sclk_modif - 1) then
--             clock_polarity <= (clock_polarity xor '1');
--             sclk_counter      := 0;
--         else sclk_counter := sclK_counter + 1;
--         end if;
--     end if;

--     --end if;
-- end process;

-- process (clock_polarity)
process (clk)

begin

    if (reset = '1') then
        currstate <= rst;

    elsif (rising_edge(clk)) then

        if (currstate = rst) then
            mosi                 <= '0';
            -- data_in_reg          <= (others => '0');
            -- adress_in_reg        <= (others => '0');
            mode_select_zw       <= '0';
            data_out             <= (others => '0');
            -- write_adress_counter <= 15;
            data_reg             <= (others => '0');
            write_adress_counter <= 16;         -- first bit: 0 -> read mode || 1 -> write mode
            read_adress_counter  <= 33;
            data_valid           <= '0';
            if (cs = '0') then
                currstate      <= send_adress;
                mode_select_zw <= mode_select;
            end if;

        elsif (currstate = send_adress) then
            if (write_adress_counter = 16) then
                mosi <= mode_select_zw;
                write_adress_counter <= write_adress_counter - 1;
            elsif(write_adress_counter > 0 and write_adress_counter <= 15) then
                mosi                 <= addr(write_adress_counter);
                write_adress_counter <= write_adress_counter - 1;
            else
                mosi            <= addr(write_adress_counter);
                if (mode_select_zw = '0') then
                    currstate <= read_data;
                elsif (mode_select_zw = '1') then
                    currstate <= write_data;
                end if;

            end if;


        elsif (currstate = read_data) then
            if (read_adress_counter >= 32) then
                read_adress_counter <= read_adress_counter - 1;

            elsif (read_adress_counter > 0) then
                data_reg(read_adress_counter) <= miso;
                read_adress_counter           <= read_adress_counter - 1;
            else
                currstate                <= data;
                data_reg(read_adress_counter) <= miso;
            end if;

        elsif (currstate = write_data) then
            if (read_adress_counter >= 32) then
                read_adress_counter <= read_adress_counter - 1;

            elsif (read_adress_counter > 0) then
                mosi                <= data_in(read_adress_counter);
                read_adress_counter <= read_adress_counter - 1;
            else
                currstate      <= data;
                mosi                <= data_in(read_adress_counter);
            end if;

        elsif (currstate = data) then
            data_valid <= '1';
            data_out   <= data_reg;
            currstate  <= rst;
        end if;
    end if;
end process;

sclk <= clk;

end architecture rtl;
