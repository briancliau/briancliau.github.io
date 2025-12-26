library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SignExtend is
port(
     x : in  STD_LOGIC_VECTOR(31 downto 0);
     y : out STD_LOGIC_VECTOR(63 downto 0) -- sign-extend(x)
);
end SignExtend;

architecture dataflow of SignExtend is
    signal ones : std_logic_vector(31 downto 0) := (others => '1');
    signal zeroes : std_logic_vector(31 downto 0) := (others => '0');

    signal ones_I : std_logic_vector(51 downto 0) := (others => '1'); -- for 12-bit I-type
    signal zeros_I : std_logic_vector(51 downto 0) := (others => '0');

    signal ones_D : std_logic_vector(54 downto 0) := (others => '1'); -- for 9-bit D-type
    signal zeros_D : std_logic_vector(54 downto 0) := (others => '0');

    signal ones_B : std_logic_vector(37 downto 0) := (others => '1'); -- for 26-bit B-type
    signal zeros_B : std_logic_vector(37 downto 0) := (others => '0');

    signal ones_CB : std_logic_vector(44 downto 0) := (others => '1'); -- for 19-bit CB-type
    signal zeros_CB : std_logic_vector(44 downto 0) := (others => '0');
begin
    process (x) begin
        -- Default set to 0 if nothing is recognized
        y <= (others => '0');

        if (x(31 downto 21)) = "11111000010" then 
            y(63 downto 9) <= zeros_D when (x(20) = '0') else ones_D;
            y(8 downto 0) <= x(20 downto 12);
        -- D type STUR
        elsif (x(31 downto 21) = "11111000000") then
            y(63 downto 9) <= zeros_D when (x(20) = '0') else ones_D;
            y(8 downto 0) <= x(20 downto 12);
        -- I type ADD or SUB
        elsif (x(31 downto 22) = "1001000100" or x(31 downto 22) = "1101000100") then
            y(63 downto 12) <= zeros_I when (x(21) = '0') else ones_I;
            y(11 downto 0) <= x(21 downto 10);
        
        -- I type AND or OR
        elsif (x(31 downto 22) = "1001001000" or x(31 downto 22) = "1011001000") then
            y(63 downto 12) <= zeros_I;
            y(11 downto 0) <= x(21 downto 10);

        -- B type
        elsif (x(31 downto 26) = "000101") then
            y(63 downto 26) <= zeros_B when (x(25) = '0') else ones_B;
            y(25 downto 0) <= x(25 downto 0);

        -- CB type
        elsif (x(31 downto 24) = "10110100" or x(31 downto 24) = "10110101") then
            y(63 downto 19) <= zeros_CB when (x(23) = '0') else ones_CB;
            y(18 downto 0) <= x(23 downto 5);
        end if;
    end process;
end dataflow;
