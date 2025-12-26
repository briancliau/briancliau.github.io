library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity add_value is 
    port (
        PCwrite : in std_logic;
        added_value : out std_logic_vector(63 downto 0)
    );
end add_value;

architecture behavioral of add_value is
begin
    added_value <= x"0000000000000004" when PCwrite = '1' else x"0000000000000000";
end;