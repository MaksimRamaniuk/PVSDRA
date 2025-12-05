library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity CORDIC_coprocessor is
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
end CORDIC_coprocessor;

architecture rtl of CORDIC_coprocessor is
    constant K : std_logic_vector(DATA_WIDTH-1 downto 0) := std_logic_vector(to_signed(155 , DATA_WIDTH)); -- K = 0.6072544793
    signal x, y: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal count : integer range 0 to N-1 := 0;
    signal angle : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal x_shift, y_shift: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal busy : std_logic := '0';
    
    type memory is  array(0 to N-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    constant rom: memory:= (
        std_logic_vector(to_signed(201, DATA_WIDTH)),
        std_logic_vector(to_signed(119, DATA_WIDTH)),
        std_logic_vector(to_signed(63, DATA_WIDTH)),
        std_logic_vector(to_signed(32, DATA_WIDTH)),
        std_logic_vector(to_signed(16, DATA_WIDTH)),
        std_logic_vector(to_signed(8, DATA_WIDTH)),
        std_logic_vector(to_signed(4, DATA_WIDTH)),
        std_logic_vector(to_signed(2, DATA_WIDTH)),
        std_logic_vector(to_signed(1, DATA_WIDTH)));
begin
    start_cordic : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ready <= '0';
                busy <= '0';
                count <= 0;
                x <= (others => '0');
                y <= (others => '0');
            elsif start = '1' and busy /= '1' then
                x <= x_in;
                y <= y_in;
                angle <= phi;
                count <= 0;
                busy <= '1';
                ready <= '0';
            end if;
        end if;
    end process;
    
    shift : process(x, y)
    variable temp_x, temp_y :std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    begin
        temp_x := x;
        temp_y := y;
        if count /= 0 and count /= N then
            for i in 0 to count loop
                temp_x := temp_x(DATA_WIDTH-1) & temp_x(DATA_WIDTH-1 downto - 1);
                temp_y := temp_y(DATA_WIDTH-1) & temp_y(DATA_WIDTH-1 downto - 1);               
            end loop;
        end if;
        x_shift <= temp_x;
        y_shift <= temp_y;   
    end process;
    
    job : process(clk)
    begin
        if rising_edge(clk) then
            if busy = '1' then
                if count < N then
                    if angle(DATA_WIDTH-1) = '1' then
                        x <= x + x_shift;
                        y <= y - y_shift;
                        angle <= angle + rom(count);
                    else
                        x <= x - x_shift;
                        y <= y + y_shift;
                        angle <= angle - rom(count);                    
                    end if;
                else
                    busy <= '0';
                    ready <= '1';
                end if;
            end if;
        end if;
    end process;
    
    mult : process(x, y)
    variable x_scale, y_scale : std_logic_vector(2*DATA_WIDTH-1 downto 0) := (others => '0');
    begin
        x_scale := x * K;
        y_scale := y * K;
        
        x_out <= x_scale(2*DATA_WIDTH-2 downto DATA_WIDTH-1);
        y_out <= y_scale(2*DATA_WIDTH-2 downto DATA_WIDTH-1);
    end process;
end rtl;