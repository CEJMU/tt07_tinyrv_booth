library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave is
  port (
    clk       : in  std_logic;                -- serial clock
    mosi       : in  std_logic;                -- master output, slave input
    cs         : in  std_logic;                -- chip select (active low)

    addr       : out std_logic_vector(13 downto 0);
    dataout    : out std_logic_vector(31 downto 0);
    data_valid : out std_logic
  );
end entity spi_slave;

architecture rtl of spi_slave is

  signal counter              : unsigned(4 downto 0)          := (others => '0');
  signal data_valid_reg       : std_logic                     := '0';
  signal data_output_register : std_logic_vector(31 downto 0) := (others => '0');
  signal addr_output_register : std_logic_vector(13 downto 0) := (others => '0');
  signal data_register        : std_logic_vector(30 downto 0) := (others => '0');
  signal addr_register        : std_logic_vector(13 downto 0) := (others => '0');

  type states is (RECV_ADDR, RECV_DATA);
  signal state                : states                        := RECV_ADDR;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if cs = '1' then
        data_register <= (others => '0');
        addr_register <= (others => '0');

        data_output_register <= (others => '0');
        addr_output_register <= (others => '0');

        counter        <= (others => '0');
        data_valid_reg <= '0';
        state          <= RECV_ADDR;
      else
        if state = RECV_ADDR then
          addr_register(to_integer(counter)) <= mosi;

          if counter >= 13 then         -- last bit read
            counter <= (others => '0');
            state   <= RECV_DATA;
          else
            counter <= counter + 1;
          end if;
        else
          if counter = 31 then          -- last bit read
            counter <= (others => '0');
            state   <= RECV_ADDR;

            -- Conversion little endian -> big endian
            -- 31-24 23-16 15-8 7-0 -> 7-0 15-8 23-16 31 30-24
            data_output_register <= data_register(7 downto 0) & data_register(15 downto 8) & data_register(23 downto 16) & mosi & data_register(30 downto 24);
            addr_output_register <= addr_register;
            data_valid_reg       <= '1';
          else                          -- normal write
            data_register(to_integer(counter)) <= mosi;
            counter                            <= counter + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  data_valid <= data_valid_reg;
  dataout    <= data_output_register;
  addr       <= addr_output_register;

end architecture rtl;
