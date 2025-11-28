library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity IIR_tb is
end IIR_tb;

architecture Behavioral of IIR_tb is
    constant N : integer := 15;

    signal clk : STD_LOGIC := '0';
    signal start : STD_LOGIC := '0';
    signal x_in : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
    signal y_out : STD_LOGIC_VECTOR(N-1 downto 0);
    signal ready : STD_LOGIC;
    
    constant clk_period : time := 8 ns;
    
begin
    uut : entity work.IIR
        generic map (
            N => N
        )
        Port map (
            clk => clk,
            start => start,
            x_in => x_in,
            y_out => y_out,
            ready => ready
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;
    
    stim_proc : process
        file sound_file : text open read_mode is "sh_sound.hex";
        file y_file     : text open write_mode is "y_out.hex";
        variable line_in, line_out : line;
        variable tmp_val : std_logic_vector(N-1 downto 0);
    begin
        wait for clk_period * 10;
        while not endfile(sound_file) loop
            readline(sound_file, line_in);
            if line_in'length > 0 then
                hread(line_in, tmp_val);
                
                wait for clk_period;
                start <= '1';
                x_in  <= tmp_val(N-1 downto 0);
                wait for clk_period;
                start <= '0';
                wait until ready = '1';
                wait for clk_period*2;
                
                hwrite(line_out, y_out);
                writeline(y_file, line_out);
               end if;
           end loop;


--        wait for clk_period;
--        start <= '1';
--        x_in <= std_logic_vector(to_signed(8192, N)); -- x[n] = 1 in Q2.13
--        wait for clk_period;
--        start <= '0';
--        wait until ready = '1';
        
--        wait for clk_period*2;
--        start <= '1';
--        x_in <= std_logic_vector(to_signed(0, N)); -- x[n] = 0 in Q2.13
--        wait for clk_period;
--        start <= '0';
--        wait until ready = '1';
        
--        for i in 0 to 8 loop
--            wait for clk_period*2;
--            start <= '1';
--            wait for clk_period;
--            start <= '0';
--            wait until ready = '1';  
--        end loop;
        wait for clk_period*2;
        std.env.stop;
        wait;
    end process;

end Behavioral;