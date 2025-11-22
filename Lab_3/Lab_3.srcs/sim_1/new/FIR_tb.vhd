library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FIR_tb is
end FIR_tb;

architecture Behavioral of FIR_tb is
    constant N : integer := 12;
    constant Order : integer := 6;
    constant BAAT : integer := 3;
    constant clk_period : time := 8 ns;
    
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal start : STD_LOGIC := '0';
    signal x : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
    signal y : STD_LOGIC_VECTOR(N-1 downto 0);
    signal ready : STD_LOGIC;
begin

    uut : entity work.FIR
    Generic map (
        N => N,
        Order => Order,
        BAAT => BAAT)
    Port map (
        clk => clk,
        rst => rst,
        start => start,
        x => x,
        y => y,
        ready => ready);   
        
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
        wait for clk_period*2;
        
        x <= std_logic_vector(to_signed(2047, N)); -- x = 1 in Q1.11
        wait for clk_period/2;
        start <= '1';
        wait for clk_period;
        start <= '0';
        wait until ready = '1';

        wait for clk_period/2;
        start <= '1';
        wait for clk_period;
        start <= '0';
        wait until ready = '1';
             
        wait for clk_period*2;
        x <= std_logic_vector(to_signed(0, N)); -- x = 0 in Q1.11
        wait for clk_period/2;

        for i in 0 to 6 loop
            start <= '1';
            wait for clk_period;
            start <= '0';
            wait until ready = '1';
            wait for clk_period*2;
        end loop;
        std.env.stop;
        wait;
    end process;

end Behavioral;
