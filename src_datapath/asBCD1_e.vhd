LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.Project_Constants_Pkg.ALL;

ENTITY asBCD1_e IS
    PORT ( 
        clk_i   : IN  std_logic;
        rst_n_i : IN  std_logic;
        cin_i   : IN  std_logic;
        cout_o  : OUT std_logic;
        count_o : OUT std_logic_vector(BCD_DIGIT_WIDTH_C - INT_ONE_C DOWNTO 0)
    );
END asBCD1_e;