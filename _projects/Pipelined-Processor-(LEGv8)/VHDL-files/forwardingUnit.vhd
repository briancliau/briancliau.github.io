library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity forwardingUnit is 
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
end entity;

architecture behavioral of forwardingUnit is
begin
    process (all) begin
        ForwardA <= "00";
        ForwardB <= "00";
        
        if (Reset = '1') then 
            ForwardA <= "00";
            ForwardB <= "00";
        end if;
        
        if (EXMEMRegWrite = '1' and (EXMEMRegRd /= "11111") and (EXMEMRegRd = Rn)) then
            ForwardA <= "10";
        elsif (MEMWBRegWrite = '1' and (MEMWBRegRd /= "11111") and 
        not((EXMEMRegWrite = '1' and (EXMEMRegRd /= "11111") and (EXMEMRegRd = Rn)))
        and (MEMWBRegRd = Rn)) then
            ForwardA <= "01";
        end if;

        if (EXMEMRegWrite = '1' and (EXMEMRegRd /= "11111") and (EXMEMRegRd = Rm)) then
            ForwardB <= "10";
        elsif (MEMWBRegWrite = '1' and (MEMWBRegRd /= "11111") and 
        not((EXMEMRegWrite = '1' and (EXMEMRegRd /= "11111") and (EXMEMRegRd = Rm)))
        and (MEMWBRegRd = Rm)) then
            ForwardB <= "01";
        end if;

        -- STUR data (writedata) Rn replaced
        -- ForwardB 11 would represent the data from the write data
        -- LDUR data (readdata) Rn replaced
        
    end process;
end;
