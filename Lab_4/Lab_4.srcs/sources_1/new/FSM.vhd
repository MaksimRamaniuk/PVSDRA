library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
    Generic (N : integer := 9);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           start : in STD_LOGIC;
           cordic_start : out STD_LOGIC;
           busy : out STD_LOGIC;
           mult : out STD_LOGIC;
           ready : out STD_LOGIC);
end FSM;

architecture Behavioral of FSM is
    type state_type is (IDLE, START_CORDIC, JOB, SCALE, DONE);
    signal state : state_type := IDLE;
    signal count : integer range 0 to N-1 := 0;
    signal cnt : integer;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ready <= '0';
                mult <= '0';
                busy <= '0';
                count <= 0;
            else
                case state is 
                    when IDLE =>
                        if start = '1' then
                            count <= 0;
                            busy <= '1';
                            ready <= '0';
                            state <= JOB;
                        end if;
--                    when START_CORDIC => 
                    
                    when JOB => 
                        if count < N then
                            count <= count + 1;
                        else
                            busy <= '0';
                            state <= SCALE;
                        end if;
                        
                    when SCALE =>
                        mult <= '1';
                        state <= DONE;
                        
                    when DONE =>
                        mult <= '0';
                        ready <= '1';
                        state <= IDLE;
                        
                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
