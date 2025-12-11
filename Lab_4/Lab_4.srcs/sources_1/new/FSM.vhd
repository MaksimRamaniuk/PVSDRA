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
           done : out STD_LOGIC;
           ready : out STD_LOGIC;
           start_pol : out STD_LOGIC;
           complete : in STD_LOGIC);
end FSM;

architecture Behavioral of FSM is
    type state_type is (IDLE, INIT, CALCULATE, POL);
    signal state : state_type := IDLE;
    signal donec : STD_LOGIC;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ready <= '0';
                start_pol <= '0';
                load <= '0';
                calc <= '0';
                donec <= '0';
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
                            donec <= '1';
                            state <= POL;
                        else
                            state <= CALCULATE;
                        end if;
                        
                    when POL => 
                        start_pol <= '0';
                        if donec = '1' then
                            donec <= '0';
                            start_pol <= '1';
                            state <= POL;
                        elsif complete = '1' then
                            ready <= '1';
                            state <= IDLE;
                        end if;                    
                end case;
            end if;
        end if;
    end process;
    done <= donec;
end Behavioral;
