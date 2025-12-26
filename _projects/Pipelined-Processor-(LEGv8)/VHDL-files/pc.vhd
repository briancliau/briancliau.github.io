library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- STD_LOGIC and STD_LOGIC_VECTOR
use IEEE.numeric_std.ALL; -- to_integer and unsigned

entity PC is -- 64-bit rising-edge triggered register with write-enable and Asynchronous reset
-- For more information on what the PC does, see page 263 in the textbook.
port(
    clk : in STD_LOGIC; -- Propogate AddressIn to AddressOut on rising edge of clock
    write_enable : in STD_LOGIC; -- Only write if ’1’
    rst : in STD_LOGIC; -- Asynchronous reset! Sets AddressOut to 0x0
    AddressIn : in STD_LOGIC_VECTOR(63 downto 0); -- Next PC address
    AddressOut : out STD_LOGIC_VECTOR(63 downto 0) -- Current PC address
);
end PC;

architecture structural of PC is    
begin
    process(clk, rst) begin
        if (rst = '1') then
            AddressOut <= x"0000000000000000";
        elsif rising_edge(clk) then 
            if (write_enable = '1') then
                AddressOut <= AddressIn;
            else 
                AddressOut <= AddressOut;
            end if;
        end if;
    end process;
end;