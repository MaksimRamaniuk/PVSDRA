library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           mac_ready : in STD_LOGIC;
           addr : out integer;
           req : out STD_LOGIC;
           wr_x : out STD_LOGIC;
           wr_y : out STD_LOGIC;
           ready : out STD_LOGIC;
           rst : out STD_LOGIC);
end FSM;

architecture Behavioral of FSM is
    type state_type is (IDLE, X_LOAD, CF_LOAD, REQ_PULSE, ON_MAC, Y_WRITE, DONE);
    signal state : state_type := IDLE;
    signal count : integer := 0;
    signal write_x : STD_LOGIC := '0';
    signal write_y : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            case state is 
                when IDLE => 
                    if start = '1' then
                        rst <= '1';
                        ready <= '0';
                        state <= X_LOAD;
                    else 
                        rst <= '0';
                        ready <= '1';
                    end if;
                    
                when X_LOAD =>
                    rst <= '0';
                    write_x <= '1';
                    state <= CF_LOAD;
                    
                when CF_LOAD =>
                    write_x <= '0';
                    state <= REQ_PULSE;
                
                when REQ_PULSE =>
                    req <= '1';
                    state <= ON_MAC;
                    
                when ON_MAC =>
                    req <= '0';
                    if mac_ready = '1' then
                        if count = 7 then
                            count <= 0;
                            state <= Y_WRITE;
                        else 
                            count <= count + 1;
                            state <= CF_LOAD;
                        end if;
                    end if;
                
                when Y_WRITE =>
                    write_y <= '1';
                    state <= DONE;
                
                when DONE =>
                    write_y <= '0';
                    ready <= '1';
                    state <= IDLE;
                
            end case;
        end if;
    end process;
    
    addr <= count;
    wr_x <= write_x;
    wr_y <= write_y;
end Behavioral;
