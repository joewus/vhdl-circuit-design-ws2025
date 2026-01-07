LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.ya_uart_pkg.ALL;

ENTITY ya_uart_tx_e IS
  PORT (
    clk_i       : IN  STD_LOGIC;                    -- system clock
    rst_i       : IN  STD_LOGIC;                    -- async reset, active low
    baudtick_i  : IN  STD_LOGIC;                    -- one pulse per bit period
    txdata_i    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); -- data byte to send
    txvalid_i   : IN  STD_LOGIC;                    -- strobe to start transmission
    tx_o        : OUT STD_LOGIC;                    -- serial TX line
    txready_o   : OUT STD_LOGIC                     -- high when idle/ready
  );
END ENTITY ya_uart_tx_e;
