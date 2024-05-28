library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.commons.all;
use work.constants.all;

entity controltb is
end entity;

architecture rtl of controltb is


  -- input
  signal clk            : std_logic := '0';
  signal reset : std_logic :='0';
  signal iword   :  std_logic_vector(31 downto 0);
  signal imm :  std_logic_vector(31 downto 0);

  -- out
  signal control_flags: std_logic_vector(5 downto 0);

  -- flags
  signal wbflag           :  std_logic;
  signal memflag          :  std_logic;
  signal pcflag           :  std_logic;

  signal finished : std_logic := '0';

  alias mem_phase : std_logic is control_flags(0);
  alias mem_write : std_logic is control_flags(1);
  alias reg_write : std_logic is control_flags(2);
 
  constant NV : std_logic_vector(31 downto 0) := (others => '0');
  constant R_TYPE_CONTROL : std_logic_vector := "000100";
  constant I_TYPE_CONTROL : std_logic_vector := "010100";
  constant BRANCH_CONTROL : std_logic_vector := "100000";
  constant LW_CONTROL : std_logic_vector := "010101";
  constant SW_CONTROL : std_logic_vector := "010111";
  constant AUIPC_CONTROL :std_logic_vector := "011100";
  constant JUMP_CONTROL : std_logic_vector := "110100";

  -- I-TYPE-Immediates
  constant I1 : std_logic_vector := "000000000000000000000" & "01010101010";
  constant I2 : std_logic_vector := "111111111111111111111" & "11010101010";
  constant I3 : std_logic_vector := "000000000000000000000" & "01110101010";
  constant I4 : std_logic_vector := "111111111111111111111" & "01010111010";
  constant I5 : std_logic_vector := "000000000000000000000" & "11111111111";
  constant I6 : std_logic_vector := "111111111111111111111" & "11010101110";
  constant I7 : std_logic_vector := "000000000000000000000" & "01010111111";
  constant I8 : std_logic_vector := "111111111111111111111" & "11111111010";
  constant I9 : std_logic_vector := "000000000000000000000" & "01010111010";

  constant I1_of_iword : std_logic_vector := "001010101010";
  constant I2_of_iword : std_logic_vector := "111010101010";
  constant I3_of_iword : std_logic_vector := "001110101010";
  constant I4_of_iword : std_logic_vector := "101010111010";
  constant I5_of_iword : std_logic_vector := "011111111111";
  constant I6_of_iword : std_logic_vector := "111010101110";
  constant I7_of_iword : std_logic_vector := "001010111111";
  constant I8_of_iword : std_logic_vector := "111111111010";
  constant I9_of_iword : std_logic_vector := "001010111010";

  constant B1 : std_logic_vector := "00000000000000000000" & "101010101010";
  constant B2 : std_logic_vector := "11111111111111111111" & "011010101010";
  constant B3 : std_logic_vector := "00000000000000000000" & "101110101010";
  constant B4 : std_logic_vector := "11111111111111111111" & "001010111010";
  constant B5 : std_logic_vector := "00000000000000000000" & "111111111110";
  constant B6 : std_logic_vector := "11111111111111111111" & "011010101110";

  constant B1_31_downto_25: std_logic_vector := "0010101";
  constant B1_11_downto_7: std_logic_vector := "01011";

  constant B2_31_downto_25: std_logic_vector := "1110101";
  constant B2_11_downto_7: std_logic_vector := "01010";

  constant B3_31_downto_25: std_logic_vector := "0011101";
  constant B3_11_downto_7: std_logic_vector  := "01011";

  constant B4_31_downto_25: std_logic_vector := "1010101";
  constant B4_11_downto_7: std_logic_vector := "11010";

  constant B5_31_downto_25: std_logic_vector := "0111111";
  constant B5_11_downto_7: std_logic_vector := "11111";

  constant B6_31_downto_25: std_logic_vector := "1110101";
  constant B6_11_downto_7: std_logic_vector := "01110";


  constant U1 :std_logic_vector(31 downto 0) := "01010010101010111111" & "000000000000";
  constant U2 :std_logic_vector(31 downto 0) := "11111110100000001111" & "000000000000";

  constant U1_31_downto_12: std_logic_vector := "01010010101010111111";
  constant U2_31_downto_12: std_logic_vector := "11111110100000001111";

  constant S1 : std_logic_vector(31 downto 0) := "111111111111111111111" & "011010" & "10101";

  constant S1_31_downto_25 : std_logic_vector := "1011010";
  constant S1_11_downto_7  : std_logic_vector := "10101";

  constant J1 : std_logic_vector(31 downto 0) := "000000000000" & "00101100" & "1" & "0010110101" & '0';

  constant J1_31_downto_12 : std_logic_vector(19 downto 0) := "00010110101100101100";

  -- R-TYPE
  constant ADD_iword : std_logic_vector := FUNCT7_ADD & "----------" & FUNCT3_ADD & "-----" & OP_RTYPE;  
  constant AND_iword : std_logic_vector := FUNCT7_AND & "----------" & FUNCT3_AND & "-----" & OP_RTYPE;  
  constant MUL_iword : std_logic_vector := FUNCT7_MUL & "----------" & FUNCT3_MUL & "-----" & OP_RTYPE;  
  constant SUB_iword : std_logic_vector := FUNCT7_SUB & "----------" & FUNCT3_SUB & "-----" & OP_RTYPE;  
  constant XOR_iword : std_logic_vector := FUNCT7_XOR & "----------" & FUNCT3_XOR & "-----" & OP_RTYPE;  
  constant OR_iword : std_logic_vector := FUNCT7_OR & "----------" & FUNCT3_OR & "-----" & OP_RTYPE;  
  constant SLTU_iword : std_logic_vector := FUNCT7_SLTU & "----------" & FUNCT3_SLTU & "-----" & OP_RTYPE;  
  constant SLT_iword : std_logic_vector := FUNCT7_SLT & "----------" & FUNCT3_SLT & "-----" & OP_RTYPE;  
  constant SRA_iword : std_logic_vector := FUNCT7_SRA & "----------" & FUNCT3_SRA & "-----" & OP_RTYPE;  
  constant SRL_iword : std_logic_vector := FUNCT7_SRL & "----------" & FUNCT3_SRL & "-----" & OP_RTYPE;  
  constant SLL_iword : std_logic_vector := FUNCT7_SLL & "----------" & FUNCT3_SLL & "-----" & OP_RTYPE;  

-- I-TYPE
  constant ADDI_iword : std_logic_vector := I1_of_iword & "-----" & FUNCT3_ADDI & "-----" & OP_ITYPE;  
  constant ANDI_iword : std_logic_vector := I2_of_iword & "-----" & FUNCT3_ANDI & "-----" & OP_ITYPE;  
  constant ORI_iword : std_logic_vector := I3_of_iword & "-----" & FUNCT3_ORI & "-----" & OP_ITYPE;  
  constant XORI_iword : std_logic_vector := I4_of_iword & "-----" & FUNCT3_XORI & "-----" & OP_ITYPE;  
  constant SLTI_iword : std_logic_vector := I5_of_iword & "-----" & FUNCT3_SLTI & "-----" & OP_ITYPE;  
  constant SLTIU_iword : std_logic_vector := I6_of_iword & "-----" & FUNCT3_SLTIU & "-----" & OP_ITYPE;  
  constant SRAI_iword : std_logic_vector := I7_of_iword & "-----" & FUNCT3_SRAI & "-----" & OP_ITYPE;  
  constant SRLI_iword : std_logic_vector := I8_of_iword & "-----" & FUNCT3_SRLI & "-----" & OP_ITYPE;  
  constant SLLI_iword : std_logic_vector := I9_of_iword & "-----" & FUNCT3_SLLI & "-----" & OP_ITYPE;
  
-- BRANCH 
  constant BEQ_iword : std_logic_vector  := B1_31_downto_25 & "----------" & FUNCT3_BEQ  &  B1_11_downto_7 & OP_BRANCH;  
  constant BNE_iword : std_logic_vector  := B2_31_downto_25 & "----------" & FUNCT3_BNE  &  B2_11_downto_7 & OP_BRANCH;  
  constant BLT_iword : std_logic_vector  := B3_31_downto_25 & "----------" & FUNCT3_BLT  &  B3_11_downto_7 & OP_BRANCH;  
  constant BGE_iword : std_logic_vector  := B4_31_downto_25 & "----------" & FUNCT3_BGE  &  B4_11_downto_7 & OP_BRANCH;  
  constant BLTU_iword : std_logic_vector := B5_31_downto_25 & "----------" & FUNCT3_BLTU &  B5_11_downto_7 & OP_BRANCH;  
  constant BGEU_iword : std_logic_vector := B6_31_downto_25 & "----------" & FUNCT3_BGEU &  B6_11_downto_7 & OP_BRANCH;
  
-- SPECIAL
  constant LUI_iword : std_logic_vector := U1_31_downto_12 & "-----" & OP_LUI;  
  constant AUIPC_iword : std_logic_vector := U2_31_downto_12 & "-----" & OP_AUIPC;

-- MEMORY
  constant LW_iword : std_logic_vector := I1_of_iword & "-----" & FUNCT3_MEMORY & "-----" & OP_LW;  
  constant SW_iword : std_logic_vector := S1_31_downto_25 & "-----" & "-----" & FUNCT3_MEMORY & S1_11_downto_7 & OP_SW;

-- JUMP
  constant JAL_iword : std_logic_vector := J1_31_downto_12 & "-----" & OP_JAL;  
  constant JALR_iword : std_logic_vector := I2_of_iword & "-----" & "---" & "-----" & OP_JALR;

  type controltest_vector is record

  -- in
   iword   :  std_logic_vector(31 downto 0);
   imm :  std_logic_vector(31 downto 0);
  -- out
   control_flags_out  : std_logic_vector(5 downto 0);
  end record;

  type controltest_vector_array is array (natural range <>) of controltest_vector;
  constant test_vectors       :  controltest_vector_array          := (
    -- instruction | imm | control_flags

    --R-TYPE
    (ADD_iword, NV, R_TYPE_CONTROL),
    (AND_iword, NV, R_TYPE_CONTROL),
    (SUB_iword, NV, R_TYPE_CONTROL),
    (MUL_iword, NV, R_TYPE_CONTROL),
    (XOR_iword, NV, R_TYPE_CONTROL),
    (OR_iword, NV, R_TYPE_CONTROL),
    (SLTU_iword, NV, R_TYPE_CONTROL),
    (SLT_iword, NV, R_TYPE_CONTROL),
    (SRA_iword, NV, R_TYPE_CONTROL),
    (SRL_iword, NV, R_TYPE_CONTROL),
    (SLL_iword, NV, R_TYPE_CONTROL),

    --I-Type
    (ADDI_iword, I1, I_TYPE_CONTROL),
    (ANDI_iword, I2, I_TYPE_CONTROL),
    (ORI_iword, I3, I_TYPE_CONTROL),
    (XORI_iword, I4, I_TYPE_CONTROL),
    (SLTI_iword, I5, I_TYPE_CONTROL),
    (SLTIU_iword, I6, I_TYPE_CONTROL),
    (SRAI_iword, I7, I_TYPE_CONTROL),
    (SRLI_iword, I8, I_TYPE_CONTROL),
    (SLLI_iword, I9, I_TYPE_CONTROL),

    --BRANCHES

    (BEQ_iword, B1, BRANCH_CONTROL),
    (BNE_iword, B2, BRANCH_CONTROL),
    (BLT_iword, B3, BRANCH_CONTROL),
    (BGE_iword, B4, BRANCH_CONTROL),
    (BLTU_iword, B5, BRANCH_CONTROL),
    (BGEU_iword, B6, BRANCH_CONTROL),

    -- SPECIAL
    (LUI_iword, U1, I_TYPE_CONTROL), 
    (AUIPC_iword, U2, AUIPC_CONTROL),

    -- MEMORY
    (LW_iword, I1, LW_CONTROL),
    (SW_iword, S1, SW_CONTROL),

    -- JUMP
    (JAL_iword, J1, JUMP_CONTROL),
    (JALR_iword, I2, JUMP_CONTROL)
    





    
    );

begin
  dut : entity work.control(rtl)
    port map(
      clk         => clk,
      reset      => reset,
      iword  => iword,
      imm   => imm,
      control_flags_out => control_flags,
      wbflag => wbflag,
      memflag => memflag,
      pcflag => pcflag
      );

  tb : process
  begin
    -- Initial reset
    reset <= '1';
    wait for period;
    reset <= '0';
    wait for period;
    -- Reset stage over

    for i in test_vectors'range loop
      iword   <= test_vectors(i).iword;
      wait for period;
      -- Decode
      assert(control_flags = test_vectors(i).control_flags_out)
        report "Test " & integer'image(i) & " failed: Expected instruction_type_out = " & slv_to_bit(test_vectors(i).control_flags_out) & " but was " & slv_to_bit(control_flags)
        severity error;

      -- Immediate Test
      assert(imm = test_vectors(i).imm)
        report "Test " & integer'image(i) & " failed: Expected imm = " & slv_to_bit(test_vectors(i).imm) & " but was " & slv_to_bit(imm)
        severity error;
      

      wait for period;
      -- Execute
      if(mem_phase = '0') then
        assert(pcflag  = '1')
          report "Test " & integer'image(i) & " failed: Expected pc_flag = 1 during Execute Stage but was " & std_logic'image(pcflag) & " in state execute"
          severity error;
      else
        assert(pcflag  = '0')
          report "Test " & integer'image(i) & " failed: Expected pc_flag = 0 during Execute Stage but was " & std_logic'image(pcflag) & " in state execute"
          severity error;
      end if;

      if(mem_phase = '1' and mem_write = '1') then
        assert(memflag = '1')
          report "Test " & integer'image(i) & " failed: Expected memflag = 1 but was " & std_logic'image(memflag) & " in execute state"
          severity error;
      else
        assert(memflag  = '0')
          report "Test " & integer'image(i) & " failed: Expected mem_flag = 0 but was " & std_logic'image(memflag) & " in execute state"
          severity error;
      end if;

      if(mem_phase = '0' and reg_write = '1') then
        assert(wbflag = '1')
          report "Test " & integer'image(i) & " failed: Expected wbflag = 1 but was " & std_logic'image(wbflag) & " in execute state"
          severity error;
      else
        assert(wbflag = '0')
          report "Test " & integer'image(i) & " failed: Expected wbflag = 0 but was "& std_logic'image(wbflag) & " in execute state"
          severity error;
      end if;

      wait for period;
      -- memory or writeback
      if(mem_phase = '1') then
        -- memory
        if(reg_write = '1') then
          assert(wbflag = '1')
            report "Test " & integer'image(i) & " failed: Expected wbflag = 1  but was " & std_logic'image(wbflag) & " in state memory"
            severity error;
        else
          assert(wbflag = '0')
            report "Test " & integer'image(i) & " failed: Expected wbflag = 0 but was " & std_logic'image(wbflag) & " in state memory"
            severity error;
        end if;

        assert(pcflag = '1')
          report "Test " & integer'image(i) & " failed: Expected pcflag = 1 but was " & std_logic'image(pcflag) & " in state memory"
          severity error;

        wait for period;
      end if;

      --writeback
      -- nothing to test here :(
      wait for period;

    end loop;

    report "Testbench finished running";
    finished <= '1';
    wait;
  end process;

  clk <= not clk after half_period when finished = '0';
end rtl;
