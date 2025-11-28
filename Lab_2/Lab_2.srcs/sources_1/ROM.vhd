library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ROM is
    generic (
        N : integer := 15);
    Port ( 
        clk : in STD_LOGIC;
        addr : in integer;
        coef : out STD_LOGIC_VECTOR (N-1 downto 0));
end ROM;

architecture Behavioral of ROM is
    type memory is array (0 to 5) of signed(N-1 downto 0);
    constant coeffs : memory :=(
    0 => to_signed(148, N), -- b0 = 0,0180989330075144
    1 => to_signed(445, N), -- b1 = 0,0542967990225433
--    2 => to_signed(445, N), -- b2 = 0,0542967990225433
--    3 => to_signed(148, N), -- b3 = 0,0180989330075144
    2 => to_signed(14418, N), -- a1 = -1,76004188034317
    3 => to_signed(-9690, N), -- a2 = 1,18289326203783
    4 => to_signed(2278, N), -- a3 = -0,278059917634546
    5 => to_signed(8192, N)); --a0 = 1

begin
    process(clk)
    begin
        if rising_edge(clk) then
            case addr is
                when 0 => coef <= std_logic_vector(coeffs(0));
                when 1 => coef <= std_logic_vector(coeffs(1));
                when 2 => coef <= std_logic_vector(coeffs(1));
                when 3 => coef <= std_logic_vector(coeffs(0));
                when 4 => coef <= std_logic_vector(coeffs(2));
                when 5 => coef <= std_logic_vector(coeffs(3));
                when 6 => coef <= std_logic_vector(coeffs(4));
                when 7 => coef <= std_logic_vector(coeffs(5));
                when others => coef <= (others => '0');
            end case;
        end if;
    end process;
end Behavioral;
