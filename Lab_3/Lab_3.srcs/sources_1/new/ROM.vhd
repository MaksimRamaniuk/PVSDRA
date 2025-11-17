library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ROM is
    Generic ( N : integer := 12);
    Port ( clk : in STD_LOGIC;
           addr1 : in STD_LOGIC_VECTOR(2 downto 0);
           addr2 : in STD_LOGIC_VECTOR(2 downto 0);
           coef1 : out STD_LOGIC_VECTOR (N-1 downto 0);
           coef2 : out STD_LOGIC_VECTOR (N-1 downto 0));
end ROM;

architecture Behavioral of ROM is
type memory is array(0 to 7) of signed(N-1 downto 0);

constant rom1 : memory := (
    to_signed(0, N), -- 0
    to_signed(21, N), -- 0.0102
    to_signed(241, N), -- 0.1177
    to_signed(262, N), -- 0.1279
    to_signed(762, N), -- 0.3721
    to_signed(783, N), -- 0.3823
    to_signed(1003, N), -- 0.4898
    to_signed(1024, N)); -- 0.5
constant rom2 : memory := (
    to_signed(0, N), -- 0
    to_signed(762, N), -- 0.3721
    to_signed(241, N), -- 0.1177
    to_signed(1003, N), -- 0.4898
    to_signed(21, N), -- 0.0102
    to_signed(783, N), -- 0.3823
    to_signed(262, N), -- 0.1279
    to_signed(1024, N)); -- 0.5
begin
--    process(clk)
--    begin
--        if rising_edge(clk) then 
--            case addr1 is 
--                when "000" => coef1 <= std_logic_vector(rom1(0));
--                when "001" => coef1 <= std_logic_vector(rom1(1));
--                when "010" => coef1 <= std_logic_vector(rom1(2));
--                when "011" => coef1 <= std_logic_vector(rom1(3));
--                when "100" => coef1 <= std_logic_vector(rom1(4));
--                when "101" => coef1 <= std_logic_vector(rom1(5));
--                when "110" => coef1 <= std_logic_vector(rom1(6));
--                when "111" => coef1 <= std_logic_vector(rom1(7));
--                when others => coef1 <= (others => '0');
--            end case;
            
--            case addr2 is 
--                when "000" => coef2 <= std_logic_vector(rom2(0));
--                when "001" => coef2 <= std_logic_vector(rom2(1));
--                when "010" => coef2 <= std_logic_vector(rom2(2));
--                when "011" => coef2 <= std_logic_vector(rom2(3));
--                when "100" => coef2 <= std_logic_vector(rom2(4));
--                when "101" => coef2 <= std_logic_vector(rom2(5));
--                when "110" => coef2 <= std_logic_vector(rom2(6));
--                when "111" => coef2 <= std_logic_vector(rom2(7));
--                when others => coef2 <= (others => '0');
--            end case;            
--        end if;
--    end process;
    coef1 <= std_logic_vector(rom1(to_integer(unsigned(addr1))));
    coef2 <= std_logic_vector(rom2(to_integer(unsigned(addr2))));
end Behavioral;