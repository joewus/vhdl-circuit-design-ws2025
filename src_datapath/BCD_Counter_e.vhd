LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.Project_Constants_Pkg.ALL;

ENTITY BCD_Counter_e IS
    PORT ( 
        clk_i       : IN  std_logic;
        rst_n_i     : IN  std_logic;
        en_i        : IN  std_logic; 
        tick_1ms_i  : IN  std_logic;
        limit_cfg_i : IN  std_logic_vector(LIMIT_WIDTH_C - INT_ONE_C DOWNTO 0);
        bcd_count_o : OUT std_logic_vector(LIMIT_WIDTH_C - INT_ONE_C DOWNTO 0)
    );
END BCD_Counter_e;