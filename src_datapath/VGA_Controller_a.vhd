LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.Project_Constants_Pkg.ALL;

ARCHITECTURE VGA_Controller_a OF VGA_Controller_e IS
    
    SIGNAL h_count_r : integer range 0 to H_TOTAL_C - 1;
    SIGNAL v_count_r : integer range 0 to V_TOTAL_C - 1;
    
    SIGNAL video_on_s : std_logic;

BEGIN

    -- 1. Horizontal and Vertical Counters
    PROCESS(clk_i, rst_n_i)
    BEGIN
        IF (rst_n_i = '0') THEN
            h_count_r <= 0;
            v_count_r <= 0;
        ELSIF rising_edge(clk_i) THEN
            -- Horizontal Counter
            IF (h_count_r = H_TOTAL_C - 1) THEN
                h_count_r <= 0;
                -- Vertical Counter
                IF (v_count_r = V_TOTAL_C - 1) THEN
                    v_count_r <= 0;
                ELSE
                    v_count_r <= v_count_r + 1;
                END IF;
            ELSE
                h_count_r <= h_count_r + 1;
            END IF;
        END IF;
    END PROCESS;
    
    -- 2. Sync Pulse Generation
    hsync_o <= '0' WHEN (h_count_r >= (H_VISIBLE_AREA_C + H_FRONT_PORCH_C) AND 
                         h_count_r < (H_VISIBLE_AREA_C + H_FRONT_PORCH_C + H_SYNC_PULSE_C)) 
               ELSE '1';
               
    vsync_o <= '0' WHEN (v_count_r >= (V_VISIBLE_AREA_C + V_FRONT_PORCH_C) AND 
                         v_count_r < (V_VISIBLE_AREA_C + V_FRONT_PORCH_C + V_SYNC_PULSE_C)) 
               ELSE '1';

    -- 3. Video On Signal (Active Area)
    video_on_s <= '1' WHEN (h_count_r < H_VISIBLE_AREA_C AND v_count_r < V_VISIBLE_AREA_C) ELSE '0';

    -- 4. RGB Output Logic
    -- Simple logic: Display a visual bar based on the BCD value
    PROCESS(video_on_s, h_count_r, v_count_r, bcd_data_i)
        VARIABLE bcd_val_int : integer;
    BEGIN
        red_o   <= (OTHERS => '0');
        green_o <= (OTHERS => '0');
        blue_o  <= (OTHERS => '0');
        
        bcd_val_int := to_integer(unsigned(bcd_data_i));
        
        IF (video_on_s = '1') THEN
            -- Draw a Green bar proportional to the time measured
            -- Scale: 10 pixels per ms unit
            IF (v_count_r > 200 AND v_count_r < 280) THEN
                IF (h_count_r < (bcd_val_int * 10)) THEN
                    green_o <= (OTHERS => '1'); -- Full Green
                ELSE
                    red_o   <= (OTHERS => '1'); -- Red background for the rest
                END IF;
            ELSE
                -- Blue background elsewhere
                blue_o <= (OTHERS => '1');
            END IF;
        END IF;
    END PROCESS;

END VGA_Controller_a;