library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity register11 is 
    port (
        clock : in std_logic;
        reset : in std_logic;
        in11 : in std_logic_vector(10 downto 0);
        out11 : out std_logic_vector(10 downto 0)
    );
end entity;

architecture behavioral of register11 is
begin
    process (all) begin
        if reset = '1' then
            out11 <= "00000000000";
        end if;

        if rising_edge(clock) then
            out11 <= in11;
        end if;
    end process;
end;