LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ya_uart_pkg.ALL;

ARCHITECTURE ya_uart_rx_a OF ya_uart_rx_e IS

    TYPE uart_rx_state_t IS (
        rx_idle_st, rx_start_st, 
        rx_bit0_st, rx_bit1_st, rx_bit2_st, rx_bit3_st,
        rx_bit4_st, rx_bit5_st, rx_bit6_st, rx_bit7_st, 
        rx_stop_st
    );

    SIGNAL states, nextstates : uart_rx_state_t;
    SIGNAL shift_reg_s        : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL delay_rx_s         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL fall_edge_s        : STD_LOGIC;
    SIGNAL sample_point_s     : STD_LOGIC;

BEGIN

    proc_rx_comb: PROCESS(states, fall_edge_s, baudtick_i, baudhalf_i)
    BEGIN
        nextstates     <= states;
        sample_point_s <= '0';
        baudstart_o    <= '0';

        CASE states IS
            WHEN rx_idle_st =>
                IF fall_edge_s = '1' THEN
                    nextstates  <= rx_start_st;
                    baudstart_o <= '1';
                END IF;

            WHEN rx_start_st =>
                IF baudtick_i = '1' THEN 
                    nextstates <= rx_bit0_st; 
                END IF;

            WHEN rx_bit0_st =>
                IF baudhalf_i = '1' THEN sample_point_s <= '1';     END IF;
                IF baudtick_i = '1' THEN nextstates     <= rx_bit1_st; END IF;

            WHEN rx_bit1_st =>
                IF baudhalf_i = '1' THEN sample_point_s <= '1';     END IF;
                IF baudtick_i = '1' THEN nextstates     <= rx_bit2_st; END IF;

            WHEN rx_bit2_st =>
                IF baudhalf_i = '1' THEN sample_point_s <= '1';     END IF;
                IF baudtick_i = '1' THEN nextstates     <= rx_bit3_st; END IF;

            WHEN rx_bit3_st =>
                IF baudhalf_i = '1' THEN sample_point_s <= '1';     END IF;
                IF baudtick_i = '1' THEN nextstates     <= rx_bit4_st; END IF;

            WHEN rx_bit4_st =>
                IF baudhalf_i = '1' THEN sample_point_s <= '1';     END IF;
                IF baudtick_i = '1' THEN nextstates     <= rx_bit5_st; END IF;

            WHEN rx_bit5_st =>
                IF baudhalf_i = '1' THEN sample_point_s <= '1';     END IF;
                IF baudtick_i = '1' THEN nextstates     <= rx_bit6_st; END IF;

            WHEN rx_bit6_st =>
                IF baudhalf_i = '1' THEN sample_point_s <= '1';     END IF;
                IF baudtick_i = '1' THEN nextstates     <= rx_bit7_st; END IF;

            WHEN rx_bit7_st =>
                IF baudhalf_i = '1' THEN sample_point_s <= '1';     END IF;
                IF baudtick_i = '1' THEN nextstates     <= rx_stop_st; END IF;

            WHEN rx_stop_st =>
                IF baudtick_i = '1' THEN 
                    nextstates <= rx_idle_st; 
                END IF;

            WHEN OTHERS =>
                nextstates <= rx_idle_st;
        END CASE;
    END PROCESS;

    -- Guideline 441: Sequential process structure
    proc_seq: PROCESS(clk_i, rst_i)
    BEGIN
        IF rst_i = '0' THEN
            states      <= rx_idle_st;
            shift_reg_s <= (OTHERS => '0');
            delay_rx_s  <= "11";
            
        ELSIF (clk_i'event AND clk_i = '1') THEN
            states     <= nextstates;
            delay_rx_s <= delay_rx_s(0) & rx_i;

            IF sample_point_s = '1' THEN
                shift_reg_s <= rx_i & shift_reg_s(7 DOWNTO 1); 
            END IF;
        END IF;
    END PROCESS;

    fall_edge_s <= delay_rx_s(1) AND NOT delay_rx_s(0);

    -- Guideline 441: Output registration process
    proc_output: PROCESS(clk_i, rst_i)
    BEGIN
        IF rst_i = '0' THEN
            ascii_o   <= (OTHERS => '0');
            rxready_o <= '0';
            
        ELSIF (clk_i'event AND clk_i = '1') THEN
            rxready_o <= '0';
            
            IF states = rx_stop_st AND baudtick_i = '1' THEN
                ascii_o   <= shift_reg_s;
                rxready_o <= '1';
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE ya_uart_rx_a;