ARCHITECTURE REG_a OF REG_e IS

    -- FSM States
    USE work.state_pkg.ALL;
    SIGNAL state_s, nextstate_s : state_type_t;

    -- Internal Signals
    SIGNAL adr_s  : STD_LOGIC_VECTOR(3 DOWNTO 0);  -- Address bus
    SIGNAL dat_s  : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Data bus
    SIGNAL wr_r_s : STD_LOGIC_VECTOR(9 DOWNTO 1);  -- Write enables for registers

    SIGNAL reg01_s, reg02_s, reg03_s, reg04_s, reg05_s, reg06_s,
           reg07_s, reg08_s, reg09_s : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

    -- FSM: Block 1: State Transitions
    proc_fsm : PROCESS(state_s, rx_ready_i, ascii_rx_i)
    BEGIN
        nextstate_s <= state_s; -- Default state
        CASE state_s IS
            WHEN rst_st =>
                IF (rx_ready_i = '1') THEN
                    IF (ascii_rx_i(7 DOWNTO 4) = "1111") THEN
                        nextstate_s <= wr_addr_st; -- Address write state
                    END IF;
                END IF;

            WHEN wr_addr_st =>
                nextstate_s <= wait_data_st;

            WHEN wait_data_st =>
                IF (rx_ready_i = '1') THEN
                    nextstate_s <= wr_data_st;
                END IF;

            WHEN wr_data_st =>
                nextstate_s <= wr_r_st;

            WHEN wr_r_st =>
                nextstate_s <= rst_st;

            WHEN OTHERS =>
                nextstate_s <= rst_st;
        END CASE;
    END PROCESS;



    -- FSM: Block 2: get addr and data from uart signal (generates outputs)
    proc_store : PROCESS(clk_i, rst_n_i)
    BEGIN
        IF (rst_n_i = '0') THEN
            adr_s <= (OTHERS => '0');
            dat_s <= (OTHERS => '0');
        ELSIF rising_edge(clk_i) THEN
            IF (state_s = wr_addr_st) THEN
                adr_s <= ascii_rx_i(3 DOWNTO 0); -- Extract higher nibble as address
            ELSIF (state_s = wr_data_st) THEN
                dat_s <= ascii_rx_i(7 DOWNTO 0); -- Capture data byte last for bits
            END IF;
        END IF;
    END PROCESS;

    -- generates enable signals for writing in the registers (from the addr that was made on the previous state)
    proc_wr_enable : PROCESS(state_s, adr_s)
    BEGIN
        wr_r_s <= (OTHERS => '0'); -- Default no write
        IF (state_s = wr_r_st) THEN
            CASE adr_s IS
                WHEN "0001" => wr_r_s(1) <= '1';
                WHEN "0010" => wr_r_s(2) <= '1';
                WHEN "0011" => wr_r_s(3) <= '1';
                WHEN "0100" => wr_r_s(4) <= '1';
                WHEN "0101" => wr_r_s(5) <= '1';
                WHEN "0110" => wr_r_s(6) <= '1';
                WHEN "0111" => wr_r_s(7) <= '1';
                WHEN "1000" => wr_r_s(8) <= '1';
                WHEN "1001" => wr_r_s(9) <= '1';
                WHEN OTHERS => NULL;
            END CASE;
        END IF;
    END PROCESS;
    
    -- FSM: Block 3: State Register (flipflop)
    proc_state : PROCESS(clk_i, rst_n_i)
    BEGIN
        IF (rst_n_i = '0') THEN
            state_s <= rst_st;
        ELSIF rising_edge(clk_i) THEN
            state_s <= nextstate_s;
        END IF;
    END PROCESS;

    -- Register Write Process
    proc_registers : PROCESS(clk_i, rst_n_i)
    BEGIN
        IF (rst_n_i = '0') THEN
            reg01_s <= (OTHERS => '0');
            reg02_s <= (OTHERS => '0');
            reg03_s <= (OTHERS => '0');
            reg04_s <= (OTHERS => '0');
            reg05_s <= (OTHERS => '0');
            reg06_s <= (OTHERS => '0');
            reg07_s <= (OTHERS => '0');
            reg08_s <= (OTHERS => '0');
            reg09_s <= (OTHERS => '0');
        ELSIF rising_edge(clk_i) THEN
            IF (wr_r_s(1) = '1') THEN reg01_s <= dat_s; END IF;
            IF (wr_r_s(2) = '1') THEN reg02_s <= dat_s; END IF;
            IF (wr_r_s(3) = '1') THEN reg03_s <= dat_s; END IF;
            IF (wr_r_s(4) = '1') THEN reg04_s <= dat_s; END IF;
            IF (wr_r_s(5) = '1') THEN reg05_s <= dat_s; END IF;
            IF (wr_r_s(6) = '1') THEN reg06_s <= dat_s; END IF;
            IF (wr_r_s(7) = '1') THEN reg07_s <= dat_s; END IF;
            IF (wr_r_s(8) = '1') THEN reg08_s <= dat_s; END IF;
            IF (wr_r_s(9) = '1') THEN reg09_s <= dat_s; END IF;
        END IF;
    END PROCESS;

    -- Outputs
    reg01_o <= reg01_s;
    reg02_o <= reg02_s;
    reg03_o <= reg03_s;
    reg04_o <= reg04_s;
    reg05_o <= reg05_s;
    reg06_o <= reg06_s;
    reg07_o <= reg07_s;
    reg08_o <= reg08_s;
    reg09_o <= reg09_s;
    state_o <= state_s;-- just for visualization purposes(in the vhdl simulation)

END ARCHITECTURE REG_a;