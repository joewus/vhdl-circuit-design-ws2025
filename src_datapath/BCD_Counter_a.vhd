LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.Project_Constants_Pkg.ALL;

ARCHITECTURE BCD_Counter_a OF BCD_Counter_e IS
    
    COMPONENT asBCD1_e IS
        PORT ( 
            clk_i   : IN  std_logic;
            rst_n_i : IN  std_logic;
            cin_i   : IN  std_logic;
            cout_o  : OUT std_logic;
            count_o : OUT std_logic_vector(BCD_DIGIT_WIDTH_C - INT_ONE_C DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL carry_s : std_logic_vector(NUM_BCD_DIGITS_C DOWNTO 0);
    SIGNAL bcd_s   : std_logic_vector(LIMIT_WIDTH_C - INT_ONE_C DOWNTO 0);
    SIGNAL limit_reached_s : std_logic;

BEGIN
    -- Carry 0 Logic: Tick AND Enable AND Not_Limit
    carry_s(0) <= tick_1ms_i AND en_i AND (NOT limit_reached_s);

    gen_digits: FOR k IN 0 TO NUM_BCD_DIGITS_C - INT_ONE_C GENERATE
        digit_inst : asBCD1_e
        PORT MAP (
            clk_i   => clk_i,
            rst_n_i => rst_n_i,
            cin_i   => carry_s(k),
            cout_o  => carry_s(k + INT_ONE_C),
            count_o => bcd_s(((k + INT_ONE_C) * BCD_DIGIT_WIDTH_C) - INT_ONE_C DOWNTO (k * BCD_DIGIT_WIDTH_C))
        );
    END GENERATE;

    limit_reached_s <= BIT_HIGH_C WHEN (unsigned(bcd_s) >= unsigned(limit_cfg_i)) ELSE '0';
    
    bcd_count_o <= bcd_s;

END BCD_Counter_a;