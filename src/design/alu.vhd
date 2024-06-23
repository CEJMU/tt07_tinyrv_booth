library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity alu is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    a           : in std_logic_vector(31 downto 0);  -- rs1/pc
    b           : in std_logic_vector(31 downto 0);  -- rs2/imm
    instruction : in std_logic_vector(16 downto 0);

    rd : out std_logic_vector(31 downto 0);
    mul_bit : out std_logic 
    );
end entity;

architecture rtl of alu is

  alias opcode : std_logic_vector(6 downto 0) is instruction(6 downto 0);
  alias funct7 : std_logic_vector(6 downto 0) is instruction(16 downto 10);
  alias funct3 : std_logic_vector(2 downto 0) is instruction(9 downto 7);
  alias s1s0   : std_logic_vector(1 downto 0) is rd(17 downto 16);
  signal product : std_logic_vector(63 downto 0) := (others => '0');
  signal multiplcand : std_logic_vector(31 downto 0) := (others => '0');
  signal mulcounter : integer;
  signal internal_mul: std_logic;

begin

  process(clk, reset)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        rd <= x"00000000";
        mulcounter <= 31;
        mul_bit <= '0';
        internal_mul <= '0';

      elsif (funct7 = FUNCT7_MUL and funct3 = FUNCT3_MUL and opcode = OP_RTYPE and internal_mul = '0')then
        mul_bit <= '1';
        internal_mul <= '1';
        multiplcand <= a;
        product(63 downto 32) <= b;       
      elsif(internal_mul = '1')then

        if(product(0)= '1' and mulcounter > 0)then
        product <= std_logic_vector(shift_right(signed(std_logic_vector((signed(product(63 downto 32)) + signed(multiplcand))) & product(31 downto 0)),1));          
        mulcounter <= mulcounter -1;
        elsif(product(0) = '0' and mulcounter > 0) then
        product <= std_logic_vector(shift_right(signed(product),1));
        mulcounter <= mulcounter -1;
        elsif(mulcounter = 0) then
        mulcounter <= 31;
        mul_bit <= '0';
        internal_mul <= '0';
        rd <= product(31 downto 0);
        end if;
      
      elsif (funct7 = FUNCT7_ADD and funct3 = FUNCT3_ADD and opcode = OP_RTYPE)
        or (funct3 = FUNCT3_ADDI and opcode = OP_ITYPE)
        or ((opcode = OP_SW or opcode = OP_LW) and funct3 = FUNCT3_MEMORY) then
        rd <= std_logic_vector(signed(a) + signed(b));

      elsif (funct7 = FUNCT7_AND and funct3 = FUNCT3_AND and opcode = OP_RTYPE) then
        rd <= a and b;

      elsif (funct7 = FUNCT7_XOR and funct3 = FUNCT3_XOR and opcode = OP_RTYPE) then
        rd <= a xor b;

        -- elsif (funct7 = FUNCT7_SLL and funct3 = FUNCT3_SLL and opcode = OP_RTYPE) then
        --   rd <= std_logic_vector(shift_left(signed(a), to_integer(unsigned(b(4 downto 0)))));

        -- elsif (funct7 = FUNCT7_SRA and funct3 = FUNCT3_SRA and opcode = OP_RTYPE) then
        --   rd <= std_logic_vector(shift_right(signed(a), to_integer(unsigned(b(4 downto 0)))));

        -- elsif (funct7 = FUNCT7_SRL and funct3 = FUNCT3_SRL and opcode = OP_RTYPE) then
        --   rd <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0)))));

      elsif opcode = OP_JAL then
        rd(31 downto 18) <= (others => '0');
        rd(15 downto 0)  <= (others => '0');
        s1s0             <= "00";

      elsif opcode = OP_JR then
        rd(31 downto 18) <= (others => '0');
        rd(15 downto 0)  <= (others => '0');
        s1s0             <= "01";

      elsif opcode = OP_BRANCH and funct3 = FUNCT3_BNE then
        rd(31 downto 18) <= (others => '0');
        rd(15 downto 0)  <= (others => '0');

        if a = b then
          s1s0 <= "10";
        else
          s1s0 <= "00";
        end if;

      else
        rd <= (others => '0');

      end if;
    end if;
  end process;
end rtl;
