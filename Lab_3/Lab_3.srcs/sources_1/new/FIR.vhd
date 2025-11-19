library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FIR is
    Generic ( N : integer := 12;
              Order : integer := 6);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           start : in STD_LOGIC;
           x : in STD_LOGIC_VECTOR(N-1 downto 0);
           y : out STD_LOGIC_VECTOR(N-1 downto 0);
           ready : out STD_LOGIC);
end FIR;

architecture Behavioral of FIR is
type shift_reg is array(0 to Order-1) of STD_LOGIC_VECTOR(N-1 downto 0);
signal reg : shift_reg := (others => (others => '0'));

signal bit_idx : integer range 0 to N-1 := 0;
signal calc, load : STD_LOGIC := '0';
signal done : STD_LOGIC := '0';

signal addr11, addr12, addr13 : STD_LOGIC_VECTOR(2 downto 0);
signal addr21, addr22, addr23 : STD_LOGIC_VECTOR(2 downto 0);

signal coef11, coef12, coef13 : STD_LOGIC_VECTOR(N-1 downto 0);
signal coef21, coef22, coef23 : STD_LOGIC_VECTOR(N-1 downto 0);

signal coef11_shift, coef12_shift, coef13_shift : STD_LOGIC_VECTOR(N-1 downto 0);
signal coef21_shift, coef22_shift, coef23_shift : STD_LOGIC_VECTOR(N-1 downto 0);

signal acc1, acc2 : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
signal acc1_prev, acc2_prev : STD_LOGIC_VECTOR(N-1 downto 0);

begin
    control_device: entity work.FSM
    generic map (N => N)
    port map(clk => clk, rst => rst, start => start, bit_idx => bit_idx, load => load, calc => calc, ready => done);
        
    ROM1: entity work.ROM
    generic map (N => N)
    port map (clk => clk, addr1 => addr11, addr2 => addr21, coef1 => coef11, coef2 => coef21);
        
    ROM2: entity work.ROM
    generic map (N => N)
    port map (clk => clk, addr1 => addr12, addr2 => addr22, coef1 => coef12, coef2 => coef22);
        
    ROM3: entity work.ROM
    generic map (N => N)
    port map (clk => clk, addr1 => addr13, addr2 => addr23, coef1 => coef13, coef2 => coef23);

--    coef12_shift <= coef12(N-1) & coef12(N-1 downto 1);
--    coef13_shift <= coef13(N-1) & coef13(N-1) & coef13(N-1 downto 2);

--    coef22_shift <= coef22(N-1) & coef22(N-1 downto 1);
--    coef23_shift <= coef23(N-1) & coef23(N-1) & coef23(N-1 downto 2);

--    acc1_prev <= acc1(N-1) & acc1(N-1) & acc1(N-1 downto 2);
--    acc2_prev <= acc2(N-1) & acc2(N-1) & acc2(N-1 downto 2);

    bit_count : process(clk)
    begin
        if rising_edge(clk) then
            if calc = '1' and bit_idx < (N - 3) then
                bit_idx <= bit_idx + 3;
            else 
                bit_idx <= 0;
            end if;
        end if;
    end process;  
    
    shift : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reg <= (others => (others => '0'));
            elsif load = '1' then
                for i in Order-1 downto 1 loop
                    reg(i) <= reg(i-1);
                end loop;
                reg(0) <= x;
            end if;
        end if;
    end process;
    
    accumulate : process(clk)
    variable temp : std_logic_vector(N-1 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if rst = '1' or start = '1' then 
                acc1 <= (others => '0');
                acc2 <= (others => '0');
            elsif calc = '1' then
            
                temp := coef11(N-1) & coef11(N-1) & coef11(N-1 downto 2);
                temp := temp + (coef12(N-1) & coef12(N-1 downto 1));
                
                if bit_idx > N/2 then
                    acc1 <= temp + (acc1(N-1) & acc1(N-1) & acc1(N-1) & acc1(N-1 downto 3)) - coef13;
                else
                    acc1 <= temp + (acc1(N-1) & acc1(N-1) & acc1(N-1) & acc1(N-1 downto 3)) + coef13;
                end if;
                
                temp := coef21(N-1) & coef21(N-1) & coef21(N-1 downto 2);
                temp := temp + (coef22(N-1) & coef22(N-1 downto 1));
                
                if bit_idx > N/2 then
                    acc2 <= temp + (acc2(N-1) & acc2(N-1) & acc2(N-1) & acc2(N-1 downto 3)) - coef23;
                else
                    acc2 <= temp + (acc2(N-1) & acc2(N-1) & acc2(N-1) & acc2(N-1 downto 3)) + coef23;
                end if;
--                if bit_idx = (N-3) then
--                    acc1 <= acc1_prev - ('0' & coef11(N-1 downto 1)) + coef12_shift + coef13_shift;
--                    acc2 <= acc2_prev - ('0' & coef21(N-1 downto 1)) + coef22_shift + coef23_shift;
--                else
--                    acc1 <= acc1_prev + coef11 + coef12_shift + coef13_shift;
--                    acc2 <= acc2_prev + coef21 + coef22_shift + coef23_shift;
--                end if;
            end if;
        end if;
    end process;

    addr11 <= reg(2)(bit_idx) & reg(1)(bit_idx) & reg(0)(bit_idx);
    addr12 <= reg(2)(bit_idx+1) & reg(1)(bit_idx+1) & reg(0)(bit_idx+1);
    addr13 <= reg(2)(bit_idx+2) & reg(1)(bit_idx+2) & reg(0)(bit_idx+2);
    
    addr21 <= reg(5)(bit_idx) & reg(4)(bit_idx) & reg(3)(bit_idx);
    addr22 <= reg(5)(bit_idx+1) & reg(4)(bit_idx+1) & reg(3)(bit_idx+1);
    addr23 <= reg(5)(bit_idx+2) & reg(4)(bit_idx+2) & reg(3)(bit_idx+2);  
     
    y <= (others => '0') when rst = '1' else
--         (acc1(N-1) & acc1(N-1 downto 1)) + (acc2(N-1) & acc2(N-1 downto 1)) when done = '1';
         acc1 + acc2 when done = '1';
    
    ready <= done;
end Behavioral;
