-- image_top_tb.vhd
--###############################################################
-- Testbench for image_top
--###############################################################
LIBRARY ieee;                                   
USE ieee.std_logic_1164.ALL;                    
USE ieee.numeric_std.ALL;                       
USE ieee.math_real.ALL;              -- for real sin()

USE work.image_top_pkg.ALL;          -- NUM_SAMPLES, TRIGGER_LEVEL, RGB subtypes, etc.

ENTITY image_top_tb IS                          
END ENTITY;

ARCHITECTURE tb OF image_top_tb IS              

    ----------------------------------------------------------------
    -- Clock period: 125 MHz  →  8 ns
    ----------------------------------------------------------------
    CONSTANT CLK_PERIOD       : time    := 8 ns;
    CONSTANT SCREEN_WIDTH_C   : integer := 640;
    CONSTANT SCREEN_LINES_C   : integer := 525;   -- 480 visible + 45 vblank
    CONSTANT VISIBLE_HEIGHT_C : integer := 480;

    ----------------------------------------------------------------
    -- Signals connected to the DUT (Device Under Test)
    ----------------------------------------------------------------
    SIGNAL clk_i          : std_logic := '0';          
    SIGNAL rst_n_i        : std_logic := '0';         

    SIGNAL sine_value_i   : sample_slv_t := (OTHERS => '0');   

   -- SIGNAL pixel_enable_i : std_logic := '0';
    SIGNAL video_active_i : std_logic := '0';
    SIGNAL line_count_i   : line_slv_t := (OTHERS => '0');     
    SIGNAL x_i            : coord_slv_t := (OTHERS => '0');    

    SIGNAL r_o            : red_t;     
    SIGNAL g_o            : green_t;   
    SIGNAL b_o            : blue_t;    

BEGIN

    ----------------------------------------------------------------
    -- DUT instance
    ----------------------------------------------------------------
    dut_inst : ENTITY work.image_top_e            
        PORT MAP (
            clk_i           => clk_i,
            rst_n_i         => rst_n_i,
            sine_value_i    => sine_value_i,
           -- pixel_enable_i  => pixel_enable_i,
            video_active_i  => video_active_i,
            line_count_i    => line_count_i,
            x_i             => x_i,
            r_o             => r_o,
            g_o             => g_o,
            b_o             => b_o
        );

    ----------------------------------------------------------------
    -- Clock generator 125 MHz
    ----------------------------------------------------------------
    clk_proc : PROCESS
    BEGIN
        WHILE true LOOP
            clk_i <= '0';
            WAIT FOR CLK_PERIOD / 2;
            clk_i <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
    END PROCESS;

    ----------------------------------------------------------------
    -- Reset generator
    ----------------------------------------------------------------
    rst_proc : PROCESS
    BEGIN
        rst_n_i <= '0';
        WAIT FOR 200 ns;              -- hold reset for some time
        rst_n_i <= '1';
        WAIT;
    END PROCESS;

    ----------------------------------------------------------------
    -- Simple VGA timing model
    --
    --  - x:               0 .. 639
    --  - line_count (y):  0 .. 524
    --  - video_active = 1 only for y < 480 (visible area)
    --
    -- 1 clock tick == 1 pixel (hugely simplified, but OK for TB).
    ----------------------------------------------------------------
    vga_model_proc : PROCESS(clk_i, rst_n_i)
        VARIABLE x_int_v : integer := 0;
        VARIABLE y_int_v : integer := 0;
    BEGIN
        IF rst_n_i = '0' THEN
            x_int_v := 0;
            y_int_v := 0;
            x_i <= (OTHERS => '0');
            line_count_i <= (OTHERS => '0');
            video_active_i <= '0';
           -- pixel_enable_i <= '0';

        ELSIF rising_edge(clk_i) THEN
            -- increment pixel (x) every clock
            x_int_v := x_int_v + 1;
            IF x_int_v = SCREEN_WIDTH_C THEN
                x_int_v := 0;
                -- end of line → next line
                y_int_v := y_int_v + 1;
                IF y_int_v = SCREEN_LINES_C THEN
                    y_int_v := 0;
                END IF;
            END IF;

            -- drive DUT inputs
            x_i <= std_logic_vector(to_unsigned(x_int_v, x_i'LENGTH));
            line_count_i <= std_logic_vector(to_unsigned(y_int_v, line_count_i'LENGTH));

            -- visible region: top 480 lines → video_active_i = '1'
            IF (y_int_v >= 0) AND (y_int_v < VISIBLE_HEIGHT_C) THEN
                video_active_i <= '1';
            ELSE
                video_active_i <= '0';  -- vertical blank
            END IF;

            -- simple pixel enable: '1' in visible area, '0' in blank
            --if video_active_i = '1' then
               -- pixel_enable_i <= '1';
           -- else
               -- pixel_enable_i <= '0';
           -- end if;
        END IF;
    END PROCESS;

    ----------------------------------------------------------------
    -- Sine generator model
    --
    --  - Generates a "nice" analog-looking sine wave:
    --      sine_value_i(t) ≈ 128 + 127 * sin(phase)
    --    mapped to 0..255 (8-bit unsigned)
    --
    --  - Uses ieee.math_real.sin, only for simulation.
    --  - Frequency is arbitrary; we just want a clean periodic shape.
    ----------------------------------------------------------------
    sine_model_proc : PROCESS(clk_i, rst_n_i)
        CONSTANT TWO_PI              : real := 2.0 * 3.14159265358979323846;
        CONSTANT SAMPLES_PER_PERIOD  : integer := 128;  -- sine resolution
        CONSTANT PHASE_STEP          : real := TWO_PI / real(SAMPLES_PER_PERIOD);
        VARIABLE phase_v             : real := 0.0;
        VARIABLE s_real_v            : real;
        VARIABLE s_scaled_v          : integer;
    BEGIN
        IF rst_n_i = '0' THEN
            phase_v      := 0.0;
            sine_value_i <= (OTHERS => '0');

        ELSIF rising_edge(clk_i) THEN
            -- ideal sine in range [-1.0, +1.0]
            s_real_v := sin(phase_v);

            -- scale to unsigned 0..255
            --   -1.0  →   0
            --   +1.0  → 255
            s_scaled_v := integer( (s_real_v + 1.0) * 127.5 );
            IF s_scaled_v < 0 THEN
                s_scaled_v := 0;
            ELSIF s_scaled_v > 255 THEN
                s_scaled_v := 255;
            END IF;

            sine_value_i <= std_logic_vector(to_unsigned(s_scaled_v, sine_value_i'LENGTH));  

            -- advance phase
            phase_v := phase_v + PHASE_STEP;
            IF phase_v >= TWO_PI THEN
                phase_v := phase_v - TWO_PI;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------------------------
    -- Simulation end condition
    ----------------------------------------------------------------
    end_sim_proc : PROCESS
    BEGIN
        -- enough time to see multiple frames and a few trigger/collect/draw cycles
        WAIT FOR 10 ms;
        ASSERT false REPORT "Simulation finished" SEVERITY failure;
    END PROCESS;

END ARCHITECTURE tb;
