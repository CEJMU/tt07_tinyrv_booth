library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tt_um_cejmu_riscv is
  port (
    clk     : in  std_logic;
    ena     : in  std_logic;
    rst_n   : in  std_logic;
    ui_in   : in  std_logic_vector(7 downto 0);
    uo_out  : out std_logic_vector(7 downto 0);
    uio_in  : in  std_logic_vector(7 downto 0);
    uio_out : out std_logic_vector(7 downto 0);
    uio_oe  : out std_logic_vector(7 downto 0)
  );
end entity tt_um_cejmu_riscv;

architecture rtl of tt_um_cejmu_riscv is

  alias mosi : std_logic is uo_out(0);
  alias sclk : std_logic is uo_out(1);
  alias cs : std_logic is uo_out(2);    -- active low

  alias miso : std_logic is ui_in(0);

  signal write_enable : std_logic;
  signal cpu_addr_out : std_logic_vector(13 downto 0);
  signal spi_addr_in  : std_logic_vector(15 downto 0);
  signal spi_data_out : std_logic_vector(31 downto 0);
  signal spi_data_in  : std_logic_vector(31 downto 0);
  signal mem_req      : std_logic;
  signal data_valid   : std_logic;
  signal reset        : std_logic;
  signal x1           : std_logic_vector(12 downto 0);

begin

  uio_oe <= (others => '1');

  uo_out(7 downto 3) <= x1(4 downto 0);
  uio_out <= x1(12 downto 5);

  cs <= mem_req;


  

  reset       <= not rst_n;
  spi_addr_in <= "00" & cpu_addr_out;

  cpu_inst : entity work.cpu (rtl)
    port map (
      clk        => clk,
      reset      => reset,
      data_in    => spi_data_out,
      data_valid => data_valid,
      addr_out   => cpu_addr_out,
      data_out   => spi_data_in,
      write_en   => write_enable,
      mem_req    => mem_req,
      x1         => x1
      );

  spi_master_inst : entity work.spi_master (rtl)
    port map(
      clk         => clk,
      sclk        => sclk,
      mode_select => write_enable,
      reset       => reset,
      mosi        => mosi,
      miso        => miso,
      cs          => mem_req,
      data_out    => spi_data_out,
      data_in     => spi_data_in,
      addr        => spi_addr_in,
      data_valid  => data_valid
      );


end architecture rtl;
