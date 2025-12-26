library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity PipeCPU_testbench is
end PipeCPU_testbench;

-- when your testbench is complete you should report error with severity failure.
-- this will end the simulation. Do not add stop times to the Makefile

architecture structural of PipeCPU_testbench is
    component PipelinedCPU1 is
        port (
            clk :in STD_LOGIC;
            rst :in STD_LOGIC;
            DEBUG_FORWARDA : out std_logic_vector(1 downto 0);
            DEBUG_FORWARDB : out std_logic_vector(1 downto 0);
            DEBUG_PC_WRITE_ENABLE : out STD_LOGIC;
            DEBUG_PC : out STD_LOGIC_VECTOR(63 downto 0);
            DEBUG_INSTRUCTION : out STD_LOGIC_VECTOR(31 downto 0);
            DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
            DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
            DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
        );
    end component;

    signal test_clk : std_logic := '1';
    signal test_rst : std_logic := '1';
    signal test_DEBUG_FORWARDA : std_logic_vector(1 downto 0);
    signal test_DEBUG_FORWARDB : std_logic_vector(1 downto 0);
    signal test_DEBUG_PC_WRITE_ENABLE : std_logic;
    signal test_DEBUG_PC : std_logic_vector(63 downto 0);
    signal test_DEBUG_INSTRUCTION : std_logic_vector(31 downto 0);
    signal test_DEBUG_TMP_REGS : std_logic_vector(64*4 - 1 downto 0);
    signal test_DEBUG_SAVED_REGS : std_logic_vector(64*4 - 1 downto 0);
    signal test_DEBUG_MEM_CONTENTS : std_logic_vector(64*4 - 1 downto 0);
begin
    uut : PipelinedCPU1 port map (
        clk => test_clk,
        rst => test_rst,
        DEBUG_FORWARDA => test_DEBUG_FORWARDA,        
        DEBUG_FORWARDB => test_DEBUG_FORWARDB,        
        DEBUG_PC_WRITE_ENABLE => test_DEBUG_PC_WRITE_ENABLE,
        DEBUG_PC => test_DEBUG_PC,
        DEBUG_INSTRUCTION => test_DEBUG_INSTRUCTION,
        DEBUG_TMP_REGS => test_DEBUG_TMP_REGS,
        DEBUG_SAVED_REGS => test_DEBUG_SAVED_REGS,
        DEBUG_MEM_CONTENTS => test_DEBUG_MEM_CONTENTS
    );

    stim_proc: process
    begin
        test_clk <= '1';
        test_rst <= '1';
        
        wait for 50 ns;
        test_rst <= '0';

        wait for 25 ns;
        test_clk <= '0';

        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns;
        test_clk <= '0';

        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns; 
        test_clk <= '0';

        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns;
        test_clk <= '0';

        -- end ldstr
        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns; 
        test_clk <= '0';

        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns;
        test_clk <= '0';

        -- end for comp
        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns; 
        test_clk <= '0';

        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns;
        test_clk <= '0';

        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns; 
        test_clk <= '0';

        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns; 
        test_clk <= '0';

        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns; 
        test_clk <= '0';

        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns; 
        test_clk <= '0';

        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns; 
        test_clk <= '0';

        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns; 
        test_clk <= '0';

        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns; 
        test_clk <= '0';

        wait for 50 ns;
        test_clk <= '1';

        wait for 50 ns; 
        test_clk <= '0';
        -- end for p1

        assert false report "Test completed" severity error;
        wait;
    end process;

end;