library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- STD_LOGIC and STD_LOGIC_VECTOR
use IEEE.numeric_std.ALL; -- to_integer and unsigned

entity controlMUX is port(
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
end controlMUX;

architecture behavioral of controlMUX is 
begin
    process (all) begin 
        if (selection = '0') then
            outCBranch  <= inCBranch;
            outMemRead  <= inMemRead;
            outMemtoReg <= inMemtoReg;
            outMemWrite <= inMemWrite;
            outALUSrc   <= inALUSrc;
            outRegWrite <= inRegWrite;
            outUBranch  <= inUBranch;
            outALUOp    <= inALUOp;
        else 
            outCBranch  <= '0';
            outMemRead  <= '0';
            outMemtoReg <= 'X';
            outMemWrite <= '0';
            outALUSrc   <= '0';
            outRegWrite <= '0';
            outUBranch  <= '0';
            outALUOp    <= "00";
        end if;
    end process;
end;