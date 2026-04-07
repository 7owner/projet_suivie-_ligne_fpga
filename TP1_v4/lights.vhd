library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lights is
    port (
        CLOCK_50   : in  std_logic;
        KEY        : in  std_logic_vector(1 downto 0);
        SW         : in  std_logic_vector(7 downto 0);
        LED        : out std_logic_vector(7 downto 0);

        -- SDRAM
        DRAM_CLK   : out std_logic;
        DRAM_CKE   : out std_logic;
        DRAM_ADDR  : out std_logic_vector(12 downto 0);
        DRAM_BA    : out std_logic_vector(1 downto 0);
        DRAM_CS_N  : out std_logic;
        DRAM_CAS_N : out std_logic;
        DRAM_RAS_N : out std_logic;
        DRAM_WE_N  : out std_logic;
        DRAM_DQ    : inout std_logic_vector(15 downto 0);
        DRAM_DQM   : out std_logic_vector(1 downto 0);

        -- Moteurs
        MTRR_N : out std_logic;
        MTRR_P : out std_logic;
        MTRL_P : out std_logic;
        MTRL_N : out std_logic;

        MTR_Sleep_n : out std_logic;
        MTR_Fault_n : in  std_logic;

        -- ADC LTC2308
        ADC_CONVST : out std_logic;
        ADC_SCK    : out std_logic;
        ADC_SDI    : out std_logic;
        ADC_SDO    : in  std_logic;

        -- Alimentation ADC
        VCC3P3_PWRON_n : out std_logic
    );
end entity;

architecture rtl of lights is

    --------------------------------------------------------------------
    -- Nouveau composant Qsys EXACTEMENT comme tu l’as donné
    --------------------------------------------------------------------
    component nios_system is
        port (
            reset_reset_n      : in    std_logic;
            switches_export    : in    std_logic_vector(7 downto 0);
            leds_export        : out   std_logic_vector(7 downto 0);
            clk_clk            : in    std_logic;

            sdram_wire_addr    : out   std_logic_vector(12 downto 0);
            sdram_wire_ba      : out   std_logic_vector(1 downto 0);
            sdram_wire_cas_n   : out   std_logic;
            sdram_wire_cke     : out   std_logic;
            sdram_wire_cs_n    : out   std_logic;
            sdram_wire_dq      : inout std_logic_vector(15 downto 0);
            sdram_wire_dqm     : out   std_logic_vector(1 downto 0);
            sdram_wire_ras_n   : out   std_logic;
            sdram_wire_we_n    : out   std_logic;

            motorr_export      : out   std_logic_vector(15 downto 0);
            motorl_export      : out   std_logic_vector(15 downto 0);

            inpossensor_export : in    std_logic_vector(7 downto 0);

            -- ⭐ NOUVELLE HORLOGE SDRAM
            sdram_clk_clk      : out   std_logic
        );
    end component;

    --------------------------------------------------------------------
    -- Autres composants
    --------------------------------------------------------------------
    component PWM_generation is
        port (
            clk          : in  std_logic;
            reset_n      : in  std_logic;
            s_writedataR : in  std_logic_vector(15 downto 0);
            s_writedataL : in  std_logic_vector(15 downto 0);
            dc_motor_p_R : out std_logic;
            dc_motor_n_R : out std_logic;
            dc_motor_p_L : out std_logic;
            dc_motor_n_L : out std_logic
        );
    end component;

    component pll_2freqs is
        port (
            areset : in  std_logic;
            inclk0 : in  std_logic;
            c0     : out std_logic; -- 40 MHz
            c1     : out std_logic  -- 2 kHz
        );
    end component;

    component capteurs_sol_seuil is
        port (
            clk          : in  std_logic;
            reset_n      : in  std_logic;
            data_capture : in  std_logic;

            data_readyr  : out std_logic;
            data0r       : out std_logic_vector(7 downto 0);
            data1r       : out std_logic_vector(7 downto 0);
            data2r       : out std_logic_vector(7 downto 0);
            data3r       : out std_logic_vector(7 downto 0);
            data4r       : out std_logic_vector(7 downto 0);
            data5r       : out std_logic_vector(7 downto 0);
            data6r       : out std_logic_vector(7 downto 0);

            NIVEAU       : in  std_logic_vector(7 downto 0);
            vect_capt    : out std_logic_vector(6 downto 0);

            ADC_CONVSTr  : out std_logic;
            ADC_SCK      : out std_logic;
            ADC_SDIr     : out std_logic;
            ADC_SDO      : in  std_logic
        );
    end component;

    --------------------------------------------------------------------
    -- Signaux internes
    --------------------------------------------------------------------
    signal rst_n : std_logic;

    signal clk40 : std_logic;
    signal clk2k : std_logic;

    signal motorR_cmd : std_logic_vector(15 downto 0);
    signal motorL_cmd : std_logic_vector(15 downto 0);

    signal vect_capt_s : std_logic_vector(6 downto 0);
    signal niveau_seuil : std_logic_vector(7 downto 0) := x"40";

    signal data0_s, data1_s, data2_s : std_logic_vector(7 downto 0);

    -- ⭐ Horloge SDRAM générée par Qsys
    signal sdram_clk_s : std_logic;

begin

    --------------------------------------------------------------------
    -- Reset
    --------------------------------------------------------------------
    rst_n <= KEY(0);

    --------------------------------------------------------------------
    -- Alimentation ADC
    --------------------------------------------------------------------
    VCC3P3_PWRON_n <= '0';

    --------------------------------------------------------------------
    -- PLL
    --------------------------------------------------------------------
    u_pll : pll_2freqs
        port map (
            areset => not rst_n,
            inclk0 => CLOCK_50,
            c0     => clk40,
            c1     => clk2k
        );

    --------------------------------------------------------------------
    -- Capteurs sol
    --------------------------------------------------------------------
    u_caps : capteurs_sol_seuil
        port map (
            clk          => clk40,
            reset_n      => rst_n,
            data_capture => clk2k,

            data_readyr  => open,
            data0r       => data0_s,
            data1r       => data1_s,
            data2r       => data2_s,
            data3r       => open,
            data4r       => open,
            data5r       => open,
            data6r       => open,

            NIVEAU       => niveau_seuil,
            vect_capt    => vect_capt_s,

            ADC_CONVSTr  => ADC_CONVST,
            ADC_SCK      => ADC_SCK,
            ADC_SDIr     => ADC_SDI,
            ADC_SDO      => ADC_SDO
        );

    --------------------------------------------------------------------
    -- Debug LED = capteur 0
    --------------------------------------------------------------------
    LED <= data0_s;

    --------------------------------------------------------------------
    -- Nios II
    --------------------------------------------------------------------
    u0 : nios_system
        port map (
            reset_reset_n      => rst_n,
            switches_export    => SW,
            leds_export        => open,

            clk_clk            => CLOCK_50,

            sdram_wire_addr    => DRAM_ADDR,
            sdram_wire_ba      => DRAM_BA,
            sdram_wire_cas_n   => DRAM_CAS_N,
            sdram_wire_cke     => DRAM_CKE,
            sdram_wire_cs_n    => DRAM_CS_N,
            sdram_wire_dq      => DRAM_DQ,
            sdram_wire_dqm     => DRAM_DQM,
            sdram_wire_ras_n   => DRAM_RAS_N,
            sdram_wire_we_n    => DRAM_WE_N,

            motorr_export      => motorR_cmd,
            motorl_export      => motorL_cmd,

            inpossensor_export => ('0' & vect_capt_s),

            -- ⭐ NOUVELLE HORLOGE SDRAM
            sdram_clk_clk      => sdram_clk_s
        );

    --------------------------------------------------------------------
    -- Horloge SDRAM vers la pin du FPGA
    --------------------------------------------------------------------
    DRAM_CLK <= sdram_clk_s;

    --------------------------------------------------------------------
    -- PWM moteurs
    --------------------------------------------------------------------
    PWM0 : PWM_generation
        port map (
            clk          => CLOCK_50,
            reset_n      => rst_n,
            s_writedataR => motorR_cmd,
            s_writedataL => motorL_cmd,
            dc_motor_p_R => MTRR_P,
            dc_motor_n_R => MTRR_N,
            dc_motor_p_L => MTRL_P,
            dc_motor_n_L => MTRL_N
        );

    --------------------------------------------------------------------
    -- DRV8848
    --------------------------------------------------------------------
    MTR_Sleep_n <= '1';

end architecture;
