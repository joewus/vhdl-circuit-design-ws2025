library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.sine_pkg.ALL;

entity sine_top_e is
    port (
        clk_i        : in  std_logic;
        rst_n_i      : in  std_logic;
        reg_en_i     : in  std_logic;
        
        reg_freq_i   : in  std_logic_vector(FREQ_MAX_BIT_C downto 0);
        
        reg_values_i : in  std_logic_vector(REG_BUS_MAX_BIT_C downto 0);
        
        reg_read_o   : out std_logic;
        sine_vga_o   : out std_logic_vector(DATA_MAX_BIT_C downto 0);
        sine_uart_o  : out std_logic_vector(DATA_MAX_BIT_C downto 0);
        sine_valid_o : out std_logic
    );
end entity sine_top_e;