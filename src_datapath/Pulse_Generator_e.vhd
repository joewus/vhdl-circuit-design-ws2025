LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.Project_Constants_Pkg.ALL;

ENTITY Pulse_Generator_e IS
    GENERIC ( 
        clk_freq_c : INTEGER := SYSTEM_FREQ_C 
    ); 
    PORT ( 
        clk_i   : IN  std_logic;
        rst_n_i : IN  std_logic;
        tick_o  : OUT std_logic
    );
END Pulse_Generator_e;