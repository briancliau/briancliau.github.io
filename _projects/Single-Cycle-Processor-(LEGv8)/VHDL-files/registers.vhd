library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- STD_LOGIC and STD_LOGIC_VECTOR
use IEEE.numeric_std.ALL; -- to_integer and unsigned

entity registers is
-- This component is described in the textbook, starting on section 4.3 
-- The indices of each of the registers can be found on the LEGv8 Green Card
-- Keep in mind that register XZR has a constant value of 0 and cannot be overwritten

-- This should only write on the negative edge of Clock when RegWrite is asserted.
-- Reads should be purely combinatorial, i.e. they don't depend on Clock
-- HINT: Use the provided dmem.vhd as a starting point
generic (NUM_REGISTERS : integer := 32);

port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
     RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
     WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
     WD       : in  STD_LOGIC_VECTOR (63 downto 0);
     RegWrite : in  STD_LOGIC;
     Clock    : in  STD_LOGIC;
     RD1      : out STD_LOGIC_VECTOR (63 downto 0);
     RD2      : out STD_LOGIC_VECTOR (63 downto 0);
     --Probe ports used for testing.
     -- Notice the width of the port means that you are 
     --      reading only part of the register file. 
     -- This is only for debugging
     -- You are debugging a sebset of registers here
     -- Temp registers: $X9 & $X10 & X11 & X12 
     -- 4 refers to number of registers you are debugging
     DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     -- Saved Registers X19 & $X20 & X21 & X22 
     DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
);
end registers;

architecture behavioral of registers is 
    type RegisterArray is array (0 to NUM_REGISTERS-1) of std_logic_vector(63 downto 0);
    signal regs : RegisterArray;
    signal first : std_logic := '1';
begin
    RD1 <= regs(to_integer(unsigned(RR1)));
    RD2 <= regs(to_integer(unsigned(RR2)));
    DEBUG_TMP_REGS(255 downto 192) <= regs(12);
    DEBUG_TMP_REGS(191 downto 128) <= regs(11);
    DEBUG_TMP_REGS(127 downto 64) <= regs(10);
    DEBUG_TMP_REGS(63 downto 0) <= regs(9);
    DEBUG_SAVED_REGS(255 downto 192) <= regs(22);
    DEBUG_SAVED_REGS(191 downto 128) <= regs(21);
    DEBUG_SAVED_REGS(127 downto 64) <= regs(20);
    DEBUG_SAVED_REGS(63 downto 0) <= regs(19);

    process (Clock, RR1, RR2)
    -- variable first:boolean := true;
    begin
        if (first = '1') then
            regs(0) <= x"0000000000000000";
            regs(1) <= x"0000000000000000";
            regs(2) <= x"0000000000000000";
            regs(3) <= x"0000000000000000";
            regs(4) <= x"0000000000000000";
            regs(5) <= x"0000000000000000";
            regs(6) <= x"0000000000000000";
            regs(7) <= x"0000000000000000";
            regs(8) <= x"0000000000000000";
            regs(16) <= x"0000000000000000";
            regs(17) <= x"0000000000000000";
            regs(18) <= x"0000000000000000";
            regs(28) <= x"0000000000000000";
            regs(29) <= x"0000000000000000";
            regs(30) <= x"0000000000000000";
            
            -- temporary registers
            regs(9) <= x"0000000000000000";
            regs(10) <= x"0000000000000001";
            regs(11) <= x"0000000000000004";
            regs(12) <= x"0000000000000008";
            regs(13) <= x"0000000000001000";
            regs(14) <= x"0000000000010000";
            regs(15) <= x"0000000000100000";

            -- saved registers
            regs(19) <= x"000000000000000F";
            regs(20) <= x"0000000000000007";
            regs(21) <= x"0000000000000000";
            regs(22) <= x"0000000000000010";
            regs(23) <= x"0000000000010000";
            regs(24) <= x"0000000000100000";
            regs(25) <= x"0000000001000000";
            regs(26) <= x"0000000010000000";
            regs(27) <= x"0000000010000000";

            -- set register XZR
            regs(31) <= x"0000000000000000";

            first <= '0';
        end if;

        if falling_edge(Clock) then
            if RegWrite = '1' and WR /= "11111" then
                regs(to_integer(unsigned(WR))) <= WD;
            end if;
        end if;
    end process;
end;

