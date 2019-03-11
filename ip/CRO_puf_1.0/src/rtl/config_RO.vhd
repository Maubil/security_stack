library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

------------------------------------------------------------------------------
-- This is VHDL code for the config RO found in Fig.3(a) on Lecture12.pdf
-- Can create 8 possible ROs based on the input of the control bits.

------------------------------------------------------------------------------

entity config_oscillator is
	Port ( 
			enable : in STD_LOGIC;
			control_bit: in STD_LOGIC_VECTOR (2 downto 0); 
			output_bit :  out STD_LOGIC
		);
end config_oscillator;

architecture Behavioral of config_oscillator is

component inverter
	PORT(
			a : in STD_LOGIC;
			b : out STD_LOGIC
	);
end component;

signal top_path_0, top_path_1, top_path_2 : STD_LOGIC;
signal bot_path_0, bot_path_1, bot_path_2 : STD_LOGIC;
signal mux0_out, mux1_out, mux2_out : STD_LOGIC;
signal enable_out   : STD_LOGIC;

--these attributes DONT_TOUCH the tools from optimizing the inverters away
attribute DONT_TOUCH : string;
attribute DONT_TOUCH of top_path_0: signal is "true";
attribute DONT_TOUCH of top_path_1: signal is "true";
attribute DONT_TOUCH of top_path_2: signal is "true";
attribute DONT_TOUCH of bot_path_0: signal is "true";
attribute DONT_TOUCH of bot_path_1: signal is "true";
attribute DONT_TOUCH of bot_path_2: signal is "true";
attribute DONT_TOUCH of mux0_out: signal is "true";
attribute DONT_TOUCH of mux1_out: signal is "true";
attribute DONT_TOUCH of mux2_out: signal is "true";
attribute DONT_TOUCH of enable_out: signal is "true";

attribute ALLOW_COMBINATORIAL_LOOPS : string;
attribute ALLOW_COMBINATORIAL_LOOPS of enable_out: signal is "true";

begin

inverter_top_0 : inverter PORT MAP(enable_out, top_path_0);
inverter_bot_0 : inverter PORT MAP(enable_out, bot_path_0);
inverter_top_1 : inverter PORT MAP(mux0_out, top_path_1);
inverter_bot_1 : inverter PORT MAP(mux0_out, bot_path_1);
inverter_top_2 : inverter PORT MAP(mux1_out, top_path_2);
inverter_bot_2 : inverter PORT MAP(mux1_out, bot_path_2);

 --Enable Stage 
enable_out <= enable AND mux2_out;

--Stage 0
stage_0: process(control_bit(0), top_path_0, bot_path_0)
begin
    case control_bit(0) is
        when '1' => 
            mux0_out <= top_path_0;
        when '0' =>
            mux0_out <= bot_path_0;
        when others => 
            null;
    end case;
end process;
    
--Stage 1
stage_1: process(control_bit(1), top_path_1, bot_path_1)
begin
    case control_bit(1) is
        when '1' => 
            mux1_out <= top_path_1;
        when '0' =>
            mux1_out <= bot_path_1;
        when others => 
            null;
    end case;
end process;
    
 --Stage 2
stage_2: process(control_bit(2), top_path_2, bot_path_2)
begin
    case control_bit(2) is
        when '1' => 
            mux2_out <= top_path_2;
        when '0' =>
            mux2_out <= bot_path_2;
        when others => 
            null;
    end case;
end process;  

--output
output_bit <= mux2_out;

end Behavioral;
