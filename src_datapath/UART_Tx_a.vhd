LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.Project_Constants_Pkg.ALL;

ARCHITECTURE UART_Tx_a OF UART_Tx_e IS
    
    CONSTANT BIT_TIMER_LIMIT_C : integer := clk_freq_c / baud_rate_c;
    
    TYPE state_t IS (IDLE_ST, START_BIT_ST, DATA_BITS_ST, STOP_BIT_ST, CLEANUP_ST);
    SIGNAL state_r : state_t;
    
    SIGNAL bit_timer_r : integer range 0 to BIT_TIMER_LIMIT_C;
    SIGNAL bit_index_r : integer range 0 to 7;
    SIGNAL tx_data_r   : std_logic_vector(7 downto 0);
    
BEGIN
    PROCESS(clk_i, rst_n_i)
    BEGIN
        IF (rst_n_i = '0') THEN
            state_r     <= IDLE_ST;
            tx_serial_o <= '1'; -- Idle High
            tx_done_o   <= '0';
            tx_active_o <= '0';
            bit_timer_r <= 0;
            bit_index_r <= 0;
            tx_data_r   <= (others => '0');
        ELSIF rising_edge(clk_i) THEN
            tx_done_o <= '0'; -- Default
            
            CASE state_r IS
                WHEN IDLE_ST =>
                    tx_serial_o <= '1';
                    tx_active_o <= '0';
                    bit_timer_r <= 0;
                    bit_index_r <= 0;
                    
                    IF (tx_start_i = '1') THEN
                        tx_data_r   <= tx_data_i;
                        state_r     <= START_BIT_ST;
                        tx_active_o <= '1';
                    END IF;
                    
                WHEN START_BIT_ST =>
                    tx_serial_o <= '0'; -- Start Bit is Low
                    
                    IF (bit_timer_r = BIT_TIMER_LIMIT_C - 1) THEN
                        state_r     <= DATA_BITS_ST;
                        bit_timer_r <= 0;
                    ELSE
                        bit_timer_r <= bit_timer_r + 1;
                    END IF;
                    
                WHEN DATA_BITS_ST =>
                    tx_serial_o <= tx_data_r(bit_index_r);
                    
                    IF (bit_timer_r = BIT_TIMER_LIMIT_C - 1) THEN
                        bit_timer_r <= 0;
                        IF (bit_index_r = 7) THEN
                            bit_index_r <= 0;
                            state_r     <= STOP_BIT_ST;
                        ELSE
                            bit_index_r <= bit_index_r + 1;
                        END IF;
                    ELSE
                        bit_timer_r <= bit_timer_r + 1;
                    END IF;
                    
                WHEN STOP_BIT_ST =>
                    tx_serial_o <= '1'; -- Stop Bit is High
                    
                    IF (bit_timer_r = BIT_TIMER_LIMIT_C - 1) THEN
                        state_r     <= CLEANUP_ST;
                        bit_timer_r <= 0;
                        tx_done_o   <= '1';
                    ELSE
                        bit_timer_r <= bit_timer_r + 1;
                    END IF;
                    
                WHEN CLEANUP_ST =>
                    state_r     <= IDLE_ST;
                    tx_active_o <= '0';
                    
                WHEN OTHERS =>
                    state_r <= IDLE_ST;
            END CASE;
        END IF;
    END PROCESS;
END UART_Tx_a;