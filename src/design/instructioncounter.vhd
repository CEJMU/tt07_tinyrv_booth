library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instructioncounter is
  port(
    clk       : in  std_logic;
    reset     : in  std_logic;

    pcflag    : in  std_logic;
    s0        : in  std_logic;
    s1        : in  std_logic;
    pc_offset : in  std_logic_vector(15 downto 0);

    pc_inc    : out std_logic_vector(15 downto 0);

    pc_new    : out std_logic_vector(15 downto 0)
  );
end entity instructioncounter;

architecture rtl of instructioncounter is

  signal s1s0 : std_logic_vector(1 downto 0);
  signal reg  : std_logic_vector(15 downto 0) := (others => '0');          -- einsprung adresse
begin

  s1s0 <= s1 & s0;
  pc_new <= reg;

  count: process(clk)
  begin
    if rising_edge(clk) then
      pc_inc <= std_logic_vector(signed(reg) + 4);
      -- Reset
      if reset = '1' then
        reg <= (others => '0');
      elsif pcflag = '1' then
        case s1s0 is
          -- Indirekter Sprung
          when "00" =>
            reg <= std_logic_vector(signed(pc_offset) + signed(reg));
            -- Inkrementieren
          when "10" =>
            reg <= std_logic_vector(signed(reg) + 4);
            -- Direkter Sprung
          when "01" =>
            reg <= pc_offset;            
          when others =>
            reg <= (others => '0');
        end case;
      end if;
    end if;
  end process count;
end architecture rtl;
