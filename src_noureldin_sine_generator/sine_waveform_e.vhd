library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.sine_pkg.ALL;

entity sine_waveform_e is
    port (
        addr_i       : in  std_logic_vector(ADDR_MAX_BIT_C downto 0);
        -- Replaced "63 downto 0" with constant
        reg_values_i : in  std_logic_vector(REG_BUS_MAX_BIT_C downto 0);
        data_o       : out std_logic_vector(DATA_MAX_BIT_C downto 0)
    );
end entity sine_waveform_e;