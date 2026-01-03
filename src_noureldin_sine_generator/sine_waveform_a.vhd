library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.sine_pkg.ALL;

architecture sine_waveform_a of sine_waveform_e is
    
    -- Use constant for array size (0 to 7)
    type reg_array_t is array (0 to REG_INDEX_LAST_C) of std_logic_vector(DATA_MAX_BIT_C downto 0);
    signal regs_s      : reg_array_t;
    
    signal quarter_s   : unsigned(1 downto 0);
    signal index_s     : unsigned(INDEX_MAX_BIT_C downto 0); -- 3 bits
    signal amplitude_s : signed(DATA_MAX_BIT_C downto 0);

begin

    -- Unpack the vector using constants
    process(reg_values_i)
    begin
        for i in 0 to REG_INDEX_LAST_C loop
            -- Logic: Slice 8 bits at a time using DATA_WIDTH_C (8)
            regs_s(i) <= reg_values_i((i+1)*DATA_WIDTH_C - 1 downto i*DATA_WIDTH_C);
        end loop;
    end process;

    -- Slice Address:
    -- Quadrant is above the index bits.
    quarter_s <= unsigned(addr_i(ADDR_MAX_BIT_C downto QUAD_LOW_BIT_C));
    -- Index is the lower bits.
    index_s   <= unsigned(addr_i(INDEX_MAX_BIT_C downto 0));

    process(quarter_s, index_s, regs_s)
    begin
        case quarter_s is
            when "00" => -- 1st Quarter
                amplitude_s <= signed(regs_s(to_integer(index_s)));
                
            when "01" => -- 2nd Quarter (Mirror)
                -- Use constant (7) instead of raw number
                amplitude_s <= signed(regs_s(REG_INDEX_LAST_C - to_integer(index_s)));
                
            when "10" => -- 3rd Quarter (Invert)
                amplitude_s <= -signed(regs_s(to_integer(index_s)));
                
            when others => -- 4th Quarter (Invert Mirror)
                amplitude_s <= -signed(regs_s(REG_INDEX_LAST_C - to_integer(index_s)));
        end case;
    end process;

    data_o <= std_logic_vector(amplitude_s);

end architecture sine_waveform_a;