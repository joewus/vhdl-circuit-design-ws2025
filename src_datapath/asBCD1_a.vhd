LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.Project_Constants_Pkg.ALL;

ARCHITECTURE asBCD1_a OF asBCD1_e IS
    SIGNAL count_r : unsigned(BCD_DIGIT_WIDTH_C - INT_ONE_C DOWNTO 0);
BEGIN
    PROCESS(clk_i, rst_n_i)
    BEGIN
        IF (rst_n_i = '0') THEN
            count_r <= to_unsigned(0, BCD_DIGIT_WIDTH_C);
            cout_o  <= '0';
        ELSIF rising_edge(clk_i) THEN
            cout_o <= '0'; 
            IF (cin_i = BIT_HIGH_C) THEN
                IF (count_r = BCD_LIMIT_C) THEN
                    count_r <= to_unsigned(0, BCD_DIGIT_WIDTH_C);
                    cout_o  <= BIT_HIGH_C;
                ELSE
                    count_r <= count_r + INT_ONE_C;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    count_o <= std_logic_vector(count_r);
END asBCD1_a;