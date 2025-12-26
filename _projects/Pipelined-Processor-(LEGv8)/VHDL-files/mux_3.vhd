library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std;

entity mux_3 is
port(
    in0    : in STD_LOGIC_VECTOR(63 downto 0);
    in1    : in STD_LOGIC_VECTOR(63 downto 0); 
    in2    : in STD_LOGIC_VECTOR(63 downto 0);
    sel    : in STD_LOGIC_VECTOR(1 downto 0);
    output : out STD_LOGIC_VECTOR(63 downto 0)
);
end mux_3;

architecture dataflow of mux_3 is 
begin
    process (all) begin
        case sel is
            when "01" => output <= in1;
            when "10" => output <= in2;
            when others => output <= in0;
        end case;
    end process;
end;