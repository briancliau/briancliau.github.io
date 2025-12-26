library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity IFID_register32 is 
    port (
        clock : in std_logic;
        reset : in std_logic;
        IFIDWrite : in std_logic;
        in32 : in std_logic_vector(31 downto 0);
        out32 : out std_logic_vector(31 downto 0)
    );
end entity;

architecture behavioral of IFID_register32 is
begin
    process (all) begin
        if reset = '1' then
            out32 <= x"00000000";
        end if;

        if rising_edge(clock) and IFIDWrite = '1' then
            out32 <= in32;
        elsif rising_edge(clock) and IFIDWrite = '0' then 
            out32 <= out32;
        end if;
    end process;
end;