LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.Project_Constants_Pkg.ALL;

ENTITY Debouncer_e IS
    PORT (
        clk_i          : IN  std_logic;
        rst_n_i        : IN  std_logic;
        data_i         : IN  std_logic;
        debounce_cfg_i : IN  std_logic_vector(DEBOUNCE_WIDTH_C - INT_ONE_C DOWNTO 0);
        tick_1ms_i     : IN  std_logic;
        pulse_o        : OUT std_logic
    );
END Debouncer_e;