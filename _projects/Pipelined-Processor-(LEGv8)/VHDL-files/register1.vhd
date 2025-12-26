library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity register1 is 
    port (
        clock : in std_logic;
        reset : in std_logic;
        in1 : in std_logic;
        out1 : out std_logic
    );
end entity;

architecture behavioral of register1 is
begin
    process (all) begin
        if reset = '1' then
            out1 <= '0';
        end if;

        if rising_edge(clock) then
            out1 <= in1;
        end if;
    end process;
end;