library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
  port (
    clk        : in  std_logic;
    reset      : in  std_logic;

    addr       : in  std_logic_vector(15 downto 0);
    datain     : in  std_logic_vector(31 downto 0);
    write_en   : in  std_logic;

    dataout    : out std_logic_vector(31 downto 0)
  );
end entity;

architecture simulation of memory is

  type mem_array is array((2**16) - 1 downto 0) of std_logic_vector(31 downto 0);
  signal mem : mem_array := 
  (x"00000000", x"00000000");

begin
  process (clk, reset) begin
    if rising_edge(clk) then
      if write_en = '1' then
        mem(to_integer(unsigned(addr))) <= datain;
      end if;

      dataout <= mem(to_integer(unsigned(addr)));
    end if;
  end process;



end architecture;
