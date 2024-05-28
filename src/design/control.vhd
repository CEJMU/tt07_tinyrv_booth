library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity control is
  port(
    clk   : in std_logic;
    reset : in std_logic;

    iword             : in  std_logic_vector(31 downto 0);
    data_valid        : in  std_logic;
    imm               : out std_logic_vector(31 downto 0);
    -- 2 downto 0 "instructiontype" | 3 I-type | 4 pc
    control_flags_out : out std_logic_vector(6 downto 0);

    wbflag    : out std_logic;
    memflag   : out std_logic;
    pcflag    : out std_logic;
    fetchflag : out std_logic;
    mem_req   : out std_logic
  );
end entity control;

architecture rtl of control is

  type states is (rst, fetch, decode, execute, memory, writeback, d2);
  signal currstate : states;

  signal control_flags : std_logic_vector(6 downto 0);
  -- concurrentsignals for registers
  signal w31_to_w11    : std_logic_vector(20 downto 0);

  -- internal control signals

  alias mem_phase  : std_logic is control_flags(0);
  alias mem_write  : std_logic is control_flags(1);
  alias reg_write  : std_logic is control_flags(2);
  alias imm_as_a   : std_logic is control_flags(3);
  alias jump       : std_logic is control_flags(4);
  alias pc_to_addr : std_logic is control_flags(5);
  alias rs1_to_pc  : std_logic is control_flags(6);

  alias opcode : std_logic_vector(6 downto 0) is iword(6 downto 0);
  alias funct3 : std_logic_vector(2 downto 0) is iword(14 downto 12);


begin
  process(clk, reset)
  begin
    if(reset = '1') then
      currstate <= rst;

    elsif (rising_edge(clk)) then

      if(currstate = rst) then
        currstate <= fetch;

      elsif(currstate = writeback) then
        currstate <= fetch;

      elsif(currstate = fetch) then
        if data_valid = '1' then
          currstate <= d2;
        end if;

      elsif(currstate = d2) then
        currstate <= decode;

      elsif(currstate = decode) then
        currstate <= execute;

      elsif(currstate = execute and (mem_phase = '1')) then
        currstate <= memory;

      elsif(currstate = execute and (mem_phase = '0')) then
        currstate <= writeback;

      elsif currstate = memory then
        if data_valid = '1' then
          currstate <= writeback;
        end if;

      end if;
    end if;
  end process;

  -- flags for Control

  mem_req <= '0' when ((currstate = fetch or currstate = memory) and data_valid = '0')
    else '1';

  pcflag <= '1' when ((currstate = execute and mem_phase = '0') or (currstate = memory and data_valid = '1'))
    else '0';

  memflag <= '1' when ((currstate = execute and mem_phase = '1' and mem_write = '1') or (currstate = memory and mem_write = '1'))
    else '0';

  wbflag <= '1' when ((currstate = memory and reg_write = '1' and data_valid = '1') or (currstate = execute and reg_write = '1' and mem_phase = '0'))
    else '0';

  fetchflag <= '1' when (currstate = fetch and data_valid = '1')
    else '0';

  pc_to_addr <= '1' when currstate = fetch or currstate = rst or currstate = writeback
    else '0';

  rs1_to_pc <= '1' when opcode = OP_JR
    else '0';

  -- concurrent signals for register access

  -- For I | S | B | U | J - Immediate
  w31_to_w11 <= (others => iword(31));

  imm <= w31_to_w11 & iword(30 downto 25) & iword(24 downto 20) when opcode = OP_LW or opcode = OP_IType or opcode = OP_JALR  -- I-Type
    else w31_to_w11 & iword(30 downto 25) & iword(11 downto 7)                                                       when opcode = OP_SW  -- S-Type
    else w31_to_w11(20 downto 1) & iword(7) & iword(30 downto 25) & iword(11 downto 8) & '0'                         when opcode = OP_BRANCH  -- B-Type
    else w31_to_w11(11 downto 0) & iword(19 downto 12) & iword(20) & iword(30 downto 25) & iword(24 downto 21) & '0' when opcode = OP_JAL  -- J-Type
    else (others => '0');

  -- control flags
  control_flags_out <= control_flags;

  mem_phase <= '1' when (opcode = OP_LW or opcode = OP_SW) and funct3 = FUNCT3_MEMORY
    else '0';
  mem_write <= '1' when opcode = OP_SW and funct3 = FUNCT3_MEMORY
    else '0';
  reg_write <= '0' when opcode = OP_BRANCH else '1';
  imm_as_a  <= '1' when opcode = OP_Itype or opcode = OP_LUI or opcode = OP_AUIPC or ((opcode = OP_LW or opcode = OP_SW) and funct3 = FUNCT3_MEMORY) or opcode = OP_JAL or opcode = OP_JALR
    else '0';
  jump <= '1' when opcode = OP_Branch or opcode = OP_JAL or opcode = OP_JALR or opcode = OP_JR
    else '0';

end architecture rtl;
