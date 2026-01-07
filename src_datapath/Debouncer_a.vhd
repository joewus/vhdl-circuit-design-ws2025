LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.Project_Constants_Pkg.ALL;

ARCHITECTURE Debouncer_a OF Debouncer_e IS
    SIGNAL count_s     : unsigned(DEBOUNCE_WIDTH_C - INT_ONE_C DOWNTO 0);
    SIGNAL data_sync_r : std_logic;
    SIGNAL data_last_r : std_logic;
    SIGNAL triggered_r : std_logic;
BEGIN
    PROCESS(clk_i, rst_n_i)
    BEGIN
        IF (rst_n_i = '0') THEN
            count_s     <= to_unsigned(0, DEBOUNCE_WIDTH_C);
            data_sync_r <= '0';
            data_last_r <= '0';
            triggered_r <= '0';
            pulse_o     <= '0';
        ELSIF rising_edge(clk_i) THEN
            pulse_o <= '0'; 
            
            data_sync_r <= data_i;

            -- Trigger on Rising Edge
            IF (data_sync_r = BIT_HIGH_C AND data_last_r = '0') THEN
                count_s     <= to_unsigned(0, DEBOUNCE_WIDTH_C);
                triggered_r <= BIT_HIGH_C;
            END IF;

            -- Timer Logic
            IF (triggered_r = BIT_HIGH_C AND tick_1ms_i = BIT_HIGH_C) THEN
                IF (count_s >= unsigned(debounce_cfg_i)) THEN
                    IF (data_sync_r = BIT_HIGH_C) THEN
                        pulse_o <= BIT_HIGH_C;
                    END IF;
                    triggered_r <= '0';
                ELSE
                    count_s <= count_s + INT_ONE_C;
                END IF;
            END IF;
            
            data_last_r <= data_sync_r;
        END IF;
    END PROCESS;
END Debouncer_a;