library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity cordic_module_tb is
end;
architecture cordic_module_tb_arch of cordic_module_tb is

constant clk_period : time := 8 ns;
constant DATA_WIDTH : integer := 9;
constant N : integer := 9;

component CORDIC_coprocessor is
    Generic ( DATA_WIDTH : integer := 9;     --Q1.8
              N : integer := 9);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           start : in STD_LOGIC;
           phi : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
           x_in : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
           y_in : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
           x_out : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
           y_out : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
           ready : out STD_LOGIC);
end component;

signal clk : std_logic := '1';
signal rst : std_logic := '1';
signal start : std_logic := '0';
signal ready : std_logic := '0';

signal phi, x_in, y_in, x_out, y_out: std_logic_vector(DATA_WIDTH-1 downto 0);

begin

clk <= not clk after clk_period;

DUT: CORDIC_coprocessor
generic map (DATA_WIDTH => DATA_WIDTH, N => N)port map ( clk => clk, rst => rst, start => start, phi => phi, x_in => x_in, y_in => y_in, x_out => x_out, y_out => y_out, ready => ready);

process
begin
    rst <= '1';
    wait for 4*clk_period;
    rst <= '0';
    
    wait for 2*clk_period;
    x_in <= std_logic_vector(to_signed(255, DATA_WIDTH));
    y_in <= std_logic_vector(to_signed(0, DATA_WIDTH));
    phi <= std_logic_vector(to_signed(344, DATA_WIDTH));
    wait for 0.75*clk_period;
    start <= '1';
    wait for 2*clk_period;
    start <= '0';
    wait until ready = '1';
    wait for 2*clk_period;
    std.env.stop;
end process;
end;