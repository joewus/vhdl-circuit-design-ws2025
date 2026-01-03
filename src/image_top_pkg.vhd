-------------------------------------------------------------------------------
-- Package: image_top_pkg
-- Author: Owusu Joseph Kwabena
-- Date:   November 2025
--
-- Description:
--   Common constants and types for the Image Top module and its testbench.
--   Putting them here avoids magic numbers in the RTL and keeps the
--   specification consistent across all files.
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

PACKAGE image_top_pkg IS

    ---------------------------------------------------------------------------
    -- General design parameters
    ---------------------------------------------------------------------------
    -- Number of samples to collect from the sine generator per frame
    CONSTANT num_samples_c        : natural := 32; -- cannot be negative

    -- Trigger threshold (mid-scale): start sampling when amplitude crosses this
    CONSTANT trigger_mid_c        : natural := 128;

    ---------------------------------------------------------------------------
    -- VGA timing / geometry assumptions for 640x480@60Hz
    ---------------------------------------------------------------------------
    -- Visible lines:    0 .. 479
    -- Vertical blank:   480 .. 524
    CONSTANT vblank_start_c       : natural := 480; -- start of vertical blank
    CONSTANT vblank_end_c         : natural := 524; -- visible + 45 vertical blank

    -- X-scaling: 640 pixels / 32 samples = 20 pixels per sample
    CONSTANT sample_stride_x_c    : natural := 20;

    -- Y-baseline for waveform (center of screen)
    CONSTANT wave_baseline_y_c    : natural := 240;

    -- How "thick" the waveform appears (vertical tolerance in pixels)
    CONSTANT wave_thickness_c     : natural := 2;

    ---------------------------------------------------------------------------
    -- Axis configuration
    ---------------------------------------------------------------------------
    -- Vertical axis X-position (middle of screen: x = 320)
    CONSTANT axis_x_pos_c         : natural := 320;

    ---------------------------------------------------------------------------
    -- Color types (VGA 5-6-5 style)
    ---------------------------------------------------------------------------
    CONSTANT red_w_c              : natural := 6;
    CONSTANT green_w_c            : natural := 7;
    CONSTANT blue_w_c             : natural := 6;

    SUBTYPE red_t   IS std_logic_vector(red_w_c-1   DOWNTO 0); -- 6 bits
    SUBTYPE green_t IS std_logic_vector(green_w_c-1 DOWNTO 0); -- 7 bits
    SUBTYPE blue_t  IS std_logic_vector(blue_w_c-1  DOWNTO 0); -- 6 bits

    ---------------------------------------------------------------------------
    -- Color definitions
    ---------------------------------------------------------------------------
    -- Background grey
    CONSTANT bg_level_r_c         : red_t   := "010000";  --mid greey
    CONSTANT bg_level_g_c         : green_t := "1000000"; --a bit brighter
    CONSTANT bg_level_b_c         : blue_t  := "010000";

    -- Axis (white-ish)
    CONSTANT axis_level_r_c       : red_t   := (OTHERS => '1');
    CONSTANT axis_level_g_c       : green_t := (OTHERS => '1');
    CONSTANT axis_level_b_c       : blue_t  := (OTHERS => '1');

    -- Waveform (also bright)
    CONSTANT wave_level_r_c       : red_t   := (OTHERS => '1');
    CONSTANT wave_level_g_c       : green_t := (OTHERS => '1');
    CONSTANT wave_level_b_c       : blue_t  := (OTHERS => '1');

    ---------------------------------------------------------------------------
    -- Width constants (avoid numbers in RTL)
    ---------------------------------------------------------------------------
    CONSTANT sample_w_c           : natural := 8;
    CONSTANT coord_w_c            : natural := 10;  -- x coordinate width for 0..639
    CONSTANT line_w_c             : natural := 10;  -- line count width for 0..524

    ---------------------------------------------------------------------------
    -- Common subtypes (type names end with _t)
    ---------------------------------------------------------------------------
    SUBTYPE sample_slv_t IS std_logic_vector(sample_w_c-1 DOWNTO 0);
    SUBTYPE coord_slv_t  IS std_logic_vector(coord_w_c-1  DOWNTO 0);
    SUBTYPE line_slv_t   IS std_logic_vector(line_w_c-1   DOWNTO 0);

    SUBTYPE sample_u_t   IS unsigned(sample_w_c-1 DOWNTO 0);

    -- Trigger threshold (mid-scale): start sampling when amplitude crosses this
    CONSTANT trigger_level_c      : sample_u_t := to_unsigned(trigger_mid_c, sample_w_c);

    ---------------------------------------------------------------------------
    -- Shared types
    ---------------------------------------------------------------------------
    -- Sample buffer: 32 x 8-bit values
    TYPE sample_array_t IS ARRAY (0 TO num_samples_c-1) OF sample_slv_t;

END PACKAGE image_top_pkg;
