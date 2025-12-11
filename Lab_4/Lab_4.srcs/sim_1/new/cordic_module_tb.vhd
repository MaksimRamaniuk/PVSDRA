library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cordic_module_tb is
end cordic_module_tb;

architecture Behavioral of cordic_module_tb is

    constant DATA_WIDTH : integer := 9;   
    constant N : integer := 9;
    constant clk_period : time := 8 ns;

    signal clk   : STD_LOGIC := '0';
    signal rst   : STD_LOGIC := '0';
    signal start : STD_LOGIC := '0';
    signal ready : STD_LOGIC;
    signal count : integer;

    signal phi   : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
    signal x_in  : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
    signal y_in  : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
    signal x_out : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal y_out : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

begin

    uut : entity work.CORDIC_coprocessor
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            N          => N)
        port map (
            clk   => clk,
            rst   => rst,
            start => start,
            phi   => phi,
            x_in  => x_in,
            y_in  => y_in,
            x_out => x_out,
            y_out => y_out,
            ready => ready
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_process : process
    begin
        wait for clk_period/4;
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for clk_period * 3/4;

--        x_in <= std_logic_vector(to_signed(64, DATA_WIDTH));
--        y_in <= std_logic_vector(to_signed(64, DATA_WIDTH));
--        phi  <= std_logic_vector(to_signed(47, DATA_WIDTH));  -- 2*pi/17 in Q2.7

--        wait for clk_period/4;
--        start <= '1';
--        wait for clk_period;
--        start <= '0';

--        wait until ready = '1';
--        wait for clk_period * 2;
        
--        x_in <= x_out;
--        y_in <= y_out;
--        phi  <= std_logic_vector(to_signed(201, DATA_WIDTH));  -- pi/2 in Q2.7
--        wait for clk_period/4;
--        start <= '1';
--        wait for clk_period;
--        start <= '0';
--        wait until ready = '1';

        x_in <= std_logic_vector(to_signed(64, DATA_WIDTH));
        y_in <= std_logic_vector(to_signed(64, DATA_WIDTH));
        phi  <= std_logic_vector(to_signed(47, DATA_WIDTH));
        
        for i in 0 to 15 loop
            wait for clk_period;
            start <= '1';
            wait for clk_period;
            start <= '0';     
            wait until ready = '1'; 
            count <= i;
            x_in <= x_out;
            y_in <= y_out;  
        end loop;
        
        wait for clk_period * 2;
        std.env.stop;
        wait;
    end process;

end Behavioral;
