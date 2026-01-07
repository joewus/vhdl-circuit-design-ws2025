LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ya_uart_pkg.ALL;

ENTITY ya_baudrate_e IS
  PORT (
    clk_i       : IN  STD_LOGIC;      -- 125 MHz system clock
    rst_i       : IN  STD_LOGIC;      -- async reset active low
    baud_sel_i  : IN  STD_LOGIC;      -- 0=9600, 1=19200
    baudstart_i : IN  STD_LOGIC;      -- restart counter
    baudtick_o  : OUT STD_LOGIC;      -- full baud tick
    baudhalf_o  : OUT STD_LOGIC       -- half baud (mid-bit)
  );
END ENTITY ya_baudrate_e;
