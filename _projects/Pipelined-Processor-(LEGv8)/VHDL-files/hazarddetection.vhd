library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity hazarddetection is
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
end entity;

architecture behavioral of hazarddetection is
begin
    process (Reset, IDEXMemRead, IDEXRt, IFIDRs, IFIDRt) begin
        PCWrite <= '1';
        IFIDWrite <= '1';
        IDEXFlush <= '0';
        
        if Reset = '1' then
            PCwrite <= '1';
            IFIDWrite <= '1';
            IDEXFlush <= '0'; 
        elsif ((IDEXMemRead = '1') and (IDEXRt = IFIDRs or IDEXRt = IFIDRt)) then
            PCwrite <= '0';
            IFIDWrite <= '0';
            IDEXFlush <= '1';            
        end if;
    end process;
end;