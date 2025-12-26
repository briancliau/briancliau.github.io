library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity IFID_register64 is 
    port (
        clock : in std_logic;
        reset : in std_logic;
        IFIDWrite : in std_logic;
        in64 : in std_logic_vector(63 downto 0);
        out64 : out std_logic_vector(63 downto 0)
    );
end entity;

architecture behavioral of IFID_register64 is
begin
    process (clock, reset, IFIDWrite, in64, out64) begin
        if reset = '1' then
            out64 <= x"0000000000000000";
        end if;

        if rising_edge(clock) and IFIDWrite = '1' then
            out64 <= in64;
        elsif rising_edge(clock) and IFIDWrite = '0' then
            out64 <= out64;
        end if;
    end process;
end;