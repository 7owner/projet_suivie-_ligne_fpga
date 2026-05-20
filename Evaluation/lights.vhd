LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY lights IS
    PORT (
        CLOCK_50 : IN STD_LOGIC;
        KEY      : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        SW       : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        LED      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        MTRR_N : OUT STD_LOGIC;
        MTRR_P : OUT STD_LOGIC;
        MTRL_P : OUT STD_LOGIC;
        MTRL_N : OUT STD_LOGIC;

        MTR_Sleep_n : OUT STD_LOGIC;
        MTR_Fault_n : IN STD_LOGIC
    );
END lights;

ARCHITECTURE rtl OF lights IS

    COMPONENT nios_system IS
        PORT (
            reset_reset_n       : IN  STD_LOGIC;
            switches_export     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            leds_export         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            clk_clk             : IN  STD_LOGIC
        );
    END COMPONENT;

    COMPONENT swap_bytes_component IS
        PORT(
            clk         : IN  STD_LOGIC;
            reset_n     : IN  STD_LOGIC;
            address     : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            chipselect  : IN  STD_LOGIC;
            read        : IN  STD_LOGIC;
            write       : IN  STD_LOGIC;
            writedata   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            readdata    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            waitrequest : OUT STD_LOGIC;
            mode_select : IN  STD_LOGIC
        );
    END COMPONENT;

    COMPONENT pio_select IS
        PORT(
            clk        : IN  STD_LOGIC;
            reset_n    : IN  STD_LOGIC;
            chipselect : IN  STD_LOGIC;
            write      : IN  STD_LOGIC;
            writedata  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            q          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL swapped_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL select_mode  : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

    -- Instanciation du Nios II
    u0 : nios_system
        PORT MAP (
            reset_reset_n   => KEY(0),
            switches_export => SW,
            leds_export     => LED,
            clk_clk         => CLOCK_50
        );

    -- Instanciation du PIO select
    pio_inst : pio_select
        PORT MAP (
            clk        => CLOCK_50,
            reset_n    => KEY(0),
            chipselect => '1',
            write      => '1',
            writedata  => X"0001",      -- valeur de test pour mode 1, changer à 0 pour mode 0
            q          => select_mode
        );

    -- Instanciation du composant swap_bytes
    swap_inst : swap_bytes_component
        PORT MAP (
            clk         => CLOCK_50,
            reset_n     => KEY(0),
            address     => "00",
            chipselect  => '1',
            read        => '1',
            write       => '1',
            writedata   => X"12345678", -- valeur test
            readdata    => swapped_data,
            waitrequest => open,
            mode_select => select_mode(0)  -- LSB du PIO pour sélectionner le mode
        );

    -- Connecter les 8 LSB sur LEDs pour visualisation
    LED <= swapped_data(7 DOWNTO 0);

    -- Activation du driver moteur
    MTR_Sleep_n <= '1';

END rtl;