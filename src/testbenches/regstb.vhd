library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- clock period and function import
use work.commons.all;

entity regstb is
end entity;

architecture rtl of regstb is

  signal clk            : std_logic                     := '0';
  signal reset          : std_logic                     := '1';

  signal rs1adr         : std_logic_vector(4 downto 0)  := (others => '0');
  signal rs2adr         : std_logic_vector(4 downto 0)  := (others => '0');
  signal rdadr          : std_logic_vector(4 downto 0)  := (others => '0');
  signal rd             : std_logic_vector(31 downto 0) := (others => '0');
  signal regwrite       : std_logic                     := '0';

  signal rs1            : std_logic_vector(31 downto 0);
  signal rs2            : std_logic_vector(31 downto 0);

  signal finished       : std_logic                     := '0';

  type test_vector is record
    regwrite : std_logic;
    -- in
    rdadr    : std_logic_vector(4 downto 0);
    rd       : std_logic_vector(31 downto 0);
    -- out
    rs1adr   : std_logic_vector(4 downto 0);
    rs1      : std_logic_vector(31 downto 0);
    rs2adr   : std_logic_vector(4 downto 0);
    rs2      : std_logic_vector(31 downto 0);
  end record;

  type test_vector_array is array (natural range <>) of test_vector;
  constant test_vectors : test_vector_array             := (
    -- regwrite rdadr       rd      rs1adr       rs1      rs2adr        rs2
    ('1', "00000", x"0000000F", "00000", x"00000000", "00000", x"00000000"),  -- x0 not writable
    ('1', "00001", x"12345678", "00001", x"00000000", "00000", x"00000000"),  -- writing to x1
    ('1', "00011", x"11111111", "00001", x"12345678", "00000", x"00000000"),  -- checking x1 and writing to x3
    ('0', "00001", x"22222222", "00001", x"12345678", "00011", x"11111111"),  -- checking x3 and x1 not writable because regwrite = 0
    ('0', "00001", x"22222222", "00001", x"12345678", "00011", x"11111111"),  -- x1 still unchanged
    ('1', "00001", x"3104AB3C", "00001", x"12345678", "00011", x"11111111"),  -- writing to x1 again. x1 out should still be the old value
    ('1', "01000", x"00000539", "00001", x"3104AB3C", "00001", x"3104AB3C"),  -- checking x1 on both outputs. Writing to x8
    ('0', "00000", x"FFFFFFFF", "01000", x"00000539", "00000", x"00000000"),  -- checking x8
    ('1', "00001", x"00000001", "00000", x"00000000", "00000", x"00000000"),  -- Checking, if every register is adressable
    ('1', "00010", x"00000002", "00001", x"00000001", "00000", x"00000000"),  -- ...
    ('1', "00011", x"00000003", "00010", x"00000002", "00000", x"00000000"),  -- ...
    ('1', "00100", x"00000004", "00011", x"00000003", "00000", x"00000000"),  -- ...
    ('1', "00101", x"00000005", "00100", x"00000004", "00000", x"00000000"),  -- ...
    ('1', "00110", x"00000006", "00101", x"00000005", "00000", x"00000000"),  -- ...
    ('1', "00111", x"00000007", "00110", x"00000006", "00000", x"00000000"),  -- ...
    ('1', "01000", x"00000008", "00111", x"00000007", "00000", x"00000000"),  -- ...
    ('1', "01001", x"00000009", "01000", x"00000008", "00000", x"00000000"),  -- ...
    ('1', "01010", x"00000010", "01001", x"00000009", "00000", x"00000000"),  -- ...
    ('1', "01011", x"00000011", "01010", x"00000010", "00000", x"00000000"),  -- ...
    ('1', "01100", x"00000012", "01011", x"00000011", "00000", x"00000000"),  -- ...
    ('1', "01101", x"00000013", "01100", x"00000012", "00000", x"00000000"),  -- ...
    ('1', "01110", x"00000014", "01101", x"00000013", "00000", x"00000000"),  -- ...
    ('1', "01111", x"00000015", "01110", x"00000014", "00000", x"00000000"),  -- ...
    ('1', "10000", x"00000016", "01111", x"00000015", "00000", x"00000000"),  -- ...
    ('1', "10001", x"00000017", "10000", x"00000016", "00000", x"00000000"),  -- ...
    ('1', "10010", x"00000018", "10001", x"00000017", "00000", x"00000000"),  -- ...
    ('1', "10011", x"00000019", "10010", x"00000018", "00000", x"00000000"),  -- ...
    ('1', "10100", x"00000020", "10011", x"00000019", "00000", x"00000000"),  -- ...
    ('1', "10101", x"00000021", "10100", x"00000020", "00000", x"00000000"),  -- ...
    ('1', "10110", x"00000022", "10101", x"00000021", "00000", x"00000000"),  -- ...
    ('1', "10111", x"00000023", "10110", x"00000022", "00000", x"00000000"),  -- ...
    ('1', "11000", x"00000024", "10111", x"00000023", "00000", x"00000000"),  -- ...
    ('1', "11001", x"00000025", "11000", x"00000024", "00000", x"00000000"),  -- ...
    ('1', "11010", x"00000026", "11001", x"00000025", "00000", x"00000000"),  -- ...
    ('1', "11011", x"00000027", "11010", x"00000026", "00000", x"00000000"),  -- ...
    ('1', "11100", x"00000028", "11011", x"00000027", "00000", x"00000000"),  -- ...
    ('1', "11101", x"00000029", "11100", x"00000028", "00000", x"00000000"),  -- ...
    ('1', "11110", x"00000030", "11101", x"00000029", "00000", x"00000000"),  -- ...
    ('1', "11111", x"00000031", "11110", x"00000030", "00000", x"00000000"),  -- ...
    ('0', "00000", x"FFFFFFFF", "11111", x"00000031", "00000", x"00000000")  -- ...
    );

begin
  dut : entity work.regs(rtl)
    port map(
      clk      => clk,
      reset    => reset,
      rs1adr   => rs1adr,
      rs2adr   => rs2adr,
      rdadr    => rdadr,
      rd       => rd,
      regwrite => regwrite,
      rs1      => rs1,
      rs2      => rs2
      );


  tb : process
  begin
    -- Initial reset
    reset <= '1';
    wait for period;
    reset <= '0';

    for i in test_vectors'range loop
      regwrite <= test_vectors(i).regwrite;
      rdadr    <= test_vectors(i).rdadr;
      rd       <= test_vectors(i).rd;
      rs1adr   <= test_vectors(i).rs1adr;
      rs2adr   <= test_vectors(i).rs2adr;

      wait for period;
      assert (rs1 = test_vectors(i).rs1)
        report "Test " & integer'image(i) & " failed: Expected rs1 = " & slv_to_hexstring(test_vectors(i).rs1) & " but was " & slv_to_hexstring(rs1)
        severity error;

      assert (rs2 = test_vectors(i).rs2)
        report "Test " & integer'image(i) & " failed: Expected rs2 = " & slv_to_hexstring(test_vectors(i).rs2) & " but was " & slv_to_hexstring(rs2)
        severity error;

    end loop;

    report "Testbench finished running";
    finished <= '1';
    wait;
  end process;

  clk <= not clk after half_period when finished = '0';

end architecture;
