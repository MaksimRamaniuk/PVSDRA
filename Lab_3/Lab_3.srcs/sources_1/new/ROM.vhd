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
    to_signed(0, N),
    to_signed(40, N),
    to_signed(271, N),
    to_signed(312, N),
    to_signed(712, N),
    to_signed(753, N),
    to_signed(984, N),
    to_signed(1024, N));
constant rom2 : memory := (
    to_signed(0, N),
    to_signed(712, N),
    to_signed(271, N),
    to_signed(984, N),
    to_signed(40, N),
    to_signed(753, N),
    to_signed(312, N),
    to_signed(1024, N));

begin
    coef1 <= std_logic_vector(rom1(to_integer(unsigned(addr1))));
    coef2 <= std_logic_vector(rom2(to_integer(unsigned(addr2))));
end Behavioral;