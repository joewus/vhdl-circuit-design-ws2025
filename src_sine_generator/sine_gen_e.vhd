library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.sine_pkg.ALL;

entity sine_gen_e is
    port (
        clk_i       : in  std_logic;
        rst_n_i     : in  std_logic;
        en_i        : in  std_logic;
        freq_ctrl_i : in  std_logic_vector(FREQ_MAX_BIT_C downto 0);
        addr_o      : out std_logic_vector(ADDR_MAX_BIT_C downto 0)
    );
end entity sine_gen_e;