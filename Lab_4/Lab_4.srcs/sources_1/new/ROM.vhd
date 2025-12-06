library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ROM is
    Generic ( DATA_WIDTH : integer := 9);
    Port ( addr : in integer;
           coef : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0));
end ROM;

architecture Behavioral of ROM is
    type memory is  array(0 to 8) of std_logic_vector(DATA_WIDTH-1 downto 0);
    constant arctans: memory:= (
        std_logic_vector(to_signed(101, DATA_WIDTH)),
        std_logic_vector(to_signed(59, DATA_WIDTH)),
        std_logic_vector(to_signed(31, DATA_WIDTH)), 
        std_logic_vector(to_signed(16, DATA_WIDTH)), 
        std_logic_vector(to_signed(8, DATA_WIDTH)),  
        std_logic_vector(to_signed(4, DATA_WIDTH)),  
        std_logic_vector(to_signed(2, DATA_WIDTH)),  
        std_logic_vector(to_signed(1, DATA_WIDTH)),  
        std_logic_vector(to_signed(0, DATA_WIDTH)));    
begin
    coef <= arctans(addr);
end Behavioral;
