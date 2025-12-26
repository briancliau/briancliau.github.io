library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity register64 is 
    port (
        clock : in std_logic;
        reset : in std_logic;
        in64 : in std_logic_vector(63 downto 0);
        out64 : out std_logic_vector(63 downto 0)
    );
end entity;

architecture behavioral of register64 is
begin
    process (clock, reset, in64, out64) begin
        if reset = '1' then
            out64 <= x"0000000000000000";
        end if;

        if rising_edge(clock) then
            out64 <= in64;
        end if;
    end process;
end;