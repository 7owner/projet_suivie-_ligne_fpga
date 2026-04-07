LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY lights IS
    PORT (
        CLOCK_50   : IN  STD_LOGIC;
        KEY        : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        SW         : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        LED        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);

        -- SDRAM
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

        -- Sorties moteurs CuteCar (DRV8848)
        MTRR_N : OUT STD_LOGIC;  -- GPIO_2[5]  → PIN_D15
        MTRR_P : OUT STD_LOGIC;  -- GPIO_2[6]  → PIN_D14
        MTRL_P : OUT STD_LOGIC;  -- GPIO_2[7]  → PIN_F15
        MTRL_N : OUT STD_LOGIC;  -- GPIO_2[8]  → PIN_F16

        MTR_Sleep_n : OUT STD_LOGIC;  -- GPIO_2[9]  → PIN_F14
        MTR_Fault_n : IN  STD_LOGIC   -- GPIO_2[10] → PIN_??
    );
END lights;

ARCHITECTURE lights_rtl OF lights IS

    --------------------------------------------------------------------
    -- Déclaration du système Nios II généré par Platform Designer
    --------------------------------------------------------------------
    COMPONENT nios_system
        PORT (
            clk_clk          : IN    STD_LOGIC;
            reset_reset_n    : IN    STD_LOGIC;
				sdram_clk_clk    : out   std_logic ;
            switches_export  : IN    STD_LOGIC_VECTOR (7 DOWNTO 0);
            leds_export      : OUT   STD_LOGIC_VECTOR (7 DOWNTO 0);

            motorr_export    : OUT   STD_LOGIC_VECTOR(15 DOWNTO 0);
            motorl_export    : OUT   STD_LOGIC_VECTOR(15 DOWNTO 0);

            sdram_wire_addr  : OUT   STD_LOGIC_VECTOR(12 DOWNTO 0);
            sdram_wire_ba    : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            sdram_wire_cas_n : OUT   STD_LOGIC;
            sdram_wire_cke   : OUT   STD_LOGIC;
            sdram_wire_cs_n  : OUT   STD_LOGIC;
            sdram_wire_dq    : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            sdram_wire_dqm   : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            sdram_wire_ras_n : OUT   STD_LOGIC;
            sdram_wire_we_n  : OUT   STD_LOGIC
        );
    END COMPONENT;

    --------------------------------------------------------------------
    -- Module PWM pour CuteCar
    --------------------------------------------------------------------
    COMPONENT PWM_generation IS
        PORT(
            clk        : IN  STD_LOGIC;
            reset_n    : IN  STD_LOGIC;

            s_writedataR : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            s_writedataL : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

            dc_motor_p_R : OUT STD_LOGIC;
            dc_motor_n_R : OUT STD_LOGIC;
            dc_motor_p_L : OUT STD_LOGIC;
            dc_motor_n_L : OUT STD_LOGIC
        );
    END COMPONENT;

    --------------------------------------------------------------------
    -- Signaux internes reliant Nios II au PWM
    --------------------------------------------------------------------
    SIGNAL motorR_cmd : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL motorL_cmd : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

    --------------------------------------------------------------------
    -- Instanciation du Nios II
    --------------------------------------------------------------------
    NiosII : nios_system
        PORT MAP (
            clk_clk          => CLOCK_50,
            reset_reset_n    => KEY(0),

            switches_export  => SW,
            leds_export      => LED,

            motorr_export    => motorR_cmd,
            motorl_export    => motorL_cmd,

            sdram_wire_addr  => DRAM_ADDR,
            sdram_wire_ba    => DRAM_BA,
            sdram_wire_cas_n => DRAM_CAS_N,
            sdram_wire_cke   => DRAM_CKE,
            sdram_wire_cs_n  => DRAM_CS_N,
            sdram_wire_dq    => DRAM_DQ,
            sdram_wire_dqm   => DRAM_DQM,
            sdram_wire_ras_n => DRAM_RAS_N,
            sdram_wire_we_n  => DRAM_WE_N
        );

    DRAM_CLK <= CLOCK_50;

    --------------------------------------------------------------------
    -- Instanciation du module PWM
    --------------------------------------------------------------------
    pwm_generated : PWM_generation
        PORT MAP (
            clk           => CLOCK_50,
            reset_n       => KEY(1),

            s_writedataR  => motorR_cmd,
            s_writedataL  => motorL_cmd,

            dc_motor_p_R  => MTRR_P,
            dc_motor_n_R  => MTRR_N,
            dc_motor_p_L  => MTRL_P,
            dc_motor_n_L  => MTRL_N
        );

    --------------------------------------------------------------------
    -- Gestion du DRV8848
    --------------------------------------------------------------------
    MTR_Sleep_n <= '1';  -- Active le driver en permanence

END lights_rtl;
