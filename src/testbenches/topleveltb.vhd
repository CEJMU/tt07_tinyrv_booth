library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.commons.all;

entity topleveltb is
end entity topleveltb;

architecture test of topleveltb is

  signal clk      : std_logic := '0';
  signal rst_n    : std_logic := '0';
  signal finished : std_logic := '0';

begin

  toplevel_inst : entity work.toplevel(rtl)
    port map (
      clk   => clk,
      rst_n => rst_n);

  process
  begin
    rst_n <= '0';
    wait for 20 ns;
    rst_n <= '1';

    for i in 0 to 10000 loop            -- Leave CPU running for a bit
      wait for 20 ns;
    end loop;

    report "Testbench finished, check Waveform for verification";
    finished <= '1';
    wait;
  end process;

  clk <= not clk after 10 ns when finished = '0';

end architecture test;
