library ieee;
use ieee.std_logic_1164.all;

package constants is
  -- Opcode field
  constant OP_RTYPE  : std_logic_vector(6 downto 0) := "0110011";
  constant OP_ITYPE  : std_logic_vector(6 downto 0) := "0010011";
  constant OP_LUI    : std_logic_vector(6 downto 0) := "0110111";
  constant OP_AUIPC  : std_logic_vector(6 downto 0) := "0010111";
  constant OP_LW     : std_logic_vector(6 downto 0) := "0000011";
  constant OP_SW     : std_logic_vector(6 downto 0) := "0100011";
  constant OP_JR     : std_logic_vector(6 downto 0) := "1100111";
  constant OP_JALR   : std_logic_vector(6 downto 0) := "1100111";
  constant OP_JAL    : std_logic_vector(6 downto 0) := "1101111";
  constant OP_BRANCH : std_logic_vector(6 downto 0) := "1100011";

  -- funct7 and funct3 fields for R-Type
  constant FUNCT7_ADD : std_logic_vector(6 downto 0) := "0000000";
  constant FUNCT3_ADD : std_logic_vector(2 downto 0) := "000";

  constant FUNCT7_SUB : std_logic_vector(6 downto 0) := "0100000";
  constant FUNCT3_SUB : std_logic_vector(2 downto 0) := "000";

  constant FUNCT7_AND : std_logic_vector(6 downto 0) := "0000000";
  constant FUNCT3_AND : std_logic_vector(2 downto 0) := "111";

  constant FUNCT7_OR : std_logic_vector(6 downto 0) := "0000000";
  constant FUNCT3_OR : std_logic_vector(2 downto 0) := "110";

  constant FUNCT7_XOR : std_logic_vector(6 downto 0) := "0000000";
  constant FUNCT3_XOR : std_logic_vector(2 downto 0) := "100";

  constant FUNCT7_SLT : std_logic_vector(6 downto 0) := "0000000";
  constant FUNCT3_SLT : std_logic_vector(2 downto 0) := "010";

  constant FUNCT7_SLTU : std_logic_vector(6 downto 0) := "0000000";
  constant FUNCT3_SLTU : std_logic_vector(2 downto 0) := "011";
  --
  constant FUNCT7_SRA  : std_logic_vector(6 downto 0) := "0100000";
  constant FUNCT3_SRA  : std_logic_vector(2 downto 0) := "101";

  constant FUNCT7_SRL : std_logic_vector(6 downto 0) := "0000000";
  constant FUNCT3_SRL : std_logic_vector(2 downto 0) := "101";

  constant FUNCT7_SLL : std_logic_vector(6 downto 0) := "0000000";
  constant FUNCT3_SLL : std_logic_vector(2 downto 0) := "001";

  constant FUNCT7_MUL : std_logic_vector(6 downto 0) := "0000001";
  constant FUNCT3_MUL : std_logic_vector(2 downto 0) := "000";

  -- funct3 for most immediate instructions
  constant FUNCT3_ADDI  : std_logic_vector(2 downto 0) := "000";
  constant FUNCT3_ANDI  : std_logic_vector(2 downto 0) := "111";
  constant FUNCT3_ORI   : std_logic_vector(2 downto 0) := "110";
  constant FUNCT3_XORI  : std_logic_vector(2 downto 0) := "100";
  constant FUNCT3_SLTI  : std_logic_vector(2 downto 0) := "010";
  constant FUNCT3_SLTIU : std_logic_vector(2 downto 0) := "011";

  constant FUNCT7_SRAI : std_logic_vector(6 downto 0) := "0100000";
  constant FUNCT3_SRAI : std_logic_vector(2 downto 0) := "101";

  constant FUNCT7_SRLI : std_logic_vector(6 downto 0) := "0000000";
  constant FUNCT3_SRLI : std_logic_vector(2 downto 0) := "101";

  constant FUNCT7_SLLI : std_logic_vector(6 downto 0) := "0000000";
  constant FUNCT3_SLLI : std_logic_vector(2 downto 0) := "001";

  -- funct3 for memory instructions
  constant FUNCT3_MEMORY : std_logic_vector(2 downto 0) := "010";

  -- funct3 for branches
  constant FUNCT3_BEQ  : std_logic_vector(2 downto 0) := "000";
  constant FUNCT3_BNE  : std_logic_vector(2 downto 0) := "001";
  constant FUNCT3_BLT  : std_logic_vector(2 downto 0) := "100";
  constant FUNCT3_BGE  : std_logic_vector(2 downto 0) := "101";
  constant FUNCT3_BLTU : std_logic_vector(2 downto 0) := "110";
  constant FUNCT3_BGEU : std_logic_vector(2 downto 0) := "111";

  -- instruction for tb
  -- R-TYPE

  constant INST_ADD  : std_logic_vector(16 downto 0) := FUNCT7_ADD & FUNCT3_ADD & OP_RTYPE;
  constant INST_SUB  : std_logic_vector(16 downto 0) := FUNCT7_SUB & FUNCT3_SUB & OP_RTYPE;
  constant INST_MUL  : std_logic_vector(16 downto 0) := FUNCT7_MUL & FUNCT3_MUL & OP_RTYPE;
  constant INST_AND  : std_logic_vector(16 downto 0) := FUNCT7_AND & FUNCT3_AND & OP_RTYPE;
  constant INST_XOR  : std_logic_vector(16 downto 0) := FUNCT7_XOR & FUNCT3_XOR & OP_RTYPE;
  constant INST_OR   : std_logic_vector(16 downto 0) := FUNCT7_OR & FUNCT3_OR & OP_RTYPE;
  constant INST_SLTU : std_logic_vector(16 downto 0) := FUNCT7_SLTU & FUNCT3_SLTU & OP_RTYPE;
  constant INST_SLT  : std_logic_vector(16 downto 0) := FUNCT7_SLT & FUNCT3_SLT & OP_RTYPE;
  constant INST_SRA  : std_logic_vector(16 downto 0) := FUNCT7_SRA & FUNCT3_SRA & OP_RTYPE;
  constant INST_SRL  : std_logic_vector(16 downto 0) := FUNCT7_SRL & FUNCT3_SRL & OP_RTYPE;
  constant INST_SLL  : std_logic_vector(16 downto 0) := FUNCT7_SLL & FUNCT3_SLL & OP_RTYPE;

  -- I-TYPE

  constant INST_ADDI  : std_logic_vector(16 downto 0) := "-------" & FUNCT3_ADDI & OP_ITYPE;
  constant INST_ANDI  : std_logic_vector(16 downto 0) := "-------" & FUNCT3_ANDI & OP_ITYPE;
  constant INST_ORI   : std_logic_vector(16 downto 0) := "-------" & FUNCT3_ORI & OP_ITYPE;
  constant INST_XORI  : std_logic_vector(16 downto 0) := "-------" & FUNCT3_XORI & OP_ITYPE;
  constant INST_SLTI  : std_logic_vector(16 downto 0) := "-------" & FUNCT3_SLTI & OP_ITYPE;
  constant INST_SLTIU : std_logic_vector(16 downto 0) := "-------" & FUNCT3_SLTIU & OP_ITYPE;
  constant INST_SRAI  : std_logic_vector(16 downto 0) := FUNCT7_SRAI & FUNCT3_SRAI & OP_ITYPE;
  constant INST_SRLI  : std_logic_vector(16 downto 0) := FUNCT7_SRLI & FUNCT3_SRLI & OP_ITYPE;
  constant INST_SLLI  : std_logic_vector(16 downto 0) := FUNCT7_SLLI & FUNCT3_SLLI & OP_ITYPE;

  -- BRANCHES

  constant INST_BEQ  : std_logic_vector(16 downto 0) := "-------" & FUNCT3_BEQ & OP_BRANCH;
  constant INST_BNE  : std_logic_vector(16 downto 0) := "-------" & FUNCT3_BNE & OP_BRANCH;
  constant INST_BLT  : std_logic_vector(16 downto 0) := "-------" & FUNCT3_BLT & OP_BRANCH;
  constant INST_BGE  : std_logic_vector(16 downto 0) := "-------" & FUNCT3_BGE & OP_BRANCH;
  constant INST_BLTU : std_logic_vector(16 downto 0) := "-------" & FUNCT3_BLTU & OP_BRANCH;
  constant INST_BGEU : std_logic_vector(16 downto 0) := "-------" & FUNCT3_BGEU & OP_BRANCH;

  -- SPECIAL

  constant INST_LUI   : std_logic_vector(16 downto 0) := "-------" & "---" & OP_LUI;
  constant INST_AUIPC : std_logic_vector(16 downto 0) := "-------" & "---" & OP_AUIPC;

  -- MEMORY

  constant INST_LW : std_logic_vector(16 downto 0) := "-------" & FUNCT3_MEMORY & OP_LW;
  constant INST_SW : std_logic_vector(16 downto 0) := "-------" & FUNCT3_MEMORY & OP_SW;

  -- JUMP

  constant INST_JAL  : std_logic_vector(16 downto 0) := "-------" & "---" & OP_JAL;
  constant INST_JALR : std_logic_vector(16 downto 0) := "-------" & "---" & OP_JALR;




end package;
