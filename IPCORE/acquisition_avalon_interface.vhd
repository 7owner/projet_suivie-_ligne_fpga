library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity acquisition_avalon_interface is
    port (
        clock       : in  std_logic;
        resetn      : in  std_logic;

        address     : in  std_logic_vector(3 downto 0);
        write       : in  std_logic;
        read        : in  std_logic;
        chipselect  : in  std_logic;
        byteenable  : in  std_logic_vector(1 downto 0);
        writedata   : in  std_logic_vector(15 downto 0);
        readdata    : out std_logic_vector(15 downto 0);

        ADC_CONVSTr : out std_logic;
        ADC_SCK     : out std_logic;
        ADC_SDIr    : out std_logic;
        ADC_SDO     : in  std_logic;

        vect_capt_export  : out std_logic_vector(6 downto 0);
        data_ready_export : out std_logic
    );
end entity;

architecture Structure of acquisition_avalon_interface is

    signal clk40_s     : std_logic;
    signal clk2k_s     : std_logic;
    signal clk2k_d     : std_logic := '0';
    signal pll_reset_s : std_logic;

    signal data_capture_s : std_logic := '0';
    signal data_ready_s   : std_logic;

    signal data0_s : std_logic_vector(7 downto 0);
    signal data1_s : std_logic_vector(7 downto 0);
    signal data2_s : std_logic_vector(7 downto 0);
    signal data3_s : std_logic_vector(7 downto 0);
    signal data4_s : std_logic_vector(7 downto 0);
    signal data5_s : std_logic_vector(7 downto 0);
    signal data6_s : std_logic_vector(7 downto 0);

    signal vect_capt_s : std_logic_vector(6 downto 0);
    signal niveau_s    : std_logic_vector(7 downto 0) := x"28";

    component pll_2freqs is
        port (
            areset : in  std_logic := '0';
            inclk0 : in  std_logic := '0';
            c0     : out std_logic;
            c1     : out std_logic
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

begin

    pll_reset_s <= not resetn;

    U_PLL : pll_2freqs
        port map (
            areset => pll_reset_s,
            inclk0 => clock,
            c0     => clk40_s,
            c1     => clk2k_s
        );

    -- Génération d'une impulsion 1 cycle Avalon à chaque front montant de clk2k_s
    process(clock)
    begin
        if rising_edge(clock) then
            if resetn = '0' then
                clk2k_d        <= '0';
                data_capture_s <= '0';
            else
                clk2k_d <= clk2k_s;

                if clk2k_s = '1' and clk2k_d = '0' then
                    data_capture_s <= '1';
                else
                    data_capture_s <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Registre niveau, offset 9
    process(clock)
    begin
        if rising_edge(clock) then
            if resetn = '0' then
                niveau_s <= x"28";
            else
                if chipselect = '1' and write = '1' then
                    case address is
                        when "1001" =>
                            if byteenable(0) = '1' then
                                niveau_s <= writedata(7 downto 0);
                            end if;

                        when others =>
                            null;
                    end case;
                end if;
            end if;
        end if;
    end process;

    with address select
        readdata <= x"00" & data0_s                    when "0000",
                    x"00" & data1_s                    when "0001",
                    x"00" & data2_s                    when "0010",
                    x"00" & data3_s                    when "0011",
                    x"00" & data4_s                    when "0100",
                    x"00" & data5_s                    when "0101",
                    x"00" & data6_s                    when "0110",
                    "000000000" & vect_capt_s          when "0111",
                    "000000000000000" & data_ready_s   when "1000",
                    x"00" & niveau_s                   when "1001",
                    x"0000"                            when others;

    vect_capt_export  <= vect_capt_s;
    data_ready_export <= data_ready_s;

    U_CAPTEURS : capteurs_sol_seuil
        port map (
            clk          => clk40_s,
            reset_n      => resetn,
            data_capture => data_capture_s,
            data_readyr  => data_ready_s,
            data0r       => data0_s,
            data1r       => data1_s,
            data2r       => data2_s,
            data3r       => data3_s,
            data4r       => data4_s,
            data5r       => data5_s,
            data6r       => data6_s,
            NIVEAU       => niveau_s,
            vect_capt    => vect_capt_s,
            ADC_CONVSTr  => ADC_CONVSTr,
            ADC_SCK      => ADC_SCK,
            ADC_SDIr     => ADC_SDIr,
            ADC_SDO      => ADC_SDO
        );

end architecture;