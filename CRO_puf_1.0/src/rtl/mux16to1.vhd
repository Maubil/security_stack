library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--s is the select bits
entity mux16to1 is
    Port ( s : in STD_LOGIC_VECTOR (3 downto 0);
           inputs : in STD_LOGIC_VECTOR (15 downto 0);
           output : out STD_LOGIC);
end mux16to1;

architecture Behavioral of mux16to1 is
begin
    process(s, inputs)
    begin
        case s is 
            when x"0" =>
                output <= inputs(0);
            when x"1" =>
                output <= inputs(1);
            when x"2" =>
                output <= inputs(2);
            when x"3" =>
                output <= inputs(3);
            when x"4" =>
                output <= inputs(4);
            when x"5" =>
                output <= inputs(5);
            when x"6" =>
                output <= inputs(6);
            when x"7" =>
                output <= inputs(7);       
            when x"8" =>
                output <= inputs(8);
            when x"9" =>
                output <= inputs(9);
            when x"A" =>
                output <= inputs(10);
            when x"B" =>
                output <= inputs(11);
            when x"C" =>
                output <= inputs(12);
            when x"D" =>
                output <= inputs(13);
            when x"E" =>
                output <= inputs(14);
            when x"F" =>
                output <= inputs(15);
            when others => 
                null;
        end case;
    end process;
end Behavioral;
