LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ya_uart_pkg.ALL;

ARCHITECTURE ya_uart_tx_a OF ya_uart_tx_e IS

    TYPE uart_tx_state_t IS (
        tx_idle_st, 
        tx_start_st, 
        tx_bit0_st, tx_bit1_st, tx_bit2_st, tx_bit3_st,
        tx_bit4_st, tx_bit5_st, tx_bit6_st, tx_bit7_st, 
        tx_stop_st
    );

    SIGNAL states, nextstates : uart_tx_state_t;
    SIGNAL shift_reg_s        : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL tx_line_s          : STD_LOGIC;
    SIGNAL load_data_s        : STD_LOGIC;
    SIGNAL txready_s          : STD_LOGIC;

BEGIN

    -- PROCESS 1: Combinatorial next-state and outputs
    proc_tx_comb: PROCESS(states, baudtick_i, txdata_i, txvalid_i, shift_reg_s)
    BEGIN
        -- Default assignments
        nextstates  <= states;
        tx_line_s   <= '1';  -- idle high
        load_data_s <= '0';
        txready_s   <= '0';

        CASE states IS
            WHEN tx_idle_st =>
                tx_line_s <= '1';
                txready_s <= '1';
                IF txvalid_i = '1' THEN
                    load_data_s <= '1';
                    nextstates  <= tx_start_st;
                END IF;

            WHEN tx_start_st =>
                tx_line_s <= '0';  -- start bit
                IF baudtick_i = '1' THEN 
                    nextstates <= tx_bit0_st; 
                END IF;

            WHEN tx_bit0_st => 
                tx_line_s <= shift_reg_s(0); 
                IF baudtick_i = '1' THEN nextstates <= tx_bit1_st; END IF;

            WHEN tx_bit1_st => 
                tx_line_s <= shift_reg_s(1); 
                IF baudtick_i = '1' THEN nextstates <= tx_bit2_st; END IF;

            WHEN tx_bit2_st => 
                tx_line_s <= shift_reg_s(2); 
                IF baudtick_i = '1' THEN nextstates <= tx_bit3_st; END IF;

            WHEN tx_bit3_st => 
                tx_line_s <= shift_reg_s(3); 
                IF baudtick_i = '1' THEN nextstates <= tx_bit4_st; END IF;

            WHEN tx_bit4_st => 
                tx_line_s <= shift_reg_s(4); 
                IF baudtick_i = '1' THEN nextstates <= tx_bit5_st; END IF;

            WHEN tx_bit5_st => 
                tx_line_s <= shift_reg_s(5); 
                IF baudtick_i = '1' THEN nextstates <= tx_bit6_st; END IF;

            WHEN tx_bit6_st => 
                tx_line_s <= shift_reg_s(6); 
                IF baudtick_i = '1' THEN nextstates <= tx_bit7_st; END IF;

            WHEN tx_bit7_st => 
                tx_line_s <= shift_reg_s(7); 
                IF baudtick_i = '1' THEN nextstates <= tx_stop_st; END IF;

            WHEN tx_stop_st =>
                tx_line_s <= '1';  -- stop bit
                IF baudtick_i = '1' THEN 
                    nextstates <= tx_idle_st; 
                END IF;

            WHEN OTHERS => 
                nextstates <= tx_idle_st;
        END CASE;
    END PROCESS;

    -- PROCESS 2: Sequential state and shift register
    proc_seq: PROCESS(clk_i, rst_i)
    BEGIN
        IF rst_i = '0' THEN
            states      <= tx_idle_st;
            shift_reg_s <= (OTHERS => '1');  -- all 1s for mark
            
        ELSIF (clk_i'event AND clk_i = '1') THEN
            states <= nextstates;
            IF load_data_s = '1' THEN
                shift_reg_s <= txdata_i;
            END IF;
        END IF;
    END PROCESS;

    -- PROCESS 3: Registered outputs
    proc_output: PROCESS(clk_i, rst_i)
    BEGIN
        IF rst_i = '0' THEN
            tx_o      <= '1';
            txready_o <= '0';
            
        ELSIF (clk_i'event AND clk_i = '1') THEN
            tx_o      <= tx_line_s;
            txready_o <= txready_s;
        END IF;
    END PROCESS;

END ARCHITECTURE ya_uart_tx_a;