library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity PipelinedCPU1 is
port(
    clk :in std_logic;
    rst :in std_logic;
    --Probe ports used for testing
    -- Forwarding control signals
    DEBUG_FORWARDA : out std_logic_vector(1 downto 0);
    DEBUG_FORWARDB : out std_logic_vector(1 downto 0);
    --The current address (AddressOut from the PC)
    DEBUG_PC : out std_logic_vector(63 downto 0);
    --Value of PC.write_enable
    DEBUG_PC_WRITE_ENABLE : out STD_LOGIC;
    --The current instruction (Instruction output of IMEM)
    DEBUG_INSTRUCTION : out std_logic_vector(31 downto 0);
    --DEBUG ports from other components
    DEBUG_TMP_REGS : out std_logic_vector(64*4-1 downto 0);
    DEBUG_SAVED_REGS : out std_logic_vector(64*4-1 downto 0);
    DEBUG_MEM_CONTENTS : out std_logic_vector(64*4-1 downto 0)
    );
end PipelinedCPU1;

architecture structural of PipelinedCPU1 is 
     component pc is 
          port (
               clk : in STD_LOGIC; -- Propogate AddressIn to AddressOut on rising edge of clock
               write_enable : in STD_LOGIC; -- Only write if ’1’
               rst : in STD_LOGIC; -- Asynchronous reset! Sets AddressOut to 0x0
               AddressIn : in STD_LOGIC_VECTOR(63 downto 0); -- Next PC address
               AddressOut : out STD_LOGIC_VECTOR(63 downto 0) -- Current PC address
          );
     end component;

     component IMEM is 
          generic(NUM_BYTES : integer := 64);
          port (
               Address  : in  STD_LOGIC_VECTOR(63 downto 0); -- Address to read from
               ReadData : out STD_LOGIC_VECTOR(31 downto 0)
          );
     end component;

     component CPUControl is 
          port (
               Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
               Reg2Loc   : out STD_LOGIC;
               CBranch  : out STD_LOGIC;  --conditional
               MemRead  : out STD_LOGIC;
               MemtoReg : out STD_LOGIC;
               MemWrite : out STD_LOGIC;
               ALUSrc   : out STD_LOGIC;
               RegWrite : out STD_LOGIC;
               UBranch  : out STD_LOGIC; -- This is unconditional
               ALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
          );
     end component;

     component registers is 
          port (
               RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
               RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
               WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
               WD       : in  STD_LOGIC_VECTOR (63 downto 0);
               RegWrite : in  STD_LOGIC;
               Clock    : in  STD_LOGIC;
               RD1      : out STD_LOGIC_VECTOR (63 downto 0);
               RD2      : out STD_LOGIC_VECTOR (63 downto 0);
               DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
               DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
          );
     end component;

     component SignExtend is
          port (
               x : in  STD_LOGIC_VECTOR(31 downto 0);
               y : out STD_LOGIC_VECTOR(63 downto 0) -- sign-extend(x)
          );
     end component;

     component add is
          port (
               carry_in : in STD_LOGIC;
               in0    : in  STD_LOGIC_VECTOR(63 downto 0);
               in1    : in  STD_LOGIC_VECTOR(63 downto 0);
               output : out STD_LOGIC_VECTOR(63 downto 0);
               carry_out : out STD_LOGIC
          );
     end component;

     component ShiftLeft2 is
          port (
               x : in  STD_LOGIC_VECTOR(63 downto 0);
               y : out STD_LOGIC_VECTOR(63 downto 0) -- x << 2
          );
     end component;

     component ALUControl is 
          port (
               ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
               Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
               Operation : out STD_LOGIC_VECTOR(3 downto 0)
          );
     end component;

     component ALU is 
          port (
               in0       : in     STD_LOGIC_VECTOR(63 downto 0);
               in1       : in     STD_LOGIC_VECTOR(63 downto 0);
               operation : in     STD_LOGIC_VECTOR(3 downto 0);
               instruction : in   std_logic_vector(31 downto 0);
               result    : buffer STD_LOGIC_VECTOR(63 downto 0);
               zero      : buffer STD_LOGIC;
               overflow  : buffer STD_LOGIC
          );
     end component;

     component DMEM is 
          port (
               WriteData          : in  STD_LOGIC_VECTOR(63 downto 0); -- Input data
               Address            : in  STD_LOGIC_VECTOR(63 downto 0); -- Read/Write address
               MemRead            : in  STD_LOGIC; -- Indicates a read operation
               MemWrite           : in  STD_LOGIC; -- Indicates a write operation
               Clock              : in  STD_LOGIC; -- Writes are triggered by a rising edge
               ReadData           : out STD_LOGIC_VECTOR(63 downto 0); -- Output data
               DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
          );
     end component;

     component MUX5 is 
          port (
               in0    : in STD_LOGIC_VECTOR(4 downto 0); -- sel == 0
               in1    : in STD_LOGIC_VECTOR(4 downto 0); -- sel == 1
               sel    : in STD_LOGIC; -- selects in0 or in1
               output : out STD_LOGIC_VECTOR(4 downto 0)
          );
     end component;

     component MUX64 is 
          port (
               in0    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 0
               in1    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 1
               sel    : in STD_LOGIC; -- selects in0 or in1
               output : out STD_LOGIC_VECTOR(63 downto 0)
          );
     end component;

     component register1 is 
          port (
               clock : in std_logic;
               reset : in std_logic;
               in1 : in std_logic;
               out1 : out std_logic
          );
     end component;

     component register5 is 
          port (
               clock : in std_logic;
               reset : in std_logic;
               in5 : in std_logic_vector(4 downto 0);
               out5 : out std_logic_vector(4 downto 0)
          );
     end component;

     component register11 is 
          port (
               clock : in std_logic;
               reset : in std_logic;
               in11 : in std_logic_vector(10 downto 0);
               out11 : out std_logic_vector(10 downto 0)
          );
     end component;

     component register32 is 
          port (
               clock : in std_logic;
               reset : in std_logic;
               in32 : in std_logic_vector(31 downto 0);
               out32 : out std_logic_vector(31 downto 0)
          );
     end component;

     component register64 is 
          port (
               clock : in std_logic;
               reset : in std_logic;
               in64 : in std_logic_vector(63 downto 0);
               out64 : out std_logic_vector(63 downto 0)
          );
     end component;

     component IDEXcpucontrol is 
          port (
               clock : in std_logic;
               reset : in std_logic;
               inCBranch : in std_logic;
               outCBranch : out std_logic;
               inMemRead : in std_logic;
               outMemRead  : out STD_LOGIC;
               inMemtoReg : in std_logic;
               outMemtoReg : out STD_LOGIC;
               inMemWrite : in std_logic;
               outMemWrite : out STD_LOGIC;
               inALUSrc : in std_logic;
               outALUSrc   : out STD_LOGIC;
               inRegWrite : in std_logic;
               outRegWrite : out STD_LOGIC;
               inUBranch : in std_logic;
               outUBranch  : out STD_LOGIC;
               inALUOp    : in STD_LOGIC_VECTOR(1 downto 0);
               outALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
          );
     end component;

     component EXMEMcpucontrol is 
          port (
               clock : in std_logic;
               reset : in std_logic;
               inCBranch : in std_logic;
               outCBranch : out std_logic;
               inMemRead : in std_logic;
               outMemRead  : out STD_LOGIC;
               inMemtoReg : in std_logic;
               outMemtoReg : out STD_LOGIC;
               inMemWrite : in std_logic;
               outMemWrite : out STD_LOGIC;
               inRegWrite : in std_logic;
               outRegWrite : out STD_LOGIC;
               inUBranch : in std_logic;
               outUBranch  : out STD_LOGIC
          );
     end component;

     component hazarddetection is
          port (
               Reset : in std_logic;
               IDEXMemRead : in std_logic;
               IDEXRt : in std_logic_vector(4 downto 0);
               IFIDRs : in std_logic_vector(4 downto 0);
               IFIDRt : in std_logic_vector(4 downto 0);
               PCwrite : out std_logic;
               IFIDWrite : out std_logic;
               IDEXFlush : out std_logic
          );
     end component;

     component forwardingUnit is
          port (
               Reset : in std_logic;
               EXMEMRegRd : in std_logic_vector(4 downto 0);
               EXMEMRegWrite : in std_logic;
               MEMWBRegRd : in std_logic_vector(4 downto 0);
               MEMWBRegWrite : in std_logic;
               Rm : in std_logic_vector(4 downto 0);
               Rn : in std_logic_vector(4 downto 0);
               ForwardA : out std_logic_vector(1 downto 0);
               ForwardB : out std_logic_vector(1 downto 0)
          );
     end component;

     component controlMUX is 
          port(
               selection   : in STD_LOGIC;
               inCBranch   : in STD_LOGIC;
               inMemRead   : in STD_LOGIC;
               inMemtoReg  : in STD_LOGIC;
               inMemWrite  : in STD_LOGIC;
               inALUSrc    : in STD_LOGIC;
               inRegWrite  : in STD_LOGIC;
               inUBranch   : in STD_LOGIC;
               inALUOp     : in STD_LOGIC_VECTOR(1 downto 0);
               outCBranch  : out STD_LOGIC;
               outMemRead  : out STD_LOGIC;
               outMemtoReg : out STD_LOGIC;
               outMemWrite : out STD_LOGIC;
               outALUSrc   : out STD_LOGIC;
               outRegWrite : out STD_LOGIC;
               outUBranch  : out STD_LOGIC;
               outALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
          );
     end component;

     component mux_3 is
          port(
          in0    : in STD_LOGIC_VECTOR(63 downto 0);
          in1    : in STD_LOGIC_VECTOR(63 downto 0); 
          in2    : in STD_LOGIC_VECTOR(63 downto 0);
          sel    : in STD_LOGIC_VECTOR(1 downto 0);
          output : out STD_LOGIC_VECTOR(63 downto 0)
          );
     end component;

     component IFID_register32 is 
          port (
               clock : in std_logic;
               reset : in std_logic;
               IFIDWrite : in std_logic;
               in32 : in std_logic_vector(31 downto 0);
               out32 : out std_logic_vector(31 downto 0)
          );
     end component;

     component IFID_register64 is 
          port (
               clock : in std_logic;
               reset : in std_logic;
               IFIDWrite : in std_logic;
               in64 : in std_logic_vector(63 downto 0);
               out64 : out std_logic_vector(63 downto 0)
          );
     end component;

     component add_value is 
          port (
               PCwrite : in std_logic;
               added_value : out std_logic_vector(63 downto 0)
          );
     end component;

     -- PC signals
     signal test_AddressIn : std_logic_vector(63 downto 0) := x"0000000000000000";
     signal test_AddressOut : std_logic_vector(63 downto 0) := x"0000000000000000";

     -- IMEM signals
     signal test_Instruction : std_logic_vector(31 downto 0);

     -- CPUControl signals
     signal test_Opcode : std_logic_vector(10 downto 0);
     signal test_Reg2Loc : std_logic;
     signal test_CBranch : std_logic;
     signal test_MemRead : std_logic;
     signal test_MemtoReg : std_logic;
     signal test_MemWrite : std_logic;
     signal test_ALUSrc : std_logic;
     signal test_RegWrite : std_logic;
     signal test_UBranch : std_logic;
     signal test_ALUOp : std_logic_vector(1 downto 0);

     -- Registers signals
     signal test_RR2 : std_logic_vector(4 downto 0) := (others => '0');
     signal test_WD : std_logic_vector(63 downto 0) := (others => '0');
     signal test_RD1 : std_logic_vector(63 downto 0);
     signal test_RD2 : std_logic_vector(63 downto 0);

     -- SignExtend signals
     signal test_signExtend_result : std_logic_vector(63 downto 0);

     -- ADD signals
     signal test_add_carry_in : std_logic := '0';
     signal test_add_alu_result : std_logic_vector(63 downto 0);
     signal test_add_carry_out : std_logic;
     signal test_added_value : std_logic_vector(63 downto 0);
     signal test_add_pc_result : std_logic_vector(63 downto 0);
     signal test_add_four : std_logic_vector(63 downto 0) := x"0000000000000004";

     -- ShiftLeft2 signals
     signal test_shift_result : std_logic_vector(63 downto 0);

     -- ALUControl signals
     signal test_Operation : std_logic_vector(3 downto 0);

     -- ALU signals
     signal test_alu_result : std_logic_vector(63 downto 0);
     signal test_alu_zero : std_logic;
     signal test_alu_overflow : std_logic;

     -- DMEM signals
     signal test_ReadData_DMEM : std_logic_vector(63 downto 0);
     signal test_DEBUG_MEM_CONTENTS : std_logic_vector(64*4 - 1 downto 0);

     -- MUX signals
     signal test_PC_MUX_Signal : std_logic;
     signal test_RD_output : std_logic_vector(63 downto 0);

     -- Debug signals
     signal test_DEBUG_PC : std_logic_vector(63 downto 0);
     signal test_DEBUG_INSTRUCTION : std_logic_vector(31 downto 0);
     signal test_DEBUG_TMP_REGS : std_logic_vector(64*4 - 1 downto 0);
     signal test_DEBUG_SAVED_REGS : std_logic_vector(64*4 - 1 downto 0);

     -- IF / ID register signals
     signal test_IFID_Instruction : std_logic_vector(31 downto 0);
     signal test_IFID_PC : std_logic_vector(63 downto 0);

     -- ID / EX register signals
     signal test_IDEX_SignExtended : std_logic_vector(63 downto 0);
     signal test_IDEX_Instruction : std_logic_vector(31 downto 0);
     signal test_IDEX_ALUControl : std_logic_vector(10 downto 0);
     signal test_IDEX_WR : std_logic_vector(4 downto 0);
     signal test_IDEX_PC : std_logic_vector(63 downto 0);
     signal test_IDEX_RD1 : std_logic_vector(63 downto 0);
     signal test_IDEX_RD2 : std_logic_vector(63 downto 0);
     signal test_IDEX_RegWrite : std_logic;
     signal test_IDEX_ALUSrc : std_logic;
     signal test_IDEX_ALUOp : std_logic_vector(1 downto 0);
     signal test_IDEX_MemWrite : std_logic;
     signal test_IDEX_MemRead : std_logic;
     signal test_IDEX_MemtoReg : std_logic;
     signal test_IDEX_CBranch : std_logic;
     signal test_IDEX_UBranch : std_logic;
     signal test_IDEX_RRn : std_logic_vector(4 downto 0);
     signal test_IDEX_RRm : std_logic_vector(4 downto 0);

     -- EX / MEM register signals
     signal test_EXMEM_WR : std_logic_vector(4 downto 0);
     signal test_EXMEM_alu_result : std_logic_vector(63 downto 0);
     signal test_EXMEM_add_alu_result : std_logic_vector(63 downto 0);
     signal test_EXMEM_RD2 : std_logic_vector(63 downto 0);
     signal test_EXMEM_alu_zero : std_logic;
     signal test_EXMEM_CBranch : std_logic;
     signal test_EXMEM_UBranch : std_logic;
     signal test_EXMEM_MemWrite : std_logic;
     signal test_EXMEM_MemtoReg : std_logic;
     signal test_EXMEM_MemRead : std_logic;
     signal test_EXMEM_RegWrite : std_logic;

     -- MEM / WB
     signal test_MEMWB_alu_result : std_logic_vector(63 downto 0);
     signal test_MEMWB_ReadData_DMEM : std_logic_vector(63 downto 0);
     signal test_MEMWB_MemtoReg : std_logic;
     signal test_MEMWB_RegWrite: std_logic;
     signal test_MEMWB_WR : std_logic_vector(4 downto 0);

     -- Hazard Detection Unit
     signal test_PCwrite : std_logic := '1';
     signal test_IFIDWrite : std_logic := '1';
     signal test_IDEXFlush : std_logic := '0';

     -- Forwarding Unit 
     signal test_ForwardA : std_logic_vector(1 downto 0) := "00";
     signal test_ForwardB : std_logic_vector(1 downto 0) := "00";

     -- Control MUX
     signal test_outCBranch  : STD_LOGIC;
     signal test_outMemRead  : STD_LOGIC;
     signal test_outMemtoReg : STD_LOGIC;
     signal test_outMemWrite : STD_LOGIC;
     signal test_outALUSrc   : STD_LOGIC;
     signal test_outRegWrite : STD_LOGIC;
     signal test_outUBranch  : STD_LOGIC;
     signal test_outALUOp    : STD_LOGIC_VECTOR(1 downto 0);

     -- Forward MUXs
     signal test_ForwardA_result : std_logic_vector(63 downto 0) := x"0000000000000000";
     signal test_ForwardB_result : std_logic_vector(63 downto 0) := x"0000000000000000";

begin 
     test_PC_MUX_Signal <= test_EXMEM_UBranch or (test_EXMEM_CBranch and test_EXMEM_alu_zero);

     DEBUG_INSTRUCTION <= test_Instruction;
     DEBUG_PC <= test_AddressOut;
     DEBUG_TMP_REGS <= test_DEBUG_TMP_REGS;
     DEBUG_SAVED_REGS <= test_DEBUG_SAVED_REGS;
     DEBUG_MEM_CONTENTS <= test_DEBUG_MEM_CONTENTS;
     DEBUG_FORWARDA <= test_ForwardA;
     DEBUG_FORWARDB <= test_ForwardB;
          
     test_pc : pc port map (
          clk => clk,
          write_enable => test_PCwrite,
          rst => rst,
          AddressIn => test_AddressIn,
          AddressOut => test_AddressOut
     );

     test_IMEM : IMEM port map (
          Address => test_AddressOut,
          ReadData => test_Instruction
     );

     test_CPUControl : CPUControl port map (
          Opcode => test_IFID_Instruction(31 downto 21),
          Reg2Loc => test_Reg2Loc,
          CBranch => test_CBranch,
          MemRead => test_MemRead,
          MemtoReg => test_MemtoReg,
          MemWrite => test_MemWrite,
          ALUSrc => test_ALUSrc,
          RegWrite => test_RegWrite,
          UBranch => test_UBranch,
          ALUOp => test_ALUOp
     );

     test_reg2_mux : MUX5 port map (
          in0 => test_IFID_Instruction(20 downto 16),
          in1 => test_IFID_Instruction(4 downto 0),
          sel => test_Reg2Loc,
          output => test_RR2
     );

     test_registers : registers port map (
          RR1 => test_IFID_Instruction(9 downto 5),
          RR2 => test_RR2,
          WR => test_MEMWB_WR,
          WD => test_WD,
          RegWrite => test_MEMWB_RegWrite,
          Clock => clk,
          RD1 => test_RD1,
          RD2 => test_RD2,
          DEBUG_TMP_REGS => test_DEBUG_TMP_REGS,
          DEBUG_SAVED_REGS => test_DEBUG_SAVED_REGS
     );

     test_SignExtend : SignExtend port map (
          x => test_IFID_Instruction,
          y => test_signExtend_result
     );

     test_ShiftLeft2 : ShiftLeft2 port map (
          x => test_IDEX_SignExtended, 
          y => test_shift_result
     );

     test_ADD_ALU : add port map (
          carry_in => test_add_carry_in,
          in0 => test_IDEX_PC,
          in1 => test_shift_result,
          output => test_add_alu_result,
          carry_out => test_add_carry_out
     );

     test_ADD_PC : add port map (
          carry_in => test_add_carry_in,
          in0 => test_AddressOut,
          in1 => test_added_value,
          output => test_add_pc_result,
          carry_out => test_add_carry_out
     );

     test_PC_MUX : MUX64 port map (
          in0 => test_add_pc_result,
          in1 => test_EXMEM_add_alu_result,
          sel => test_PC_MUX_Signal,
          output => test_AddressIn
     );

     test_ALU_MUX : MUX64 port map (
          in0 => test_ForwardB_result,
          in1 => test_IDEX_SignExtended,
          sel => test_IDEX_ALUSrc,
          output => test_RD_output
     );

     test_ALUControl : ALUControl port map (
          ALUOp => test_IDEX_ALUOp,
          Opcode => test_IDEX_ALUControl,
          Operation => test_Operation
     );

     test_ALU : ALU port map (
          in0 => test_ForwardA_result,
          in1 => test_RD_output,
          operation => test_Operation,
          instruction => test_IDEX_Instruction,
          result => test_alu_result,
          zero => test_alu_zero,
          overflow => test_alu_overflow
     );

     test_DMEM : DMEM port map (
          WriteData => test_EXMEM_RD2,
          Address => test_EXMEM_alu_result,
          MemRead => test_EXMEM_MemRead,
          MemWrite => test_EXMEM_MemWrite,
          Clock => clk,
          ReadData => test_ReadData_DMEM,
          DEBUG_MEM_CONTENTS => test_DEBUG_MEM_CONTENTS
     );

     test_DMEM_MUX : MUX64 port map (
          in0 => test_MEMWB_alu_result,
          in1 => test_MEMWB_ReadData_DMEM,
          sel => test_MEMWB_MemtoReg,
          output => test_WD
     );

     test_IFID_Instruction_reg : IFID_register32 port map (
          clock => clk,
          reset => rst,
          IFIDWrite => test_IFIDWrite,
          in32 => test_Instruction,
          out32 => test_IFID_Instruction
     );

     test_PC_IFID : IFID_register64 port map (
          clock => clk,
          reset => rst,
          IFIDWrite => test_IFIDWrite,
          in64 => test_AddressOut,
          out64 => test_IFID_PC
     );

     test_IDEXcpucontrol : IDEXcpucontrol port map (
          clock => clk,
          reset => rst,
          inCBranch => test_outCBranch,
          outCBranch => test_IDEX_CBranch,
          inMemRead => test_outMemRead,
          outMemRead => test_IDEX_MemRead,
          inMemtoReg => test_outMemtoReg,
          outMemtoReg => test_IDEX_MemtoReg,
          inMemWrite => test_outMemWrite,
          outMemWrite => test_IDEX_MemWrite,
          inALUSrc => test_outALUSrc,
          outALUSrc => test_IDEX_ALUSrc,
          inRegWrite => test_outRegWrite,
          outRegWrite => test_IDEX_RegWrite,
          inUBranch => test_outUBranch,
          outUBranch => test_IDEX_UBranch,
          inALUOp => test_outALUOp,
          outALUOp => test_IDEX_ALUOp
     );

     test_RD1_IDEX : register64 port map (
          clock => clk,
          reset => rst,
          in64 => test_RD1,
          out64 => test_IDEX_RD1
     );

     test_RD2_IDEX : register64 port map (
          clock => clk,
          reset => rst,
          in64 => test_RD2,
          out64 => test_IDEX_RD2
     );

     test_SignExtend_IDEX : register64 port map (
          clock => clk,
          reset => rst,
          in64 => test_signExtend_result,
          out64 => test_IDEX_SignExtended
     );

     test_WR_IDEX : register5 port map (
          clock => clk,
          reset => rst,
          in5 => test_IFID_Instruction(4 downto 0),
          out5 => test_IDEX_WR
     );

     test_ALUControl_IDEX : register11 port map (
          clock => clk,
          reset => rst,
          in11 => test_IFID_Instruction(31 downto 21),
          out11 => test_IDEX_ALUControl
     );

     test_PC_IDEX : register64 port map (
          clock => clk,
          reset => rst,
          in64 => test_IFID_PC,
          out64 => test_IDEX_PC
     );

     test_Instructions_IDEX : register32 port map (
          clock => clk,
          reset => rst,
          in32 => test_IFID_Instruction,
          out32 => test_IDEX_Instruction
     );

     test_WR_EXMEM : register5 port map (
          clock => clk,
          reset => rst,
          in5 => test_IDEX_WR,
          out5 => test_EXMEM_WR
     );

     test_ALU_EXMEM : register64 port map (
          clock => clk,
          reset => rst,
          in64 => test_alu_result,
          out64 => test_EXMEM_alu_result
     );

     test_ADD_ALU_EXMEM : register64 port map (
          clock => clk,
          reset => rst,
          in64 => test_add_alu_result,
          out64 => test_EXMEM_add_alu_result
     );

     test_ALU_Zero_EXMEM : register1 port map (
          clock => clk,
          reset => rst,
          in1 => test_alu_zero,
          out1 => test_EXMEM_alu_zero
     );

     test_EXMEMcpucontrol : EXMEMcpucontrol port map (
          clock => clk,
          reset => rst,
          inCBranch => test_IDEX_CBranch,
          outCBranch => test_EXMEM_CBranch,
          inMemRead => test_IDEX_MemRead,
          outMemRead => test_EXMEM_MemRead,
          inMemtoReg => test_IDEX_MemtoReg,
          outMemtoReg => test_EXMEM_MemtoReg,
          inMemWrite => test_IDEX_MemWrite,
          outMemWrite => test_EXMEM_MemWrite,
          inRegWrite => test_IDEX_RegWrite,
          outRegWrite => test_EXMEM_RegWrite,
          inUBranch => test_IDEX_UBranch,
          outUBranch => test_EXMEM_UBranch
     );

     test_RD2_EXMEM : register64 port map (
          clock => clk,
          reset => rst,
          in64 => test_ForwardB_result,
          out64 => test_EXMEM_RD2
     );

     test_WR_MEMWB : register5 port map (
          clock => clk,
          reset => rst,
          in5 => test_EXMEM_WR,
          out5 => test_MEMWB_WR
     );

     test_alu_result_MEMWB : register64 port map (
          clock => clk,
          reset => rst,
          in64 => test_EXMEM_alu_result,
          out64 => test_MEMWB_alu_result
     );

     test_ReadData_DMEM_MEMWB : register64 port map (
          clock => clk,
          reset => rst,
          in64 => test_ReadData_DMEM,
          out64 => test_MEMWB_ReadData_DMEM
     );
     
     test_MemtoReg_MEMWB : register1 port map (
          clock => clk,
          reset => rst,
          in1 => test_EXMEM_MemtoReg,
          out1 => test_MEMWB_MemtoReg
     );

     test_RegWrite_MEMWB : register1 port map (
          clock => clk,
          reset => rst,
          in1 => test_EXMEM_RegWrite,
          out1 => test_MEMWB_RegWrite
     );

     test_IDEX_RR1 : register5 port map (
          clock => clk,
          reset => rst,
          in5 => test_IFID_Instruction(9 downto 5),
          out5 => test_IDEX_RRn
     );

     test_IDEX_RR2 : register5 port map (
          clock => clk,
          reset => rst,
          in5 => test_RR2,
          out5 => test_IDEX_RRm
     );

     test_hazarddetection: hazarddetection port map (
          Reset => rst,
          IDEXMemRead => test_IDEX_MemRead,
          IDEXRt => test_IDEX_WR,
          IFIDRs => test_IFID_Instruction(9 downto 5),
          IFIDRt => test_RR2,
          PCwrite => test_PCwrite,
          IFIDWrite => test_IFIDWrite,
          IDEXFlush => test_IDEXFlush
     );

     test_forwardunit : forwardingUnit port map (
          Reset => rst,
          EXMEMRegRd => test_EXMEM_WR,
          EXMEMRegWrite => test_EXMEM_RegWrite,
          MEMWBRegRd => test_MEMWB_WR,
          MEMWBRegWrite => test_MEMWB_RegWrite,
          Rm => test_IDEX_RRm,
          Rn => test_IDEX_RRn,
          ForwardA => test_ForwardA,
          ForwardB => test_ForwardB
     );

     test_controlMUX : controlMUX port map (
          selection => test_IDEXFlush,
          inCBranch => test_CBranch,
          inMemRead => test_MemRead,
          inMemtoReg => test_MemtoReg,
          inMemWrite => test_MemWrite,
          inALUSrc => test_ALUSrc,
          inRegWrite => test_RegWrite,
          inUBranch => test_UBranch,
          inALUOp => test_ALUOp,
          outCBranch => test_outCBranch,
          outMemRead => test_outMemRead,
          outMemtoReg => test_outMemtoReg,
          outMemWrite => test_outMemWrite,
          outALUSrc => test_outALUSrc,
          outRegWrite => test_outRegWrite,
          outUBranch => test_outUBranch,
          outALUOp => test_outALUOp
     );

     test_ForwardAMUX : mux_3 port map (
          in0 => test_IDEX_RD1, 
          in1 => test_WD,
          in2 => test_EXMEM_alu_result,
          sel => test_ForwardA,
          output => test_ForwardA_result
     );

     test_ForwardBMUX : mux_3 port map (
          in0 => test_IDEX_RD2, 
          in1 => test_WD,
          in2 => test_EXMEM_alu_result,
          sel => test_ForwardB,
          output => test_ForwardB_result
     );

     test_PC_add_value : add_value port map (
          PCwrite => test_PCwrite,
          added_value => test_added_value
     );
     
end;
