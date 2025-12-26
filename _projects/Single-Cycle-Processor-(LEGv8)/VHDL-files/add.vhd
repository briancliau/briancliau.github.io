library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity ADD is
-- Adds two signed 64-bit inputs
-- output = in1 + in2
-- carry_in : 1 bit carry_in
-- carry_out : 1 bit carry_out
-- Hint: there are multiple ways to do this
--       -- cascade smaller adders to make the 64-bit adder (make a heirarchy)
--       -- use a Python script (or Excel) to automate filling in the signals
--       -- try a Gen loop (you will have to look this up)
port(
     carry_in : in STD_LOGIC;
     in0    : in  STD_LOGIC_VECTOR(63 downto 0);
     in1    : in  STD_LOGIC_VECTOR(63 downto 0);
     output : out STD_LOGIC_VECTOR(63 downto 0);
     carry_out : out STD_LOGIC
);
end ADD;

architecture structural of ADD is
    component ADD32 is 
        port (
            carry_in : in STD_LOGIC;
            in0    : in  STD_LOGIC_VECTOR(31 downto 0);
            in1    : in  STD_LOGIC_VECTOR(31 downto 0);
            output : out STD_LOGIC_VECTOR(31 downto 0);
            carry_out : out STD_LOGIC
        );
    end component;

    signal carry_out_intermediate : std_logic;
begin
    test_ADD32_lower : ADD32 port map (
        carry_in => carry_in,
        in0 => in0(31 downto 0),
        in1 => in1(31 downto 0),
        output => output(31 downto 0),
        carry_out => carry_out_intermediate
    );

    test_ADD32_upper : ADD32 port map (
        carry_in => carry_out_intermediate,
        in0 => in0(63 downto 32),
        in1 => in1(63 downto 32),
        output => output(63 downto 32),
        carry_out => carry_out
    );

end;