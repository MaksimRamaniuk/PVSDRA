library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           start : in STD_LOGIC;
           ready : in STD_LOGIC;
           start_mpy : out STD_LOGIC;
           write_acc : out STD_LOGIC;
           ready_mac : out STD_LOGIC);
end controller;

architecture Behavioral of controller is
    type state_type is (IDLE, START_MULT, WAIT_MULT, DONE);
    signal state : state_type := IDLE;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                start_mpy <= '0';
                write_acc <= '0';
                ready_mac <= '0';
            else
                start_mpy <= '0';
                write_acc <= '0';
                ready_mac <= '0';   
            
                case state is 
                    when IDLE => 
                        if start = '1' then
                            start_mpy <= '1';
                            state <= START_MULT;
                        end if;
                    
                    when START_MULT =>
                        state <= WAIT_MULT;
                        
                    when WAIT_MULT => 
                        if ready = '1' then
                            write_acc <= '1';
                            state <= DONE;                        
                        end if;
                     
                     when DONE =>
                         ready_mac <= '1';  
                         state <= IDLE;   
              
                end case;         
            end if;
        end if;
    end process;

end Behavioral;
