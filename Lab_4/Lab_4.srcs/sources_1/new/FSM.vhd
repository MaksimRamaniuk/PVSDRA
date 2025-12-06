library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
    Generic (N : integer := 9);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           start : in STD_LOGIC;
           count : in integer;
           load : out STD_LOGIC;
           calc : out STD_LOGIC;
           ready : out STD_LOGIC);
end FSM;

architecture Behavioral of FSM is
    type state_type is (IDLE, INIT, CALCULATE);
    signal state : state_type := IDLE;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ready <= '0';
                load <= '0';
                calc <= '0';
            else
                case state is 
                    when IDLE =>
                        ready <= '0';
                        if start = '1' then
                            load <= '1';
                            state <= INIT;
                        end if;
                        
                    when INIT =>
                        load <= '0';
                        calc <= '1';
                        state <= CALCULATE;
                        
                    when CALCULATE => 
                        if count = N-1 then
                            calc <= '0';
                            ready <= '1';
                            state <= IDLE;
                        else
                            state <= CALCULATE;
                        end if;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
