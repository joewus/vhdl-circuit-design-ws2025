LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE Project_Constants_Pkg IS
    -- System Configuration
    CONSTANT SYSTEM_FREQ_C       : integer := 125_000_000;
    CONSTANT MS_PER_SEC_C        : integer := 1000;
    
    -- Logic Constants
    CONSTANT BIT_HIGH_C          : std_logic := '1';
    CONSTANT BIT_LOW_C           : std_logic := '0';
    CONSTANT INT_ONE_C           : integer := 1;
    CONSTANT INT_ZERO_C          : integer := 0;
    
    -- Bus Widths
    CONSTANT DEBOUNCE_WIDTH_C    : integer := 8;
    CONSTANT LIMIT_WIDTH_C       : integer := 16;
    CONSTANT REG_WIDTH_C         : integer := 8;
    
    -- BCD Specifics
    CONSTANT BCD_DIGIT_WIDTH_C   : integer := 4;
    CONSTANT BCD_LIMIT_C         : unsigned(3 DOWNTO 0) := "1001"; -- 9
    CONSTANT NUM_BCD_DIGITS_C    : integer := 4;
    
    -- UART Configuration (9600 Baud)
    CONSTANT UART_BAUD_RATE_C    : integer := 9600;
    CONSTANT UART_DATA_WIDTH_C   : integer := 8;
    
    -- VGA Configuration (640x480 @ 60Hz)
    -- Horizontal Timing
    CONSTANT H_VISIBLE_AREA_C    : integer := 640;
    CONSTANT H_FRONT_PORCH_C     : integer := 16;
    CONSTANT H_SYNC_PULSE_C      : integer := 96;
    CONSTANT H_BACK_PORCH_C      : integer := 48;
    CONSTANT H_TOTAL_C           : integer := 800;
    
    -- Vertical Timing
    CONSTANT V_VISIBLE_AREA_C    : integer := 480;
    CONSTANT V_FRONT_PORCH_C     : integer := 10;
    CONSTANT V_SYNC_PULSE_C      : integer := 2;
    CONSTANT V_BACK_PORCH_C      : integer := 33;
    CONSTANT V_TOTAL_C           : integer := 525;
    
    -- Colors (4 bits per channel)
    CONSTANT RGB_WIDTH_C         : integer := 4;

END PACKAGE Project_Constants_Pkg;