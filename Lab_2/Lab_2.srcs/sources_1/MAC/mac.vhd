library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity mac is
    generic(
        N : integer := 16
    );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           start : in STD_LOGIC;
           A : in std_logic_vector (N-1 downto 0);
           B : in std_logic_vector (N-1 downto 0);
           S : out std_logic_vector (N-1 downto 0);
           ready_mac : out STD_LOGIC);
end mac;

architecture Behavioral of mac is
    signal result :std_logic_vector(N-1 downto 0);
    signal reg_out :std_logic_vector(N-1 downto 0);
    signal sum : std_logic_vector(N-1 downto 0);
    signal start_mpy :STD_LOGIC;
    signal ready : STD_LOGIC;
    signal write_acc : STD_LOGIC;    
begin

    u_mult: entity work.mult
    generic map (
                N => N
             )
            port map (
                clk => clk,
                rst => rst,
                start => start_mpy,
                A => A,
                B => B,
                P => result,
                ready => ready);
    
    sum <= result + reg_out;
    
    u_reg: entity work.reg
    generic map (
                N => N
             )
            port map (
                clk => clk,
                rst => rst,
                en => write_acc,
                reg_in => sum,
                reg_out => reg_out);
                
    u_ctrl: entity work.controller
            port map (
                clk => clk,
                rst => rst,
                start => start,
                ready => ready,
                start_mpy => start_mpy,
                write_acc => write_acc,
                ready_mac => ready_mac);      
                
    S <= reg_out;               
           
end Behavioral;