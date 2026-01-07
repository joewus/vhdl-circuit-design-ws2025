LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.Project_Constants_Pkg.ALL;

ENTITY UART_Tx_e IS
    GENERIC (
        clk_freq_c : integer := SYSTEM_FREQ_C;
        baud_rate_c: integer := UART_BAUD_RATE_C
    );
    PORT (
        clk_i       : IN  std_logic;
        rst_n_i     : IN  std_logic;
        tx_start_i  : IN  std_logic;
        tx_data_i   : IN  std_logic_vector(UART_DATA_WIDTH_C - INT_ONE_C DOWNTO 0);
        tx_active_o : OUT std_logic;
        tx_serial_o : OUT std_logic;
        tx_done_o   : OUT std_logic
    );
END UART_Tx_e;