library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FIR is
    Generic ( N : integer := 12;
              Order : integer := 6;
              BAAT : integer := 3);
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

    type addr_array is array(0 to BAAT-1) of STD_LOGIC_VECTOR(2 downto 0);
    type coef_array is array(0 to BAAT-1) of STD_LOGIC_VECTOR(N-1 downto 0);
    type coef_array_shift is array(0 to BAAT-2) of STD_LOGIC_VECTOR(N-1 downto 0);
    
    signal addr1 : addr_array;
    signal addr2 : addr_array;
    
    signal coef1 : coef_array;
    signal coef2 : coef_array;
    
    signal coef1_shift : coef_array_shift;
    signal coef2_shift : coef_array_shift;
    
    signal sum1, sum2 : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
    signal acc1, acc2 : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
    signal acc1_prev, acc2_prev : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
begin
    control_device: entity work.FSM
    generic map (N => N, BAAT => BAAT)
    port map(clk => clk, rst => rst, start => start, bit_idx => bit_idx, load => load, calc => calc, ready => done);
        
--    ROM1: entity work.ROM
--    generic map (N => N)
--    port map (clk => clk, addr1 => addr1(0), addr2 => addr2(0), coef1 => coef1(0), coef2 => coef2(0));
        
--    ROM2: entity work.ROM
--    generic map (N => N)
--    port map (clk => clk, addr1 => addr1(1), addr2 => addr2(1), coef1 => coef1(1), coef2 => coef2(1));
        
--    ROM3: entity work.ROM
--    generic map (N => N)
--    port map (clk => clk, addr1 => addr1(2), addr2 => addr2(2), coef1 => coef1(2), coef2 => coef2(2));

--    coef1_shift(0) <= coef1(0)(N-1) & coef1(0)(N-1) & coef1(0)(N-1 downto 2);
--    coef1_shift(1) <= coef1(1)(N-1) & coef1(1)(N-1 downto 1);
--    coef2_shift(0) <= coef2(0)(N-1) & coef2(0)(N-1) & coef2(0)(N-1 downto 2);
--    coef2_shift(1) <= coef2(1)(N-1) & coef2(1)(N-1 downto 1);  
    gen_rom: for i in 0 to BAAT-1 generate
    begin
        ROMi: entity work.ROM
        generic map (N => N)
        port map ( clk => clk, addr1 => addr1(i), addr2 => addr2(i), coef1 => coef1(i), coef2 => coef2(i));
    end generate;

 
    coef_shift : process(coef1, coef2)
    variable temp1, temp2 : STD_LOGIC_VECTOR(N-1 downto 0); 
    begin 
        for i in 0 to BAAT-2 loop
            temp1 := coef1(i);
            temp2 := coef2(i);
            for j in 0 to (BAAT-i-2) loop
                temp1 := temp1(N-1) & temp1(N-1 downto 1);
                temp2 := temp2(N-1) & temp2(N-1 downto 1);
            end loop;
            coef1_shift(i) <= temp1;
            coef2_shift(i) <= temp2;
        end loop;
    end process;
    
    bit_count : process(clk)
    begin
        if rising_edge(clk) then
            if calc = '1' and bit_idx < (N - BAAT) then
                bit_idx <= bit_idx + BAAT;
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

--    sum1 <= coef1_shift(0) + coef1_shift(1);
--    sum2 <= coef2_shift(0) + coef2_shift(1);
    
--    acc1_prev <= acc1(N-1) & acc1(N-1) & acc1(N-1) & acc1(N-1 downto 3);
--    acc2_prev <= acc2(N-1) & acc2(N-1) & acc2(N-1) & acc2(N-1 downto 3);
    
    sum_comb: process(coef1_shift, coef2_shift)
    variable s1, s2 : STD_LOGIC_VECTOR(N-1 downto 0);
    begin
        s1 := (others => '0');
        s2 := (others => '0');
    
        for i in 0 to BAAT-2 loop
            s1 := s1 + coef1_shift(i);
            s2 := s2 + coef2_shift(i);
        end loop;
    
        sum1 <= s1;
        sum2 <= s2;
    end process;
    
    shift_acc : process(acc1,acc2)
        variable temp1, temp2 : STD_LOGIC_VECTOR(N-1 downto 0); 
    begin
        temp1 := acc1;
        temp2 := acc2;
        for i in 0 to BAAT-1 loop
            temp1 := temp1(N-1) & temp1(N-1 downto 1);
            temp2 := temp2(N-1) & temp2(N-1 downto 1);
        end loop;
        
        acc1_prev <= temp1;
        acc2_prev <= temp2;
    end process;
    
    accumulate : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or start = '1' then 
                acc1 <= (others => '0');
                acc2 <= (others => '0');
            elsif calc = '1' then
                if bit_idx = (N-BAAT) then
                    acc1 <= sum1 + acc1_prev - coef1(BAAT-1);
                    acc2 <= sum2 + acc2_prev - coef2(BAAT-1);
--                    acc1 <= sum1 + acc1_prev - coef13;
--                    acc2 <= sum2 + acc2_prev - coef23;
                else
                    acc1 <= sum1 + acc1_prev + coef1(BAAT-1);
                    acc2 <= sum2 + acc2_prev + coef2(BAAT-1);
--                    acc1 <= sum1 + acc1_prev + coef13;
--                    acc2 <= sum2 + acc2_prev + coef23;
                end if;
            end if;
        end if;
    end process;
 
    gen_addr: for i in 0 to BAAT-1 generate
    begin
        addr1(i) <= reg(2)(bit_idx+i) & reg(1)(bit_idx+i) & reg(0)(bit_idx+i);
        addr2(i) <= reg(5)(bit_idx+i) & reg(4)(bit_idx+i) & reg(3)(bit_idx+i);
    end generate;

    y <= (others => '0') when rst = '1' else
         acc1 + acc2 when done = '1';
    
    ready <= done;
end Behavioral;