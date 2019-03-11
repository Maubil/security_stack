library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity puf is
  generic (
    INPUT_WIDTH    : integer := 128;
    RING_OSC_DEPTH : integer := 20;
    COUNTER_SIZE   : integer := 32;
    CNTR_OVERFLOW  : integer := 65535);
  port (
    clk             : in  std_logic;
    rstn            : in  std_logic;
    ena             : in  std_logic;
    done            : out std_logic;
    challenge_input : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    response_output : out std_logic_vector((INPUT_WIDTH/4)-1 downto 0));
end entity puf;

architecture rtl of puf is
  component ring_oscillator is
    generic (
      CHAIN_WIDTH : positive);
    port (
      rstn   : in  std_logic;
      output : out std_logic);
  end component ring_oscillator;
  component comparator is
    generic (
      WIDTH : integer);
    port (
      val_a    : in  std_logic_vector(WIDTH-1 downto 0);
      val_b    : in  std_logic_vector(WIDTH-1 downto 0);
      solution : out std_logic);
  end component comparator;
  component counter is
    generic (
      WIDTH : integer;
      COUNTER_OVERFLOW : integer);
    port (
      clk      : in  std_logic;
      rstn     : in  std_logic;
      ena      : in  std_logic;
      finished : out std_logic;
      count    : out std_logic_vector(WIDTH-1 downto 0));
  end component counter;
  component mux is
    port (
      in0  : in  std_logic;
      in1  : in  std_logic;
      sel  : in  std_logic;
      out0 : out std_logic);
  end component mux;
  type count_t is array (INPUT_WIDTH-1 downto 0) of std_logic_vector(COUNTER_SIZE-1 downto 0);
  signal count         : count_t := (others=> (others=>'0'));
  type osc_output_t is array (INPUT_WIDTH-1 downto 0) of std_logic;
  signal osc_output    : osc_output_t := (others=>'0');
  type solution_t is array ((INPUT_WIDTH/2)-1 downto 0) of std_logic;
  signal solution      : solution_t := (others=>'0');
  type mux_lvl_1_out_t is array ((INPUT_WIDTH/4)-1 downto 0) of std_logic;
  signal mux_lvl_1_out : mux_lvl_1_out_t := (others=>'0');
  type finished_t is array (INPUT_WIDTH-1 downto 0) of std_logic;
  signal finished      : finished_t := (others=>'0');
begin
  U0_GEN_RING_OSC : for i in 0 to INPUT_WIDTH-1
  generate
    U0_OSC : ring_oscillator
      generic map (
        CHAIN_WIDTH => RING_OSC_DEPTH)
      port map (
        rstn   => rstn,
        output => osc_output(i));
  end generate;

  U1_GEN_COUNTER : for i in 0 to INPUT_WIDTH-1
  generate
    U1_COUNTER : counter
      generic map (
        WIDTH => COUNTER_SIZE,
        COUNTER_OVERFLOW => CNTR_OVERFLOW)
      port map (
        clk      => osc_output(i),
        rstn     => rstn,
        ena      => ena,
        finished => finished(i),
        count    => count(i));
  end generate;

  done <= (finished(0));

  U2_GEN_COMPARATOR : for i in 0 to (INPUT_WIDTH/2)-1
  generate
    U2_COMPARATOR : comparator
      generic map (
        WIDTH => COUNTER_SIZE)
      port map (
        val_a    => count(i*2),
        val_b    => count(i*2+1), -- solution <= '1' when val_a > val_b else '0';
        solution => solution(i)); -- quand vecteur 0 est plus grand que vecteur 1 alors sortie = 1
  end generate;

  U3_GEN_MUX_LVL_1 : for i in 0 to (INPUT_WIDTH/4)-1
  generate
    U3_MUX_LVL_1 : mux
      port map (
        in0  => solution(i*2),
        in1  => solution(i*2+1),
        sel  => challenge_input(i*2),
        out0 => mux_lvl_1_out(i));
  end generate;

  U4_GEN_MUX_LVL_2 : for i in 0 to (INPUT_WIDTH/4)-1
  generate
    U4_MUX_LVL_2 : mux
      port map (
        in0  => mux_lvl_1_out(i),
        in1  => solution(i*2),
        sel  => challenge_input(i),
        out0 => response_output(i));
  end generate;
end architecture rtl;
