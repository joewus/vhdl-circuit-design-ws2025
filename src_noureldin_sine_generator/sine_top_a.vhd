library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.sine_pkg.ALL;

architecture sine_top_a of sine_top_e is

    signal addr_s : std_logic_vector(ADDR_MAX_BIT_C downto 0);
    signal sine_s : std_logic_vector(DATA_MAX_BIT_C downto 0);

    component sine_gen_e is
        port (
            clk_i       : in  std_logic;
            rst_n_i     : in  std_logic;
            en_i        : in  std_logic;
            freq_ctrl_i : in  std_logic_vector(FREQ_MAX_BIT_C downto 0);
            addr_o      : out std_logic_vector(ADDR_MAX_BIT_C downto 0)
        );
    end component;

    component sine_waveform_e is
        port (
            addr_i       : in  std_logic_vector(ADDR_MAX_BIT_C downto 0);
            reg_values_i : in  std_logic_vector(REG_BUS_MAX_BIT_C downto 0);
            data_o       : out std_logic_vector(DATA_MAX_BIT_C downto 0)
        );
    end component;

begin

    u_gen : sine_gen_e
        port map (
            clk_i       => clk_i,
            rst_n_i     => rst_n_i,
            en_i        => reg_en_i,
            freq_ctrl_i => reg_freq_i,
            addr_o      => addr_s
        );

    u_waveform : sine_waveform_e
        port map (
            addr_i       => addr_s,
            reg_values_i => reg_values_i,
            data_o       => sine_s
        );

    sine_vga_o   <= sine_s;
    sine_uart_o  <= sine_s;
    sine_valid_o <= reg_en_i;
    reg_read_o   <= reg_en_i;

end architecture sine_top_a;