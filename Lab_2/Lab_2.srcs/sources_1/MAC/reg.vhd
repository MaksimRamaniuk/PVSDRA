library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity reg is
generic(
        N : integer := 16
    );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           reg_in : in std_logic_vector (N-1 downto 0);
           reg_out : out std_logic_vector (N-1 downto 0));
end reg;

architecture Behavioral of reg is
    signal tmp: std_logic_vector(N-1 downto 0) := (others => '0');
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                tmp <= (others => '0');
            elsif en = '1' then
                tmp <= reg_in;
            end if;
        end if;
    end process;
reg_out <= tmp;
end Behavioral;
