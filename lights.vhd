LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY lights IS
    PORT (
        CLOCK_50 : IN STD_LOGIC;
        KEY      : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        SW       : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        LED      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        DRAM_CLK   : OUT STD_LOGIC;
        DRAM_CKE   : OUT STD_LOGIC;
        DRAM_ADDR  : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
        DRAM_BA    : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        DRAM_CS_N  : OUT STD_LOGIC;
        DRAM_CAS_N : OUT STD_LOGIC;
        DRAM_RAS_N : OUT STD_LOGIC;
        DRAM_WE_N  : OUT STD_LOGIC;
        DRAM_DQ    : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DRAM_DQM   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        MTRR_N : OUT STD_LOGIC;
        MTRR_P : OUT STD_LOGIC;
        MTRL_P : OUT STD_LOGIC;
        MTRL_N : OUT STD_LOGIC;

        MTR_Sleep_n : OUT STD_LOGIC;
        MTR_Fault_n : IN STD_LOGIC
    );
END lights;

ARCHITECTURE rtl OF lights IS

    SIGNAL reset_cnt : unsigned(23 DOWNTO 0) := (OTHERS => '0');
    SIGNAL reset_n_i : STD_LOGIC := '0';

    COMPONENT nios_system IS
        PORT (
            reset_reset_n   : IN STD_LOGIC;
            switches_export : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            leds_export     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            clk_clk         : IN STD_LOGIC;

            sdram_wire_addr  : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
            sdram_wire_ba    : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            sdram_wire_cas_n : OUT STD_LOGIC;
            sdram_wire_cke   : OUT STD_LOGIC;
            sdram_wire_cs_n  : OUT STD_LOGIC;
            sdram_wire_dq    : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            sdram_wire_dqm   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            sdram_wire_ras_n : OUT STD_LOGIC;
            sdram_wire_we_n  : OUT STD_LOGIC;

            sdram_clk_clk : OUT STD_LOGIC;

            dc_motor_p_r_export : OUT STD_LOGIC;
            dc_motor_n_r_export : OUT STD_LOGIC;
            dc_motor_p_l_export : OUT STD_LOGIC;
            dc_motor_n_l_export : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN

    PROCESS(CLOCK_50)
    BEGIN
        IF rising_edge(CLOCK_50) THEN
            IF KEY(0) = '0' THEN
                reset_cnt <= (OTHERS => '0');
                reset_n_i <= '0';
            ELSE
                IF reset_cnt /= x"FFFFFF" THEN
                    reset_cnt <= reset_cnt + 1;
                    reset_n_i <= '0';
                ELSE
                    reset_n_i <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    u0 : nios_system
        PORT MAP (
            reset_reset_n   => reset_n_i,
            switches_export => SW,
            leds_export     => LED,
            clk_clk         => CLOCK_50,

            sdram_wire_addr  => DRAM_ADDR,
            sdram_wire_ba    => DRAM_BA,
            sdram_wire_cas_n => DRAM_CAS_N,
            sdram_wire_cke   => DRAM_CKE,
            sdram_wire_cs_n  => DRAM_CS_N,
            sdram_wire_dq    => DRAM_DQ,
            sdram_wire_dqm   => DRAM_DQM,
            sdram_wire_ras_n => DRAM_RAS_N,
            sdram_wire_we_n  => DRAM_WE_N,

            sdram_clk_clk => DRAM_CLK,

            dc_motor_p_r_export => MTRR_P,
            dc_motor_n_r_export => MTRR_N,
            dc_motor_p_l_export => MTRL_P,
            dc_motor_n_l_export => MTRL_N
        );

    MTR_Sleep_n <= '1';

END rtl;