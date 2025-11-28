library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity mult is
    generic(
        N : integer := 16
    );
    Port (
        clk   : in  STD_LOGIC;
        rst   : in  STD_LOGIC;
        start : in  STD_LOGIC;
        A     : in  std_logic_vector(N-1 downto 0);
        B     : in  std_logic_vector(N-1 downto 0);
        P     : out std_logic_vector(N-1 downto 0);
        ready : out STD_LOGIC
    );
end mult;

architecture Behavioral of mult is
    signal mt   : std_logic_vector(N-1 downto 0);      -- множитель
    signal mn   : std_logic_vector(N-1 downto 0);      -- множимое
    signal sum  : std_logic_vector(2*N-1 downto 0);    -- сумма частичных произведений
    constant zeros : std_logic_vector(N-1 downto 0) := (others => '0');
    
    
    signal count : integer range 0 to N;
    signal busy  : std_logic := '0';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                mt    <= (others => '0');
                mn    <= (others => '0');
                sum   <= (others => '0');
                count <= 0;
                busy  <= '0';
                ready <= '0';
                
            else
                if start = '1' and busy = '0' then
                    mt    <= A;
                    mn    <= B;
                    sum   <= (others => '0');
                    ready <= '0';
                    count <= 0;
                    busy  <= '1';
                    
                elsif busy = '1' then
                    if count = N-1 then
                        if A(N-1) = '1' then
                            sum <= sum - (mn & zeros);
                        end if;
                        busy  <= '0';
                        ready <= '1';
                    else
                        if mt(0) = '1' then
                            sum <= mn(N-1) & (sum(2*N-1 downto N) + mn) & sum(N-1 downto 1);
                        else
                            sum <= sum(2*N-1) & sum(2*N-1 downto 1);
                        end if;
                        
                        mt    <= '0' & mt(N-1 downto 1);
                        count <= count + 1;
                    end if;
                end if;
            end if;
        end if;
            P <= sum(2*N-2 downto N-1) + sum(N-2);
    end process;

end Behavioral;