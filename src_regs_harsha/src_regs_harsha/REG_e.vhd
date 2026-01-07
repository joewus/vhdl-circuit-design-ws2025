PACKAGE state_pkg IS 
TYPE state_type_t IS (rst_st, wr_addr_st, wait_data_st, wr_data_st, wr_r_st);
END PACKAGE state_pkg;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.state_pkg.ALL;


ENTITY REG_e IS
    PORT (
        clk_i      : IN  STD_LOGIC;
        rst_n_i    : IN  STD_LOGIC;
        rx_ready_i : IN  STD_LOGIC;
        ascii_rx_i : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg01_o    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg02_o    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg03_o    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg04_o    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg05_o    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg06_o    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg07_o    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg08_o    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg09_o    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        state_o    : OUT state_type_t
    );
END ENTITY REG_e;