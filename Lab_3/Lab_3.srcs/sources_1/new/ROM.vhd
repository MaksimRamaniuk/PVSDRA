library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ROM is
    Generic ( N : integer := 12);
    Port ( clk : in STD_LOGIC;
           addr1 : in STD_LOGIC_VECTOR(1 downto 0);
           addr2 : in STD_LOGIC_VECTOR(1 downto 0);
           coef1 : out STD_LOGIC_VECTOR (N-1 downto 0);
           coef2 : out STD_LOGIC_VECTOR (N-1 downto 0));
end ROM;

architecture Behavioral of ROM is
type memory is array(0 to 7) of signed(N-1 downto 0);

constant rom1 : memory := (
    to_signed(-512, N),     
    to_signed(-472, N),       
    to_signed(-241, N),     
    to_signed(-200, N),      
    to_signed(200, N),      
    to_signed(241, N),      
    to_signed(472, N),      
    to_signed(512, N));    
constant rom2 : memory := (
    to_signed(-512, N),     
    to_signed(200, N),     
    to_signed(-241, N),      
    to_signed(472, N),      
    to_signed(-472, N),      
    to_signed(241, N),     
    to_signed(-200, N),     
    to_signed(512, N));

begin
    coef1 <= std_logic_vector(rom1(to_integer(unsigned(addr1))));
    coef2 <= std_logic_vector(rom2(to_integer(unsigned(addr2))));
end Behavioral;