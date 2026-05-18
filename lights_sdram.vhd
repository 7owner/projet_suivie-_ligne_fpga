
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
ENTITY lights_sdram IS
PORT (
	SW : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	CLOCK_50 : IN STD_LOGIC;
	LED : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	DRAM_CLK, DRAM_CKE : OUT STD_LOGIC;
	DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
	DRAM_BA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	DRAM_CS_N, DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N : OUT STD_LOGIC;
	DRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	DRAM_DQM : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) );
END lights_sdram;
ARCHITECTURE Structure OF lights_sdram IS
COMPONENT nios_system
PORT (
	clk_clk : IN STD_LOGIC;
	reset_reset_n : IN STD_LOGIC;
	leds_export : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	switches_export : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	sdram_wire_addr0 : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
	sdram_wire_ba : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	sdram_wire_cas_n : OUT STD_LOGIC;
	sdram_wire_cke : OUT STD_LOGIC;
	sdram_wire_cs_n : OUT STD_LOGIC;
	sdram_wire_dq : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	sdram_wire_dqm : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	sdram_wire_ras_n : OUT STD_LOGIC;
	sdram_wire_we_n : OUT STD_LOGIC );
END COMPONENT;

BEGIN
	NiosII: nios_system
PORT MAP (
	clk_clk => CLOCK_50,
	reset_reset_n => KEY(0),
	leds_export => LED,
	switches_export => SW,
	sdram_wire_addr => DRAM_ADDR,
	sdram_wire_ba => DRAM_BA,
	sdram_wire_cas_n => DRAM_CAS_N,
	sdram_wire_cke => DRAM_CKE,
	sdram_wire_cs_n => DRAM_CS_N,
	sdram_wire_dq => DRAM_DQ,
	sdram_wire_dqm => DRAM_DQM,
	sdram_wire_ras_n => DRAM_RAS_N,
	sdram_wire_we_n => DRAM_WE_N );
	DRAM_CLK <= CLOCK_50;
END Structure;






    component nios_system is
        port (
            reset_reset_n    : in    std_logic                     := 'X';             -- reset_n
            switches_export  : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- export
            leds_export      : out   std_logic_vector(7 downto 0);                     -- export
            clk_clk          : in    std_logic                     := 'X';             -- clk
            sdram_wire_addr  : out   std_logic_vector(12 downto 0);                    -- addr
            sdram_wire_ba    : out   std_logic_vector(1 downto 0);                     -- ba
            sdram_wire_cas_n : out   std_logic;                                        -- cas_n
            sdram_wire_cke   : out   std_logic;                                        -- cke
            sdram_wire_cs_n  : out   std_logic;                                        -- cs_n
            sdram_wire_dq    : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
            sdram_wire_dqm   : out   std_logic_vector(1 downto 0);                     -- dqm
            sdram_wire_ras_n : out   std_logic;                                        -- ras_n
            sdram_wire_we_n  : out   std_logic                                         -- we_n
        );
    end component nios_system;

    u0 : component nios_system
        port map (
            reset_reset_n    => CONNECTED_TO_reset_reset_n,    --      reset.reset_n
            switches_export  => CONNECTED_TO_switches_export,  --   switches.export
            leds_export      => CONNECTED_TO_leds_export,      --       leds.export
            clk_clk          => CONNECTED_TO_clk_clk,          --        clk.clk
            sdram_wire_addr  => CONNECTED_TO_sdram_wire_addr,  -- sdram_wire.addr
            sdram_wire_ba    => CONNECTED_TO_sdram_wire_ba,    --           .ba
            sdram_wire_cas_n => CONNECTED_TO_sdram_wire_cas_n, --           .cas_n
            sdram_wire_cke   => CONNECTED_TO_sdram_wire_cke,   --           .cke
            sdram_wire_cs_n  => CONNECTED_TO_sdram_wire_cs_n,  --           .cs_n
            sdram_wire_dq    => CONNECTED_TO_sdram_wire_dq,    --           .dq
            sdram_wire_dqm   => CONNECTED_TO_sdram_wire_dqm,   --           .dqm
            sdram_wire_ras_n => CONNECTED_TO_sdram_wire_ras_n, --           .ras_n
            sdram_wire_we_n  => CONNECTED_TO_sdram_wire_we_n   --           .we_n
        );
