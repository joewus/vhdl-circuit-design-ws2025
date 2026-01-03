-- image_top_a.vhd
-------------------------------------------------------------------------------
-- Architecture: behavioral
-- Author: Owusu Joseph Kwabena
-- Date:   November 2025
--
-- Description:
--   Image Top module for VGA waveform display.
--
--   Responsibilities of this block:
--     - Receive continuous 8-bit sine samples from Sine Generator
--     - Detect a trigger event (amplitude crossing a threshold)
--     - During vertical blank, COLLECT_ST exactly NUM_SAMPLES samples into a buffer
--     - During the visible area, draw the stored waveform on a grey background
--
--   FSM (3-block Moore machine, as required by professor):
--     WAIT_TRIGGER_ST  -> wait in vertical blank for a valid trigger crossing
--     COLLECT_ST       -> collect exactly NUM_SAMPLES samples
--     BLOCK_DRAW_ST    -> hold the collected buffer; drawing is done purely
--                         combinational while FSM stays in this state
--
--   Notes:
--     - No latches: all registers are clocked, all branches have explicit ELSE.
--     - Vertical blank region is detected using line_count_i range.
--     - Drawing logic is combinational, based on (x_i, line_int_s) and sample_buf_s.
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.image_top_pkg.ALL;

ARCHITECTURE image_top_a OF image_top_e IS  -- [GUIDE-FIX] architecture name ends with _a

    ---------------------------------------------------------------------------
    -- Types and Signals
    ---------------------------------------------------------------------------

    -- FSM states
    TYPE state_type_t IS (WAIT_TRIGGER_ST, COLLECT_ST, BLOCK_DRAW_ST);
    SIGNAL state_s, next_state_s : state_type_t;

    -- Sample buffer: 32 x 8-bit values (type defined in package)
    SIGNAL sample_buf_s : sample_array_t;

    -- Index for storage (0..NUM_SAMPLES)
    SIGNAL sample_index_s : integer RANGE 0 TO num_samples_c;  -- [GUIDE-FIX] NUM_SAMPLES -> num_samples_c

    -- Line count as integer for easier comparisons
    SIGNAL line_int_s     : integer RANGE 0 TO 1023;

    -- Vertical blanking flag derived from line_count
    SIGNAL vertical_blank_s : std_logic;

BEGIN

    ---------------------------------------------------------------------------
    -- Line Count Conversion and Vertical Blank Detection
    -- Converts the std_logic_vector line_count_i to an integer, then checks
    -- whether we are in the vertical blanking region using VBLANK_* constants.
    ---------------------------------------------------------------------------
    PROCESS(line_count_i)
    BEGIN
        line_int_s <= to_integer(unsigned(line_count_i));  -- 0..1023
        IF (line_int_s >= vblank_start_c) AND (line_int_s <= vblank_end_c) THEN -- [GUIDE-FIX] VBLANK_* -> vblank_*_c
            vertical_blank_s <= '1';
        ELSE
            vertical_blank_s <= '0';
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------------
    -- 1) STATE REGISTER (Sequential)
    -- Classic Moore FSM: state updated on clock edge, reset to WAIT_TRIGGER_ST.
    ---------------------------------------------------------------------------
    PROCESS(clk_i, rst_n_i)
    BEGIN
        IF rst_n_i = '0' THEN
            state_s <= WAIT_TRIGGER_ST;
        ELSIF rising_edge(clk_i) THEN
            state_s <= next_state_s;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------------
    -- 2) NEXT STATE LOGIC (Combinational)
    -- WAIT_TRIGGER_ST: wait in vertical blank for a valid trigger condition.
    -- COLLECT_ST:      collect exactly NUM_SAMPLES values (still in vertical blank).
    -- BLOCK_DRAW_ST:   drawing uses buffered samples during visible region.
    ---------------------------------------------------------------------------
    PROCESS(state_s, sine_value_i, vertical_blank_s, sample_index_s, line_int_s)
    BEGIN
        CASE state_s IS

            -------------------------------------------------------------------
            WHEN WAIT_TRIGGER_ST =>
                -- Trigger condition:
                --   - We must be in vertical blank
                --   - Amplitude crosses trigger level
                IF (vertical_blank_s = '1' AND
                    unsigned(sine_value_i) > trigger_level_c) THEN 
                    next_state_s <= COLLECT_ST;
                ELSE
                    next_state_s <= WAIT_TRIGGER_ST;
                END IF;

            -------------------------------------------------------------------
            WHEN COLLECT_ST =>
                -- Stay in COLLECT_ST until we have NUM_SAMPLES samples
                IF sample_index_s = num_samples_c THEN 
                    next_state_s <= BLOCK_DRAW_ST;
                ELSE
                    next_state_s <= COLLECT_ST;
                END IF;

            -------------------------------------------------------------------
            WHEN BLOCK_DRAW_ST =>
                -- Stay in BLOCK_DRAW_ST for the rest of the frame.
                -- Go back to WAIT_TRIGGER_ST only at the start of the next blank.
                IF line_int_s = vblank_start_c THEN 
                    next_state_s <= WAIT_TRIGGER_ST;
                ELSE
                    next_state_s <= BLOCK_DRAW_ST;
                END IF;

            -------------------------------------------------------------------
            WHEN OTHERS =>
                next_state_s <= WAIT_TRIGGER_ST;

        END CASE;
    END PROCESS;

    ---------------------------------------------------------------------------
    -- 3) SAMPLE COLLECTION (Sequential)
    -- Only active in COLLECT_ST state.
    -- - sample_index_s counts how many samples we have already stored.
    -- - In WAIT_TRIGGER_ST, index is reset to 0.
    ---------------------------------------------------------------------------
    PROCESS(clk_i, rst_n_i)
    BEGIN
        IF rst_n_i = '0' THEN
            sample_index_s <= 0;
            sample_buf_s   <= (OTHERS => (OTHERS => '0'));

        ELSIF rising_edge(clk_i) THEN
            IF state_s = COLLECT_ST THEN
                IF sample_index_s < num_samples_c THEN 
                    sample_buf_s(sample_index_s) <= sine_value_i;
                    sample_index_s <= sample_index_s + 1;
                ELSE
                    -- explicit else: keep index (no latch)
                    sample_index_s <= sample_index_s;
                END IF;

            ELSIF state_s = WAIT_TRIGGER_ST THEN
                -- In WAIT_TRIGGER_ST we rearm the system: reset sample_index_s
                sample_index_s <= 0;

            ELSE
                -- BLOCK_DRAW_ST: keep the collected values and index as is
                sample_index_s <= sample_index_s;
            END IF;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------------
    -- 4) DRAWING LOGIC (Combinational)
    --
    -- Moore-style: the FSM only decides WHEN drawing is allowed (BLOCK_DRAW_ST).
    --
    -- Drawing order:
    --   1) Default grey background
    --   2) If video_active_i = '1':
    --        - Draw coordinate axes (horizontal + vertical)
    --        - If state_s = BLOCK_DRAW_ST:
    --             overlay the waveform on top of axes
    --
    -- Horizontal axis:
    --   y = WAVE_BASELINE_Y   (center line, X-axis)
    --
    -- Vertical axis:
    --   x = AXIS_X_POSITION   (middle of screen, Y-axis)
    ---------------------------------------------------------------------------
    draw_logic : PROCESS(state_s, video_active_i, x_i, line_int_s, sample_buf_s)
        VARIABLE x_int_v   : integer;
        VARIABLE y_int_v   : integer;
        VARIABLE idx_v     : integer;
        VARIABLE amp_int_v : integer;
        VARIABLE wave_y_v  : integer;
        VARIABLE r_tmp_v   : red_t;   
        VARIABLE g_tmp_v   : green_t; 
        VARIABLE b_tmp_v   : blue_t;  
    BEGIN
        -----------------------------------------------------------------------
        -- 0) Default: grey background everywhere
        -----------------------------------------------------------------------
        r_tmp_v := bg_level_r_c; 
        g_tmp_v := bg_level_g_c; 
        b_tmp_v := bg_level_b_c; 

        -- Only care about drawing when we are in the visible area
        IF video_active_i = '1' THEN

            -- Convert coordinates to integers
            x_int_v := to_integer(unsigned(x_i)); -- 0..639
            y_int_v := line_int_s;               -- 0..479 in visible area

            -------------------------------------------------------------------
            -- 1) Draw coordinate axes (independent of FSM state)
            --    - Horizontal axis: y = WAVE_BASELINE_Y
            --    - Vertical axis:   x = AXIS_X_POSITION
            -------------------------------------------------------------------
            IF y_int_v = wave_baseline_y_c THEN 
                r_tmp_v := axis_level_r_c;      
                g_tmp_v := axis_level_g_c;      
                b_tmp_v := axis_level_b_c;      
            END IF;

            IF x_int_v = axis_x_pos_c THEN       
                r_tmp_v := axis_level_r_c;
                g_tmp_v := axis_level_g_c;
                b_tmp_v := axis_level_b_c;
            END IF;

            -------------------------------------------------------------------
            -- 2) Draw waveform ON TOP of axes (only in BLOCK_DRAW_ST)
            -------------------------------------------------------------------
            IF state_s = BLOCK_DRAW_ST THEN
                -- Map x position to buffer index (0..NUM_SAMPLES-1)
                idx_v := x_int_v / sample_stride_x_c; 

                IF (idx_v >= 0) AND (idx_v < num_samples_c) THEN 
                    -- Convert sample amplitude to integer (0..255)
                    amp_int_v := to_integer(unsigned(sample_buf_s(idx_v)));

                    -- Simple vertical scaling:
                    --   - amp_int_v / 8 -> 0..31
                    --   - waveform centered at WAVE_BASELINE_Y
                    wave_y_v := wave_baseline_y_c - (amp_int_v / 8); 

                    -- If current y is close to wave_y_v, draw the waveform (overwrites axis if overlapping)
                    IF (y_int_v >= wave_y_v - wave_thickness_c) AND  
                       (y_int_v <= wave_y_v + wave_thickness_c) THEN
                        r_tmp_v := wave_level_r_c; 
                        g_tmp_v := wave_level_g_c; 
                        b_tmp_v := wave_level_b_c; 
                    END IF;
                END IF;
            END IF; -- state_s = BLOCK_DRAW_ST

        END IF; -- video_active_i = '1'

        -----------------------------------------------------------------------
        -- Assign to outputs
        -----------------------------------------------------------------------
        r_o <= r_tmp_v;
        g_o <= g_tmp_v;
        b_o <= b_tmp_v;
    END PROCESS draw_logic;

END ARCHITECTURE image_top_a;
