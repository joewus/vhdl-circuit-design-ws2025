-- image_top_e.vhd
-------------------------------------------------------------------------------
-- Entity: image_top
-- Author: Owusu Joseph Kwabena
-- Date:   November 2025
--
-- Description:
--   Top-level interface of the Image Top module.
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.image_top_pkg.ALL;  -- RED/GREEN/BLUE, constants

ENTITY image_top_e IS
    PORT (
        -----------------------------------------------------------------------
        -- Global
        -----------------------------------------------------------------------
        clk_i           : IN  std_logic;  -- 125 MHz FPGA clock
        rst_n_i         : IN  std_logic;  -- Active-low asynchronous reset

        -----------------------------------------------------------------------
        -- Sine Generator Interface
        -----------------------------------------------------------------------
        sine_value_i    : IN  sample_slv_t; -- 8-bit amplitude

        -----------------------------------------------------------------------
        -- VGA Timing Interface
        -----------------------------------------------------------------------
        --pixel_enable_i  : in  std_logic;  -- 25 MHz pixel enable (kept for future use)
        video_active_i  : IN  std_logic;  -- '1' in visible area, '0' in blanking
        line_count_i    : IN  line_slv_t; -- current line index (0..524)
        x_i             : IN  coord_slv_t; -- pixel X coordinate (0..639)

        -----------------------------------------------------------------------
        -- VGA RGB Outputs
        -----------------------------------------------------------------------
        r_o             : OUT red_t;
        g_o             : OUT green_t;
        b_o             : OUT blue_t
    );
END ENTITY image_top_e;
