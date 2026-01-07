LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ya_uart_pkg.ALL;

ARCHITECTURE ya_baudrate_a OF ya_baudrate_e IS

    SIGNAL baud_cnt_s     : INTEGER RANGE 0 TO C_BAUD_CNT_MAX;
    SIGNAL full_max_s     : INTEGER RANGE 0 TO C_BAUD_CNT_MAX;
    SIGNAL half_max_s     : INTEGER RANGE 0 TO C_BAUD_CNT_MAX;

BEGIN

    full_max_s <= C_DIV_9600_FULL_MAX WHEN baud_sel_i = '0' ELSE C_DIV_19200_FULL_MAX;
    half_max_s <= C_DIV_9600_HALF_MAX WHEN baud_sel_i = '0' ELSE C_DIV_19200_HALF_MAX;

    proc_baud_counter: PROCESS(clk_i, rst_i)
    BEGIN
        -- Guideline 444: 'if' handles reset only
        IF rst_i = '0' THEN
            baud_cnt_s <= 0;
            
        ELSIF (clk_i'event AND clk_i = '1') THEN
            
            IF baudstart_i = '1' THEN
                baud_cnt_s <= 0;
            ELSE
                IF baud_cnt_s >= full_max_s THEN
                    baud_cnt_s <= 0;
                ELSE
                    baud_cnt_s <= baud_cnt_s + C_INCREMENT;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    baudtick_o <= '1' WHEN (baud_cnt_s = full_max_s) ELSE '0';
    baudhalf_o <= '1' WHEN (baud_cnt_s = half_max_s) ELSE '0';

END ARCHITECTURE ya_baudrate_a;