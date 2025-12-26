library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- STD_LOGIC and STD_LOGIC_VECTOR
use IEEE.numeric_std.ALL; -- to_integer and unsigned

entity ALU is
-- Implement: AND, OR, ADD (signed), SUBTRACT (signed)
-- as described in Section 4.4 in the textbook.
-- The functionality of each instruction can be found on the 'ARM Reference Data' sheet at the
--    front of the textbook (or the Green Card pdf on Canvas).
port(
     in0       : in     STD_LOGIC_VECTOR(63 downto 0);
     in1       : in     STD_LOGIC_VECTOR(63 downto 0);
     operation : in     STD_LOGIC_VECTOR(3 downto 0);
     result    : buffer STD_LOGIC_VECTOR(63 downto 0);
     zero      : buffer STD_LOGIC;
     overflow  : buffer STD_LOGIC
    );
end ALU;

architecture structrual of ALU is 
    Component ADD is 
        port (
            carry_in : in STD_LOGIC;
            in0    : in  STD_LOGIC_VECTOR(63 downto 0);
            in1    : in  STD_LOGIC_VECTOR(63 downto 0);
            output : out STD_LOGIC_VECTOR(63 downto 0);
            carry_out : out STD_LOGIC
        );
    end component;

    signal adder_in0 : std_logic_vector(63 downto 0) := (others => '0');
    signal adder_in1 : std_logic_vector(63 downto 0) := (others => '0');
    signal adder_result : std_logic_vector(63 downto 0) := (others => '0');
    signal adder_overflow : std_logic := '0';
    signal subtraction_in1 : std_logic_vector(63 downto 0) := (others => '0');
    signal adder_carry_in : std_logic := '0';
begin 
    Adder : ADD port map (
        carry_in => adder_carry_in,
        in0 => adder_in0,
        in1 => adder_in1,
        output => adder_result,
        carry_out => adder_overflow
    );

    process (all) begin
        if operation = "0010" then
            adder_in0 <= in0;
            adder_in1 <= in1;
            adder_carry_in <= '0';
            result <= adder_result;
            overflow <= ((in0(63) and in1(63) and not adder_result(63)) or ((not in0(63)) and (not in1(63)) and adder_result(63)));
        elsif operation = "0000" then
            result <= in0 and in1;
        elsif operation = "0001" then
            result <= in0 or in1;
        elsif operation = "0110" then --subtract
            adder_in0 <= in0;
            adder_carry_in <= '1';
            subtraction_in1 <= in1 xor x"FFFFFFFFFFFFFFFF";
            adder_in1 <= subtraction_in1;
            result <= adder_result;
            overflow <= ((in0(63) and not in1(63) and not adder_result(63)) or ((not in0(63)) and in1(63) and adder_result(63)));
        elsif operation = "0111" then -- pass input b
            result <= in1;
        elsif operation = "1100" then 
            result <= in0 nor in1;
        end if;

        if result = x"0000000000000000" then 
            zero <= '1';
        else 
            zero <= '0';
        end if;
    end process;
end;
        


