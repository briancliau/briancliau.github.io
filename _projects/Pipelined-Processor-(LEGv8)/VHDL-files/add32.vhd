library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity ADD32 is
port(
     carry_in : in STD_LOGIC;
     in0    : in  STD_LOGIC_VECTOR(31 downto 0);
     in1    : in  STD_LOGIC_VECTOR(31 downto 0);
     output : out STD_LOGIC_VECTOR(31 downto 0);
     carry_out : out STD_LOGIC
);
end ADD32;

architecture dataflow of ADD32 is
    signal carry_in_vector : std_logic_vector(32 downto 0);
begin
    carry_in_vector(0) <= carry_in; 

    gen: for i in 0 to 31 generate 
    output(i) <= in0(i) xor in1(i) xor carry_in_vector(i); 
    carry_in_vector(i + 1) <= (in0(i) and in1(i)) or (in0(i) and carry_in_vector(i)) or (in1(i) and carry_in_vector(i)); 
    end generate gen; 
    
    carry_out <= carry_in_vector(32);
end;