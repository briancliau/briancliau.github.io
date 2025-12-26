library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity EXMEMcpucontrol is 
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
end entity;

architecture behavioral of EXMEMcpucontrol is
begin
    process (all) begin
        if reset = '1' then
            outCBranch <= '0';
            outMemRead <= '0';
            outMemtoReg <= '0';
            outMemWrite <= '0';
            outRegWrite <= '0';
            outUBranch <= '0';
        end if;

        if rising_edge(clock) then
            outCBranch <= inCBranch;
            outMemRead <= inMemRead;
            outMemtoReg <= inMemtoReg;
            outMemWrite <= inMemWrite;
            outRegWrite <= inRegWrite;
            outUBranch <= inUBranch;
        end if;
    end process;
end;