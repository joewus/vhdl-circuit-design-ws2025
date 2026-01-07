LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ya_uart_pkg.ALL;

ENTITY ya_uart_rx_e IS
  PORT (
    clk_i        : IN  STD_LOGIC;                    -- 125 MHz system clock
    rst_i        : IN  STD_LOGIC;                    -- async reset active low
    baudtick_i   : IN  STD_LOGIC;                    -- full baud tick (start/end bit)
    baudhalf_i   : IN  STD_LOGIC;                    -- half baud (mid-bit sample)
    rx_i         : IN  STD_LOGIC;                    -- serial RX input (idle=1)
    ascii_o      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- received byte
    rxready_o    : OUT STD_LOGIC;                    -- data valid pulse
    baudstart_o  : OUT STD_LOGIC                     -- baud counter restart req
  );
END ENTITY ya_uart_rx_e;
