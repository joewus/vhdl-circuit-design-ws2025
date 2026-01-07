LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.Project_Constants_Pkg.ALL;

ENTITY VGA_Controller_e IS
    PORT (
        clk_i       : IN  std_logic;
        rst_n_i     : IN  std_logic;
        -- Data to display (Measurement Result)
        bcd_data_i  : IN  std_logic_vector(LIMIT_WIDTH_C - INT_ONE_C DOWNTO 0);
        
        -- VGA Physical Outputs
        hsync_o     : OUT std_logic;
        vsync_o     : OUT std_logic;
        red_o       : OUT std_logic_vector(RGB_WIDTH_C - 1 DOWNTO 0);
        green_o     : OUT std_logic_vector(RGB_WIDTH_C - 1 DOWNTO 0);
        blue_o      : OUT std_logic_vector(RGB_WIDTH_C - 1 DOWNTO 0)
    );
END VGA_Controller_e;