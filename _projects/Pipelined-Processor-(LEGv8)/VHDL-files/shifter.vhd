library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity Shifter is -- Shifts the input by 2 bits
port(
    Instruction : in std_logic_vector(31 downto 0);
    DataIn : in  STD_LOGIC_VECTOR(63 downto 0);
    DataOut : out STD_LOGIC_VECTOR(63 downto 0)
);
end Shifter;

architecture behvaioral of Shifter is 
    signal shiftAmount : integer;
begin 
    process (all) begin
        shiftAmount <= to_integer(unsigned(Instruction(15 downto 10)));

        if (Instruction(31 downto 21) = "11010011011") then -- Left
            DataOut <= shift_left(unsigned(DataIn), shiftAmount);
        elsif (Instruction(31 downto 21) = "11010011010") then-- Right
            DataOut <= shift_right(unsigned(DataIn), shiftAmount);
        end if;
    end process;
end;