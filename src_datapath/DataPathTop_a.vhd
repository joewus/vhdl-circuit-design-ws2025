LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.Project_Constants_Pkg.ALL;

ARCHITECTURE DataPathTop_a OF DataPathTop_e IS

    -- Signals
    SIGNAL tick_1ms_s     : std_logic;
    SIGNAL start_pulse_s  : std_logic;
    SIGNAL stop_pulse_s   : std_logic;
    
    -- Control Logic (Replacing FSM)
    SIGNAL count_enable_s : std_logic;
    SIGNAL measurement_done_s : std_logic;
    
    SIGNAL bcd_val_s      : std_logic_vector(LIMIT_WIDTH_C - INT_ONE_C DOWNTO 0);

    -- Components
    COMPONENT Pulse_Generator_e IS
        GENERIC ( clk_freq_c : INTEGER );
        PORT ( clk_i, rst_n_i : IN std_logic; tick_o : OUT std_logic );
    END COMPONENT;

    COMPONENT Debouncer_e IS
        PORT (
            clk_i, rst_n_i, data_i : IN std_logic;
            debounce_cfg_i : IN std_logic_vector(DEBOUNCE_WIDTH_C - INT_ONE_C DOWNTO 0);
            tick_1ms_i : IN std_logic;
            pulse_o : OUT std_logic
        );
    END COMPONENT;

    COMPONENT BCD_Counter_e IS
        PORT (
            clk_i, rst_n_i, en_i, tick_1ms_i : IN std_logic;
            limit_cfg_i : IN std_logic_vector(LIMIT_WIDTH_C - INT_ONE_C DOWNTO 0);
            bcd_count_o : OUT std_logic_vector(LIMIT_WIDTH_C - INT_ONE_C DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT UART_Tx_e IS
        PORT ( clk_i, rst_n_i, tx_start_i : IN std_logic; tx_data_i : IN std_logic_vector(7 downto 0); tx_serial_o : OUT std_logic; tx_done_o : OUT std_logic; tx_active_o : OUT std_logic );
    END COMPONENT;
    
    COMPONENT VGA_Controller_e IS
        PORT ( clk_i, rst_n_i : IN std_logic; bcd_data_i : IN std_logic_vector(LIMIT_WIDTH_C - INT_ONE_C DOWNTO 0); hsync_o, vsync_o : OUT std_logic; red_o, green_o, blue_o : OUT std_logic_vector(RGB_WIDTH_C - 1 DOWNTO 0) );
    END COMPONENT;

BEGIN

    -- 1. Pulse Generator
    inst_pulse_gen: Pulse_Generator_e
    GENERIC MAP ( clk_freq_c => SYSTEM_CLOCK_FREQ_C )
    PORT MAP ( clk_i => clk_i, rst_n_i => rst_n_i, tick_o => tick_1ms_s );

    -- 2. Debouncers
    inst_deb_start: Debouncer_e
    PORT MAP ( clk_i => clk_i, rst_n_i => rst_n_i, data_i => photo_diode1_i, debounce_cfg_i => debounce_cfg_i, tick_1ms_i => tick_1ms_s, pulse_o => start_pulse_s );

    inst_deb_stop: Debouncer_e
    PORT MAP ( clk_i => clk_i, rst_n_i => rst_n_i, data_i => photo_diode2_i, debounce_cfg_i => debounce_cfg_i, tick_1ms_i => tick_1ms_s, pulse_o => stop_pulse_s );

    -- 3. Simple Control Logic (Replaces Complex FSM)
    PROCESS(clk_i, rst_n_i)
    BEGIN
        IF (rst_n_i = '0') THEN
            count_enable_s <= '0';
            measurement_done_s <= '0';
        ELSIF rising_edge(clk_i) THEN
            IF (start_pulse_s = '1') THEN
                count_enable_s <= '1';
                measurement_done_s <= '0';
            ELSIF (stop_pulse_s = '1') THEN
                count_enable_s <= '0';
                measurement_done_s <= '1';
            END IF;
        END IF;
    END PROCESS;

    -- 4. BCD Counter
    inst_counter: BCD_Counter_e
    PORT MAP ( clk_i => clk_i, rst_n_i => rst_n_i, en_i => count_enable_s, tick_1ms_i => tick_1ms_s, limit_cfg_i => limit_cfg_i, bcd_count_o => bcd_val_s );

    -- 5. UART (Transmits lower 8 bits of result when done)
    inst_uart: UART_Tx_e
    PORT MAP (
        clk_i => clk_i, rst_n_i => rst_n_i,
        tx_start_i => measurement_done_s, -- Transmit when stop button pressed
        tx_data_i => bcd_val_s(7 downto 0),
        tx_serial_o => uart_tx_o,
        tx_done_o => OPEN, tx_active_o => OPEN
    );

    -- 6. VGA Controller
    inst_vga: VGA_Controller_e
    PORT MAP (
        clk_i => clk_i, rst_n_i => rst_n_i,
        bcd_data_i => bcd_val_s,
        hsync_o => vga_hsync_o, vsync_o => vga_vsync_o,
        red_o => vga_red_o, green_o => vga_green_o, blue_o => vga_blue_o
    );

END DataPathTop_a;