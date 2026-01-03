library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package sine_pkg is

    -- ===============================================================
    -- 1. FUNDAMENTAL CONSTANTS
    -- ===============================================================
    constant DATA_WIDTH_C : integer := 8;
    constant FREQ_WIDTH_C : integer := 8;
    constant ADDR_WIDTH_C : integer := 5;
    constant NUM_REGS_C   : integer := 8;

    -- ===============================================================
    -- 2. DERIVED CONSTANTS
    -- ===============================================================
    constant DATA_MAX_BIT_C : integer := DATA_WIDTH_C - 1;
    constant FREQ_MAX_BIT_C : integer := FREQ_WIDTH_C - 1;
    constant ADDR_MAX_BIT_C : integer := ADDR_WIDTH_C - 1;

    constant REG_BUS_WIDTH_C   : integer := NUM_REGS_C * DATA_WIDTH_C;
    constant REG_BUS_MAX_BIT_C : integer := REG_BUS_WIDTH_C - 1;
    constant REG_INDEX_LAST_C  : integer := NUM_REGS_C - 1;

    constant INDEX_WIDTH_C     : integer := 3; 
    constant INDEX_MAX_BIT_C   : integer := INDEX_WIDTH_C - 1;
    constant QUAD_LOW_BIT_C    : integer := INDEX_WIDTH_C;

    -- Simulation Timing
    constant CLK_PERIOD_C : time := 20 ns;
    constant FREQ_LOW_C   : std_logic_vector(FREQ_MAX_BIT_C downto 0) := x"04";
    constant FREQ_HIGH_C  : std_logic_vector(FREQ_MAX_BIT_C downto 0) := x"10";

    -- ===============================================================
    -- 3. SINE LOOK-UP TABLE (Required for Testbench!)
    -- ===============================================================
    -- This defines the array type for 8 registers
    type lut_array_t is array (0 to REG_INDEX_LAST_C) of std_logic_vector(DATA_MAX_BIT_C downto 0);
    
    -- These are the calculated Quarter-Wave Sine Values
    constant SINE_DEFAULTS_C : lut_array_t := (
        std_logic_vector(to_signed(0,   DATA_WIDTH_C)),
        std_logic_vector(to_signed(25,  DATA_WIDTH_C)),
        std_logic_vector(to_signed(49,  DATA_WIDTH_C)),
        std_logic_vector(to_signed(71,  DATA_WIDTH_C)),
        std_logic_vector(to_signed(90,  DATA_WIDTH_C)),
        std_logic_vector(to_signed(106, DATA_WIDTH_C)),
        std_logic_vector(to_signed(117, DATA_WIDTH_C)),
        std_logic_vector(to_signed(127, DATA_WIDTH_C))
    );

end package sine_pkg;