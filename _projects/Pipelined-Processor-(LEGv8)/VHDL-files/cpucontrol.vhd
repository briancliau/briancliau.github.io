library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- STD_LOGIC and STD_LOGIC_VECTOR
use IEEE.numeric_std.ALL; -- to_integer and unsigned

entity CPUControl is
-- Functionality should match the truth table shown in Figure 4.22 of the textbook, including the
--    output 'X' values.
-- The truth table in Figure 4.22 omits the unconditional branch instruction:
--    UBranch = '1'
--    MemWrite = RegWrite = '0'
--    all other outputs = 'X'    
port(Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
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
end CPUControl;

architecture behavioral of CPUControl is 
begin
    process(Opcode) begin       
        if Opcode = "10001011000" then --R format ADD
            Reg2Loc <= '0';
            ALUSrc <= '0';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            CBranch <= '0';
            ALUOp(1) <= '1';
            ALUOP(0) <= '0';
            UBranch <= '0';
        elsif Opcode(10 downto 1) = "1001000100" then -- ADDI
            Reg2Loc <= '0';
            ALUSrc <= '1';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            CBranch <= '0';
            ALUOp(1) <= '1';
            ALUOP(0) <= '0';
            UBranch <= '0';
        elsif Opcode(10 downto 5) = "000101" then -- B
            Reg2Loc <= 'X';
            ALUSrc <= 'X';
            MemtoReg <= 'X';
            RegWrite <= '0';
            MemRead <= 'X';
            MemWrite <= '0';
            CBranch <= 'X';
            ALUOp(1) <= 'X';
            ALUOP(0) <= 'X';
            UBranch <= '1';
        elsif Opcode(10 downto 3) = "10110100" then -- CBZ
            Reg2Loc <= '1';
            ALUSrc <= '0';
            MemtoReg <= 'X';
            RegWrite <= '0';
            MemRead <= '0';
            MemWrite <= '0';
            CBranch <= '1';
            ALUOp(1) <= '0';
            ALUOP(0) <= '1';
            UBranch <= '0';
        elsif Opcode(10 downto 3) = "10110101" then -- CBNZ
            Reg2Loc <= '1';
            ALUSrc <= '0';
            MemtoReg <= 'X';
            RegWrite <= '0';
            MemRead <= '0';
            MemWrite <= '0';
            CBranch <= '1';
            ALUOp(1) <= '0';
            ALUOP(0) <= '1';
            UBranch <= '0';
        elsif Opcode = "11111000010" then -- LDUR
            Reg2Loc <= 'X';
            ALUSrc <= '1';
            MemtoReg <= '1';
            RegWrite <= '1';
            MemRead <= '1';
            MemWrite <= '0';
            CBranch <= '0';
            ALUOp(1) <= '0';
            ALUOP(0) <= '0';
            UBranch <= '0';
        elsif Opcode = "11111000000" then -- STUR
            Reg2Loc <= '1';
            ALUSrc <= '1';
            MemtoReg <= 'X';
            RegWrite <= '0';
            MemRead <= '0';
            MemWrite <= '1';
            CBranch <= '0';
            ALUOp(1) <= '0';
            ALUOP(0) <= '0';
            UBranch <= '0';
        elsif Opcode = "11001011000" then -- SUB
            Reg2Loc <= '0';
            ALUSrc <= '0';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            CBranch <= '0';
            ALUOp(1) <= '1';
            ALUOP(0) <= '0';
            UBranch <= '0';
        elsif Opcode(10 downto 1) = "1101000100" then -- SUBI
            Reg2Loc <= '0';
            ALUSrc <= '1';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            CBranch <= '0';
            ALUOp(1) <= '1';
            ALUOP(0) <= '0';
            UBranch <= '0';
        elsif Opcode(10 downto 1) = "1001001000" then -- ANDI
            Reg2Loc <= '0';
            ALUSrc <= '1';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            CBranch <= '0';
            ALUOp(1) <= '1';
            ALUOP(0) <= '0';
            UBranch <= '0';
        elsif Opcode(10 downto 1) = "1011001000" then -- ORRI
            Reg2Loc <= '0';
            ALUSrc <= '1';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            CBranch <= '0';
            ALUOp(1) <= '1';
            ALUOP(0) <= '0';
            UBranch <= '0';
        elsif Opcode = "10001010000" then -- AND
            Reg2Loc <= '0';
            ALUSrc <= '0';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            CBranch <= '0';
            ALUOp(1) <= '1';
            ALUOP(0) <= '0';
            UBranch <= '0';
        elsif Opcode = "10101010000" then -- ORR
            Reg2Loc <= '0';
            ALUSrc <= '0';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            CBranch <= '0';
            ALUOp(1) <= '1';
            ALUOP(0) <= '0';
            UBranch <= '0';
        elsif Opcode = "11010011011" then -- LSL
            Reg2Loc <= '0';
            ALUSrc <= '0';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            CBranch <= '0';
            ALUOp(1) <= '1';
            ALUOP(0) <= '0';
            UBranch <= '0';
        elsif Opcode = "11010011010" then -- LSR
            Reg2Loc <= '0';
            ALUSrc <= '0';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            CBranch <= '0';
            ALUOp(1) <= '1';
            ALUOP(0) <= '0';
            UBranch <= '0';
        elsif Opcode = "00000000000" then -- NOP
            Reg2Loc <= '0';
            ALUSrc <= '0';
            MemtoReg <= 'X';
            RegWrite <= '0';
            MemRead <= '0';
            MemWrite <= '0';
            CBranch <= '0';
            ALUOp(1) <= '0';
            ALUOP(0) <= '0';
            UBranch <= '0';
        else
            Reg2Loc <= 'U';
            ALUSrc <= 'U';
            MemtoReg <= 'U';
            RegWrite <= 'U';
            MemRead <= 'U';
            MemWrite <= 'U';
            CBranch <= 'U';
            ALUOp(1) <= 'U';
            ALUOP(0) <= 'U';
            UBranch <= 'U';
        end if;

    end process;
end;