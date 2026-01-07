LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.Project_Constants_Pkg.ALL;

ARCHITECTURE Pulse_Generator_a OF Pulse_Generator_e IS
    CONSTANT CYCLES_PER_MS : integer := clk_freq_c / MS_PER_SEC_C;
    SIGNAL counter_r       : integer RANGE 0 TO CYCLES_PER_MS - INT_ONE_C;
BEGIN
    PROCESS(clk_i, rst_n_i)
    BEGIN
        IF (rst_n_i = '0') THEN
            counter_r <= 0;
            tick_o    <= '0';
        ELSIF rising_edge(clk_i) THEN
            tick_o <= '0'; 
            
            IF (counter_r = CYCLES_PER_MS - INT_ONE_C) THEN
                tick_o    <= BIT_HIGH_C;
                counter_r <= 0;
            ELSE
                counter_r <= counter_r + INT_ONE_C;
            END IF;
        END IF;
    END PROCESS;
END Pulse_Generator_a;