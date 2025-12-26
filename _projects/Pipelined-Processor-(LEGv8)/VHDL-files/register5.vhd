library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity register5 is 
    port (
        clock : in std_logic;
        reset : in std_logic;
        in5 : in std_logic_vector(4 downto 0);
        out5 : out std_logic_vector(4 downto 0)
    );
end entity;

architecture behavioral of register5 is
begin
    process (all) begin
        if reset = '1' then
            out5 <= "00000";
        end if;

        if rising_edge(clock) then
            out5 <= in5;
        end if;
    end process;
end;