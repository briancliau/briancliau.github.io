library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity register32 is 
    port (
        clock : in std_logic;
        reset : in std_logic;
        in32 : in std_logic_vector(31 downto 0);
        out32 : out std_logic_vector(31 downto 0)
    );
end entity;

architecture behavioral of register32 is
begin
    process (all) begin
        if reset = '1' then
            out32 <= x"00000000";
        end if;

        if rising_edge(clock) then
            out32 <= in32;
        end if;
    end process;
end;