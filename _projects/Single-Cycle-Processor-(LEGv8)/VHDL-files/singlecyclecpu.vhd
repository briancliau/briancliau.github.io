library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- STD_LOGIC and STD_LOGIC_VECTOR
use IEEE.numeric_std.ALL; -- to_integer and unsigned

entity SingleCycleCPU is
port(clk :in STD_LOGIC;
     rst :in STD_LOGIC;
     --Probe ports used for testing
     --The current address (AddressOut from the PC)
     DEBUG_PC : out STD_LOGIC_VECTOR(63 downto 0);
     --The current instruction (Instruction output of IMEM)
     DEBUG_INSTRUCTION : out STD_LOGIC_VECTOR(31 downto 0);
     --DEBUG ports from other components
     DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
);
end SingleCycleCPU;

architecture structural of SingleCycleCPU is 
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

     -- PC signals
     signal test_write_enable : std_logic := '1';
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
     signal test_add4 : std_logic_vector(63 downto 0) := x"0000000000000004";
     signal test_add_pc_result : std_logic_vector(63 downto 0);

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
begin 
     test_PC_MUX_Signal <= test_UBranch or (test_CBranch and test_alu_zero);

     DEBUG_INSTRUCTION <= test_Instruction;
     DEBUG_PC <= test_AddressOut;
     DEBUG_TMP_REGS <= test_DEBUG_TMP_REGS;
     DEBUG_SAVED_REGS <= test_DEBUG_SAVED_REGS;
     DEBUG_MEM_CONTENTS <= test_DEBUG_MEM_CONTENTS;
          
     test_pc : pc port map (
          clk => clk,
          write_enable => test_write_enable,
          rst => rst,
          AddressIn => test_AddressIn,
          AddressOut => test_AddressOut
     );

     test_IMEM : IMEM port map (
          Address => test_AddressOut,
          ReadData => test_Instruction
     );

     test_CPUControl : CPUControl port map (
          Opcode => test_Instruction(31 downto 21),
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
          in0 => test_Instruction(20 downto 16),
          in1 => test_Instruction(4 downto 0),
          sel => test_Reg2Loc,
          output => test_RR2
     );

     test_registers : registers port map (
          RR1 => test_Instruction(9 downto 5),
          RR2 => test_RR2,
          WR => test_Instruction(4 downto 0),
          WD => test_WD,
          RegWrite => test_RegWrite,
          Clock => clk,
          RD1 => test_RD1,
          RD2 => test_RD2,
          DEBUG_TMP_REGS => test_DEBUG_TMP_REGS,
          DEBUG_SAVED_REGS => test_DEBUG_SAVED_REGS
     );

     test_SignExtend : SignExtend port map (
          x => test_Instruction,
          y => test_signExtend_result
     );

     test_ShiftLeft2 : ShiftLeft2 port map (
          x => test_signExtend_result, 
          y => test_shift_result
     );

     test_ADD_ALU : add port map (
          carry_in => test_add_carry_in,
          in0 => test_AddressOut,
          in1 => test_shift_result,
          output => test_add_alu_result,
          carry_out => test_add_carry_out
     );

     test_ADD_PC : add port map (
          carry_in => test_add_carry_in,
          in0 => test_AddressOut,
          in1 => test_add4,
          output => test_add_pc_result,
          carry_out => test_add_carry_out
     );

     test_PC_MUX : MUX64 port map (
          in0 => test_add_pc_result,
          in1 => test_add_alu_result,
          sel => test_PC_MUX_Signal,
          output => test_AddressIn
     );

     test_ALU_MUX : MUX64 port map (
          in0 => test_RD2,
          in1 => test_signExtend_result,
          sel => test_ALUSrc,
          output => test_RD_output
     );

     test_ALUControl : ALUControl port map (
          ALUOp => test_ALUOp,
          Opcode => test_Instruction(31 downto 21),
          Operation => test_Operation
     );

     test_ALU : ALU port map (
          in0 => test_RD1,
          in1 => test_RD_output,
          operation => test_Operation,
          result => test_alu_result,
          zero => test_alu_zero,
          overflow => test_alu_overflow
     );

     test_DMEM : DMEM port map (
          WriteData => test_RD2,
          Address => test_alu_result,
          MemRead => test_MemRead,
          MemWrite => test_MemWrite,
          Clock => clk,
          ReadData => test_ReadData_DMEM,
          DEBUG_MEM_CONTENTS => test_DEBUG_MEM_CONTENTS
     );

     test_DMEM_MUX : MUX64 port map (
          in0 => test_alu_result,
          in1 => test_ReadData_DMEM,
          sel => test_MemtoReg,
          output => test_WD
     );

end;