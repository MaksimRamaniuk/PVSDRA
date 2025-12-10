library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use ieee.std_logic_signed.all;

entity Cartesian2Polar is
    Generic (DATA_WIDTH : integer := 9;
             N : integer := 9); -- число итераций CORDIC
    Port (
        clk    : in  STD_LOGIC;
        rst    : in  STD_LOGIC;
        start  : in  STD_LOGIC;
        x_in   : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        y_in   : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        r_out  : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        theta_out : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        ready  : out STD_LOGIC
    );
end Cartesian2Polar;

architecture rtl of Cartesian2Polar is
    signal x, y : signed(DATA_WIDTH-1 downto 0);
    signal angle : signed(DATA_WIDTH-1 downto 0);
    signal busy : std_logic := '0';
    signal count : integer range 0 to N-1 := 0;

    type memory is array(0 to N-1) of signed(DATA_WIDTH-1 downto 0);
    constant arctan_rom : memory := (
        to_signed(101, DATA_WIDTH), to_signed(59, DATA_WIDTH),
        to_signed(31, DATA_WIDTH), to_signed(16, DATA_WIDTH),
        to_signed(8, DATA_WIDTH), to_signed(4, DATA_WIDTH),
        to_signed(2, DATA_WIDTH), to_signed(1, DATA_WIDTH),
        to_signed(0, DATA_WIDTH) );
    constant K : std_logic_vector(DATA_WIDTH-1 downto 0) := std_logic_vector(to_signed(78 , DATA_WIDTH)); -- K = 0.6072544793
    signal arctan : std_logic_vector(DATA_WIDTH-1 downto 0);  
begin
    atan: entity work.ROM
    generic map (DATA_WIDTH => DATA_WIDTH)
    port map (addr => count, coef => arctan);
    process(clk)
    variable temp : std_logic_vector(2*DATA_WIDTH-1 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if rst = '1' then
                x <= (others => '0');
                y <= (others => '0');
                angle <= (others => '0');
                count <= 0;
                busy <= '0';
                ready <= '0';
            elsif start = '1' then
                x <= signed(x_in);
                y <= signed(y_in);
                angle <= (others => '0');
                count <= 0;
                busy <= '1';
                ready <= '0';
            elsif busy = '1' then
                if count < N then
                    if y(DATA_WIDTH-1) = '1' then
                        x <= x - shift_right(y, count);
                        y <= y + shift_right(x, count);
                        angle <= angle - arctan_rom(count);
                    else
                        x <= x + shift_right(y, count);
                        y <= y - shift_right(x, count);
                        angle <= angle + arctan_rom(count);
                    end if;
                    count <= count + 1;
                else
                    temp := std_logic_vector(x) * K;
                    busy <= '0';
                    ready <= '1';
                end if;
            end if;
            r_out <= temp(2*DATA_WIDTH-3 downto DATA_WIDTH-2);
        end if;
    end process;
    theta_out <= std_logic_vector(angle);

end rtl;
