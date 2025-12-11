library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;

entity Cartesian_to_Polar is
    Generic (DATA_WIDTH : integer := 9;
             N : integer := 9); -- число итераций CORDIC
    Port (
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        start : in  STD_LOGIC;
        x_in : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        y_in : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        r_out : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        theta_out : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        ready : out STD_LOGIC);
end Cartesian_to_Polar;

architecture rtl of Cartesian_to_Polar is
    signal x, y : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal angle : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal busy : std_logic := '0';
    signal count : integer range 0 to N-1 := 0;
    signal x_shift, y_shift: std_logic_vector(DATA_WIDTH-1 downto 0);
    
    constant K : std_logic_vector(DATA_WIDTH-1 downto 0) := std_logic_vector(to_signed(78 , DATA_WIDTH)); -- K = 0.6072544793
    signal arctan : std_logic_vector(DATA_WIDTH-1 downto 0);    
begin
    atan: entity work.ROM
    generic map (DATA_WIDTH => DATA_WIDTH)
    port map (addr => count, coef => arctan);
    
    shift : process(x, y)
    variable temp_x, temp_y :std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    begin
        if busy = '1' then
            temp_x := x;
            temp_y := y;
            if count > 0 and count /= N then
                for i in 0 to N-1 loop
                    if i = count then
                        exit;
                    end if;
                
                    temp_x := temp_x(DATA_WIDTH-1) & temp_x(DATA_WIDTH-1 downto 1);
                    temp_y := temp_y(DATA_WIDTH-1) & temp_y(DATA_WIDTH-1 downto 1);
                end loop;
            end if;
            x_shift <= temp_x;
            y_shift <= temp_y; 
        end if;  
    end process;
    process(clk)
    variable temp : std_logic_vector(2*DATA_WIDTH-1 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            ready <= '0';
            if rst = '1' then
                x <= (others => '0');
                y <= (others => '0');
                angle <= (others => '0');
                count <= 0;
                busy <= '0';
            elsif start = '1' then
                x <= x_in;
                y <= y_in;
                angle <= (others => '0');
                count <= 0;
                busy <= '1';
            elsif busy = '1' then
                if count < N-1 then
                    if y(DATA_WIDTH-1) = '1' then
                        x <= x - y_shift;
                        y <= y + x_shift;
                        angle <= angle - arctan;
                    else
                        x <= x + y_shift;
                        y <= y - x_shift;
                        angle <= angle + arctan;
                    end if;
                    count <= count + 1;
                else
                    temp := x * K;
                    busy <= '0';
                    ready <= '1';
                    
                    r_out <= temp(2*DATA_WIDTH-3 downto DATA_WIDTH-2);
                    theta_out <= angle;
                end if;
            end if;
        end if;
    end process;
end rtl;