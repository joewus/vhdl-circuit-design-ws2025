LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.Project_Constants_Pkg.ALL;

ENTITY DataPathTop_e IS
    GENERIC ( 
        SYSTEM_CLOCK_FREQ_C : INTEGER := SYSTEM_FREQ_C 
    );
    PORT (
        clk_i          : IN  std_logic;
        rst_n_i        : IN  std_logic;
        debounce_cfg_i : IN  std_logic_vector(DEBOUNCE_WIDTH_C - INT_ONE_C DOWNTO 0);
        limit_cfg_i    : IN  std_logic_vector(LIMIT_WIDTH_C - INT_ONE_C DOWNTO 0);
        photo_diode1_i : IN  std_logic;
        photo_diode2_i : IN  std_logic;
        
        -- UART Output
        uart_tx_o      : OUT std_logic;
        
        -- VGA Outputs
        vga_hsync_o    : OUT std_logic;
        vga_vsync_o    : OUT std_logic;
        vga_red_o      : OUT std_logic_vector(RGB_WIDTH_C - 1 DOWNTO 0);
        vga_green_o    : OUT std_logic_vector(RGB_WIDTH_C - 1 DOWNTO 0);
        vga_blue_o     : OUT std_logic_vector(RGB_WIDTH_C - 1 DOWNTO 0)
    );
END DataPathTop_e;