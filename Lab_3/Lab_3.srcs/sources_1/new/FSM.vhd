library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
    Generic ( N : integer := 12);
    Port (  clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            start : in STD_LOGIC;
            bit_idx : in integer;
            load : out STD_LOGIC;
            calc : out STD_LOGIC;
            ready : out STD_LOGIC);
end FSM;

architecture Behavioral of FSM is
type state_type is (IDLE, SHIFT, CALCULATE, DONE);
signal state : state_type := IDLE;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then 
                ready <= '0';
                load <= '0';
                calc <= '0';
                state <= IDLE;
            else
                case state is 
                    when IDLE =>
                        ready <= '0';
                        if start = '1' then
                            load <= '1';
                            state <= SHIFT;
                        end if;
                        
                    when SHIFT =>
                        load <= '0';
                        calc <= '1';
                        state <= CALCULATE;
                        
                    when CALCULATE =>
                        if bit_idx >= N-3 then
                            calc <= '0';
                            state <= DONE;
                        else 
                            state <= CALCULATE;
                        end if;
                        
                    when DONE =>
                        ready <= '1';
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;
end Behavioral;