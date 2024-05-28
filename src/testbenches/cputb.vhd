library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cputb is
end entity;

architecture rtl of cputb is

  signal clk   : std_logic := '0';
  signal reset : std_logic := '1';

  signal finished : std_logic := '0';

  type reg_array is array (0 to 9) of std_logic_vector(31 downto 0);
  signal memory : reg_array := (
    -- ADDI x1, x1, 5 | 0
    "000000000101" & "00001" & "000" & "00001" & "0010011",
    -- ADDI x2, x0, 2 | 0
    "000000000010" & "00000" & "000" & "00010" & "0010011",
    -- ADD x3, x2, x1 | 8
    "0000000" & "00001" & "00010" & "000" & "00011" & "0110011",
    -- SW x3, 7(x0) | 24
    "0000000" & "00011" & "00000" & "010" & "00111" & "0100011",
    -- LW x4, 7(x0) | 32
    "000000000111" & "00000" & "010" & "00100" & "0000011",
    "0000001" & "00001" & "00010" & "000" & "00011" & "0110011",
    "0000001" & "00001" & "00010" & "000" & "00011" & "0110011",
    "0000001" & "00001" & "00010" & "000" & "00011" & "0110011",
    "0000001" & "00001" & "00010" & "000" & "00011" & "0110011",
    "0000001" & "00001" & "00010" & "000" & "00011" & "0110011"
    );

  signal iword        : std_logic_vector(31 downto 0) := memory(0);
  signal rdTMP        : std_logic_vector(31 downto 0);
  signal addr         : std_logic_vector(13 downto 0);
  signal write_en     : std_logic;
  signal cpu_data_in  : std_logic_vector(31 downto 0);
  signal cpu_data_out : std_logic_vector(31 downto 0);

begin

  process (addr, memory, write_en)
  begin
    if to_integer(unsigned(addr)) < 10 then
      iword <= memory(to_integer(unsigned(addr)));

      if write_en = '1' then
        memory(to_integer(unsigned(addr))) <= cpu_data_out;
      end if;
    else
      finished <= '1';
    end if;
  end process;

  process(clk)
    variable counter : natural := 0;

  begin
    if rising_edge(clk) then
      counter := counter + 1;

      if counter > 100 then
        finished <= '1';
      end if;
    end if;
  end process;

  dut : entity work.cpu(rtl)
    port map (
      clk      => clk,
      reset    => reset,
      data_in  => iword,
      addr_out => addr,
      write_en => write_en,
      data_out => cpu_data_out
      );


  reset <= '0' after 5 ns;

  clk <= not clk after 10 ns when finished = '0';


end architecture;
