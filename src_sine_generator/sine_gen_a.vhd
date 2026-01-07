library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.sine_pkg.ALL;

architecture sine_gen_a of sine_gen_e is
    signal phase_acc_s : unsigned(FREQ_MAX_BIT_C downto 0);
begin

    process(clk_i, rst_n_i)
    begin
        if rst_n_i = '0' then
            phase_acc_s <= (others => '0');
        elsif rising_edge(clk_i) then
            if en_i = '1' then
                phase_acc_s <= phase_acc_s + unsigned(freq_ctrl_i);
            end if;
        end if;
    end process;

    addr_o <= std_logic_vector(phase_acc_s(FREQ_MAX_BIT_C downto (FREQ_MAX_BIT_C - ADDR_MAX_BIT_C)));

end architecture sine_gen_a;