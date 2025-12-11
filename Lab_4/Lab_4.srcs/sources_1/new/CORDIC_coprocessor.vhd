library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity CORDIC_coprocessor is
    Generic ( DATA_WIDTH : integer := 9;     --Q2.7
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
end CORDIC_coprocessor;

architecture rtl of CORDIC_coprocessor is
    constant K : std_logic_vector(DATA_WIDTH-1 downto 0) := std_logic_vector(to_signed(78 , DATA_WIDTH)); -- K = 0.6072544793
    signal x, y: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal count : integer range 0 to N-1 := 0;
    signal corner : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal x_shift, y_shift: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal busy, load, done : std_logic := '0';
    signal arctan : std_logic_vector(DATA_WIDTH-1 downto 0);    
    signal x_cart, y_cart: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal r, theta: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal start_pol,complete : std_logic := '0';
begin
    control_device: entity work.FSM
    generic map (N => N)
    port map(clk => clk, rst => rst, start => start, count => count, load => load, calc => busy, done => done, ready => ready, start_pol => start_pol, complete => complete);
    
    atan: entity work.ROM
    generic map (DATA_WIDTH => DATA_WIDTH)
    port map (addr => count, coef => arctan);
    
    counter : process(clk)
    begin
        if rising_edge(clk) then
            if busy = '1' and count < N-1 then
                count <= count + 1;
            else
                count <= 0;
            end if;
        end if;    
    end process;
    
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
--                for i in 0 to count-1 loop
--                    temp_x := temp_x(DATA_WIDTH-1) & temp_x(DATA_WIDTH-1 downto - 1);
--                    temp_y := temp_y(DATA_WIDTH-1) & temp_y(DATA_WIDTH-1 downto - 1);               
--                end loop;
            end if;
            x_shift <= temp_x;
            y_shift <= temp_y; 
        end if;  
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                x <= (others => '0');
                y <= (others => '0');
                corner <= (others => '0');
            elsif load = '1' then
                x <= x_in;
                y <= y_in;
                corner <= phi;
            elsif busy = '1' then
                if corner(DATA_WIDTH-1) = '1' then
                    x <= x + y_shift;
                    y <= y - x_shift;
                    corner <= corner + arctan;
                else
                    x <= x - y_shift;
                    y <= y + x_shift;
                    corner <= corner - arctan;
                end if;
            end if;
        end if;
    end process;


    mult : process(rst, done)
    variable x_scale, y_scale : std_logic_vector(2*DATA_WIDTH-1 downto 0) := (others => '0');
    begin
        if rst = '1' then
            x_out <= (others => '0');
            y_out <= (others => '0');
            x_cart <= (others => '0');
            y_cart <= (others => '0');
        elsif done = '1' then
            x_scale := x * K;
            y_scale := y * K;
            
            x_out <= x_scale(2*DATA_WIDTH-3 downto DATA_WIDTH-2);
            y_out <= y_scale(2*DATA_WIDTH-3 downto DATA_WIDTH-2);
            x_cart <= x_scale(2*DATA_WIDTH-3 downto DATA_WIDTH-2);
            y_cart <= y_scale(2*DATA_WIDTH-3 downto DATA_WIDTH-2);
        end if;
    end process;
    
    to_polar : entity work.Cartesian_to_Polar
    generic map (DATA_WIDTH => DATA_WIDTH)
    port map(clk => clk, rst => rst, start => start_pol, x_in => x_cart, y_in => y_cart, r_out => r, theta_out => theta, ready => complete);    
    
--    ready <= done;
end rtl;