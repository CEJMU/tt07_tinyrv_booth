library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    addr     : in std_logic_vector(15 downto 0);
    datain   : in std_logic_vector(31 downto 0);
    write_en : in std_logic;

    dataout : out std_logic_vector(31 downto 0)
    );
end entity;

architecture simulation of memory is

  type mem_array is array((2**16) - 1 downto 0) of std_logic_vector(31 downto 0);
  signal mem : mem_array := (others => (others => '0'));

begin
  process (clk, reset)
  begin
    if reset = '1' then
      mem(0)  <= "10010011100000000101000000000000";  -- addi
      mem(1)  <= "00010011000000010010000000000000";  -- addi
      mem(2)  <= "10110011000000010001000100000000";  -- add
      mem(3)  <= "10110011010000100001000100000000";  -- xor
      mem(4)  <= "00110011011100110001000100000000";  -- and
      mem(5)  <= "10100011001001110011000000000000";  -- sw
      mem(6)  <= "00000011001000101111000000000000";  -- lw
      mem(7)  <= "11101111000000111000000000000000";  -- jal x7, 8
      mem(8)  <= "10100011001001110000000000000000";  -- sw 0 in mem[7]. This instruction should never execute
      mem(9)  <= "10010011000001000000000000000011";  -- addi x9 = 12*4 = 48
      mem(10) <= "01100111100000000000010000000000";  -- jr x9
      mem(11) <= "10100011001001110000000000000000";  -- sw 0 in mem[7]. This instruction should never execute
      mem(12) <= "01100011000000000001000000000000";  -- bne endless

    elsif rising_edge(clk) then
      if write_en = '1' then
        mem(to_integer(unsigned(addr))) <= datain;
      end if;

      dataout <= mem(to_integer(unsigned(addr)));
    end if;
  end process;



end architecture;
