LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY component_tutorial IS
PORT (
    CLOCK_50 : IN STD_LOGIC;
    KEY      : IN STD_LOGIC_VECTOR(0 DOWNTO 0);

    HEX0 : OUT STD_LOGIC_VECTOR(0 TO 6);
    HEX1 : OUT STD_LOGIC_VECTOR(0 TO 6);
    HEX2 : OUT STD_LOGIC_VECTOR(0 TO 6);
    HEX3 : OUT STD_LOGIC_VECTOR(0 TO 6);

    LEDG : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    LEDR : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
);
END component_tutorial;

ARCHITECTURE Structure OF component_tutorial IS

    SIGNAL to_HEX : STD_LOGIC_VECTOR(15 DOWNTO 0);

    COMPONENT nios_system IS
        PORT (
            clk           : IN  STD_LOGIC;
            reset_n       : IN  STD_LOGIC;
            to_hex_export : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT hex7seg IS
        PORT (
            hex     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            display : OUT STD_LOGIC_VECTOR(0 TO 6)
        );
    END COMPONENT;

BEGIN

    U0: nios_system
        PORT MAP (
            clk           => CLOCK_50,
            reset_n       => KEY(0),
            to_hex_export => to_HEX
        );

    h0: hex7seg PORT MAP (to_HEX(3 DOWNTO 0),   HEX0);
    h1: hex7seg PORT MAP (to_HEX(7 DOWNTO 4),   HEX1);
    h2: hex7seg PORT MAP (to_HEX(11 DOWNTO 8),  HEX2);
    h3: hex7seg PORT MAP (to_HEX(15 DOWNTO 12), HEX3);

    LEDG <= to_HEX(7 downto 0);
    LEDR <= to_HEX;

END Structure;
