library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use work.commons.all;
use std.textio.all;

entity topleveltb is
end entity topleveltb;

architecture test of topleveltb is

  signal clk          : std_logic   := '0';  -- clk for CPU
  signal reset        : std_logic   := '0';  -- reset for CPU
  signal sclk         : std_logic   := '0';  -- clk for SPI programming
  signal mosi         : std_logic   := '0';  -- slave input for SPI programming
  signal program_mode : std_logic   := '1';  -- switch CPU to SPI programming mode (active low)
  signal miso         : std_logic;
  signal finished     : std_logic   := '0';

  file program_file : text;
  file env_file : text;

begin  -- architecture test

  toplevel_inst: entity work.toplevel(rtl)
    port map (
      clk          => clk,
      reset        => reset,
      -- sclk         => sclk,
      mosi         => mosi,
      program_mode => program_mode,
      miso         => miso);

  test: process
    -- TODO 13 oder 14?
    variable counter      : unsigned(13 downto 0) := (others => '0');
    variable program_line : line;
    variable env_line     : line;
    variable input_file   : character;
    variable iword_tmp    : std_logic_vector(31 downto 0);
  begin
    reset <= '1';
    wait for period;
    reset <= '0';
    program_mode <= '0';

    file_open(env_file, "testbenches/cpu_env.txt", read_mode);
    readline(env_file, env_line);
    read(env_line, input_file);

    file_open(program_file, "testbenches/cpu" & input_file & ".txt", read_mode);

    while not endfile(program_file) loop  -- Loop over iwords
      readline(program_file, program_line);
      hread(program_line, iword_tmp);

      for j in 0 to 13 loop             -- Loop over address
        mosi <= counter(j);
        wait for period;
      end loop;

      for j in 0 to 31 loop             -- Loop over iword
        mosi <= iword_tmp(j);
        wait for period;
      end loop;

      counter := counter + 1;
    end loop;

    file_close(program_file);

    program_mode <= '1';
    reset <= '1';
    wait for period;
    reset <= '0';

    for i in 0 to 10000 loop               -- Leave CPU running for a bit
      wait for period;
    end loop;

    report "Testbench finished, check Waveform for verification";
    finished <= '1';
    wait;
  end process;

  clk <= not clk after half_period when finished = '0';

end architecture test;
