library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Top_CUTECAR is
  port (
    CLOCK_50 : in  std_logic;
    KEY      : in  std_logic_vector(0 downto 0);
    SW       : in  std_logic_vector(7 downto 0);
    LED      : out std_logic_vector(7 downto 0);

    DRAM_CLK, DRAM_CKE : out std_logic;
    DRAM_ADDR          : out std_logic_vector(12 downto 0);
    DRAM_BA            : out std_logic_vector(1 downto 0);
    DRAM_CS_N          : out std_logic;
    DRAM_CAS_N         : out std_logic;
    DRAM_RAS_N         : out std_logic;
    DRAM_WE_N          : out std_logic;
    DRAM_DQ            : inout std_logic_vector(15 downto 0);
    DRAM_DQM           : out std_logic_vector(1 downto 0);

    MTRR_P : out std_logic;
    MTRR_N : out std_logic;
    MTRL_P : out std_logic;
    MTRL_N : out std_logic;

    LTC_ADC_CONVST : out std_logic;
    LTC_ADC_SCK    : out std_logic;
    LTC_ADC_SDI    : out std_logic;
    LTC_ADC_SDO    : in  std_logic;

    VCC3P3_PWRON_n : out std_logic
  );
end entity;

architecture Structure of Top_CUTECAR is

  component Nios_CUTECAR is
    port (
      clk_clk                               : in    std_logic                     := 'X';
      switches_export                       : in    std_logic_vector(7 downto 0)  := (others => 'X');
      leds_export                           : out   std_logic_vector(7 downto 0);

      sdram_wire_addr                       : out   std_logic_vector(12 downto 0);
      sdram_wire_ba                         : out   std_logic_vector(1 downto 0);
      sdram_wire_cas_n                      : out   std_logic;
      sdram_wire_cke                        : out   std_logic;
      sdram_wire_cs_n                       : out   std_logic;
      sdram_wire_dq                         : inout std_logic_vector(15 downto 0) := (others => 'X');
      sdram_wire_dqm                        : out   std_logic_vector(1 downto 0);
      sdram_wire_ras_n                      : out   std_logic;
      sdram_wire_we_n                       : out   std_logic;

      reset_reset_n                         : in    std_logic                     := 'X';
      clocks_sdram_clk_clk                  : out   std_logic;

      writedatal_external_connection_export : out   std_logic_vector(13 downto 0);
      writedatar_external_connection_export : out   std_logic_vector(13 downto 0);

      pos_data0r_external_connection_export  : in    std_logic_vector(7 downto 0)  := (others => 'X');
      pos_data1r_external_connection_export  : in    std_logic_vector(7 downto 0)  := (others => 'X');
      pos_data2r_external_connection_export  : in    std_logic_vector(7 downto 0)  := (others => 'X');
      pos_data3r_external_connection_export  : in    std_logic_vector(7 downto 0)  := (others => 'X');
      pos_data4r_external_connection_export  : in    std_logic_vector(7 downto 0)  := (others => 'X');
      pos_data5r_external_connection_export  : in    std_logic_vector(7 downto 0)  := (others => 'X');
      pos_data6r_external_connection_export  : in    std_logic_vector(7 downto 0)  := (others => 'X');

      vect_pos_external_connection_export    : in    std_logic_vector(6 downto 0)  := (others => 'X');
      niveau_external_connection_export      : out   std_logic_vector(7 downto 0)  := (others => '0')
    );
  end component;

  component PWM_generation is
    port (
      clk          : in  std_logic;
      reset_n      : in  std_logic;
      s_writedataR : in  std_logic_vector(13 downto 0);
      s_writedataL : in  std_logic_vector(13 downto 0);
      dc_motor_p_R : out std_logic;
      dc_motor_n_R : out std_logic;
      dc_motor_p_L : out std_logic;
      dc_motor_n_L : out std_logic
    );
  end component;

  component capteurs_sol_seuil is
    port (
      clk         : in  std_logic;  -- max 40 MHz
      reset_n     : in  std_logic;
      data_capture: in  std_logic;  -- rising edge trigger
      data_readyr : out std_logic;

      data0r      : out std_logic_vector(7 downto 0);
      data1r      : out std_logic_vector(7 downto 0);
      data2r      : out std_logic_vector(7 downto 0);
      data3r      : out std_logic_vector(7 downto 0);
      data4r      : out std_logic_vector(7 downto 0);
      data5r      : out std_logic_vector(7 downto 0);
      data6r      : out std_logic_vector(7 downto 0);

      NIVEAU      : in  std_logic_vector(7 downto 0);
      vect_capt   : out std_logic_vector(6 downto 0);

      ADC_CONVSTr : out std_logic;
      ADC_SCK     : out std_logic;
      ADC_SDIr    : out std_logic;
      ADC_SDO     : in  std_logic
    );
  end component;

  component pll_2freqs is
    port (
      areset : in  std_logic := '0';
      inclk0 : in  std_logic := '0';
      c0     : out std_logic;  -- 40 MHz
      c1     : out std_logic   -- 2 kHz
    );
  end component;

  -- Signaux internes
  signal rst_n    : std_logic;
  signal clk40   : std_logic;
  signal clk2k   : std_logic;

  signal led_nios : std_logic_vector(7 downto 0);

  signal writedataL_s, writedataR_s : std_logic_vector(13 downto 0);

  signal pos_data0r_s, pos_data1r_s, pos_data2r_s : std_logic_vector(7 downto 0);
  signal pos_data3r_s, pos_data4r_s, pos_data5r_s : std_logic_vector(7 downto 0);
  signal pos_data6r_s : std_logic_vector(7 downto 0);

  signal vect_capt_s : std_logic_vector(6 downto 0);
  signal niveau   : std_logic_vector(7 downto 0);

  signal data_ready_s : std_logic;

begin

  rst_n <= KEY(0);

  -- Power ON 3.3V rail
  VCC3P3_PWRON_n <= '0';

  -- PLL hardware : 50 MHz -> 40 MHz + 2 kHz
  u_pll : pll_2freqs
    port map (
      areset => not rst_n,
      inclk0 => CLOCK_50,
      c0     => clk40,
      c1     => clk2k
    );


  -- Capteurs sol seuillés
  u_caps : capteurs_sol_seuil
    port map (
      clk          => clk40,
      reset_n      => rst_n,
      data_capture => clk2k,
      data_readyr  => data_ready_s,

      data0r => pos_data0r_s,
      data1r => pos_data1r_s,
      data2r => pos_data2r_s,
      data3r => pos_data3r_s,
      data4r => pos_data4r_s,
      data5r => pos_data5r_s,
      data6r => pos_data6r_s,

      NIVEAU    => niveau,
      vect_capt => vect_capt_s,

      ADC_CONVSTr => LTC_ADC_CONVST,
      ADC_SCK     => LTC_ADC_SCK,
      ADC_SDIr    => LTC_ADC_SDI,
      ADC_SDO     => LTC_ADC_SDO
    );

  -- Debug LEDs: vect_capt + data_ready
  LED(6 downto 0) <= vect_capt_s;
  LED(7)          <= '0';

  -- Nios system
  NiosII : Nios_CUTECAR
    port map (
      clk_clk      => CLOCK_50,
      reset_reset_n => rst_n,

      switches_export => SW,
      leds_export     => led_nios,  -- (non utilisé ici car LED = debug)

      sdram_wire_addr  => DRAM_ADDR,
      sdram_wire_ba    => DRAM_BA,
      sdram_wire_cas_n => DRAM_CAS_N,
      sdram_wire_cke   => DRAM_CKE,
      sdram_wire_cs_n  => DRAM_CS_N,
      sdram_wire_dq    => DRAM_DQ,
      sdram_wire_dqm   => DRAM_DQM,
      sdram_wire_ras_n => DRAM_RAS_N,
      sdram_wire_we_n  => DRAM_WE_N,

      writedatal_external_connection_export => writedataL_s,
      writedatar_external_connection_export => writedataR_s,
      clocks_sdram_clk_clk                  => DRAM_CLK,

      pos_data0r_external_connection_export => pos_data0r_s,
      pos_data1r_external_connection_export => pos_data1r_s,
      pos_data2r_external_connection_export => pos_data2r_s,
      pos_data3r_external_connection_export => pos_data3r_s,
      pos_data4r_external_connection_export => pos_data4r_s,
      pos_data5r_external_connection_export => pos_data5r_s,
      pos_data6r_external_connection_export => pos_data6r_s,

      vect_pos_external_connection_export   => vect_capt_s,
      niveau_external_connection_export     => niveau
    );

  -- PWM moteurs
  PWM0 : PWM_generation
    port map (
      clk          => CLOCK_50,
      reset_n      => rst_n,
      s_writedataR => writedataR_s,
      s_writedataL => writedataL_s,
      dc_motor_p_R => MTRR_P,
      dc_motor_n_R => MTRR_N,
      dc_motor_p_L => MTRL_P,
      dc_motor_n_L => MTRL_N
    );

end architecture;