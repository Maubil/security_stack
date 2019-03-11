library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity inverter is
    Port ( a : in STD_LOGIC;
           b : out STD_LOGIC
           );
end inverter;

architecture Behavioral of inverter is
attribute KEEP : string;
attribute KEEP of a : signal is "true";
attribute KEEP of b : signal is "true";

begin
b <= not a;
end Behavioral;
