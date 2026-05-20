LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY pio_select IS
    PORT(
        clk       : IN  STD_LOGIC;
        reset_n   : IN  STD_LOGIC;
        chipselect: IN  STD_LOGIC;                     -- Nouveau
        write     : IN  STD_LOGIC;                     -- Nouveau
        writedata : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        q         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END pio_select;

ARCHITECTURE rtl OF pio_select IS
    SIGNAL reg_select : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
    PROCESS(clk, reset_n)
    BEGIN
        IF reset_n = '0' THEN
            reg_select <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            reg_select <= writedata;
        END IF;
    END PROCESS;

    q <= reg_select;
END rtl;