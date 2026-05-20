LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY swap_bytes IS
    PORT(
        clk         : IN  std_logic;
        reset_n     : IN  std_logic;
        address     : IN  std_logic_vector(1 DOWNTO 0);
        chipselect  : IN  std_logic;
        read        : IN  std_logic;
        write       : IN  std_logic;
        writedata   : IN  std_logic_vector(31 DOWNTO 0);
        readdata    : OUT std_logic_vector(31 DOWNTO 0);
        waitrequest : OUT std_logic
    );
END swap_bytes;

ARCHITECTURE behavior OF swap_bytes IS
    SIGNAL reg_out : std_logic_vector(31 DOWNTO 0);
BEGIN
    waitrequest <= '0';  -- composant toujours prêt

    -- Écriture et swap combinatoire directement à partir de writedata
    PROCESS(clk, reset_n)
    BEGIN
        IF reset_n = '0' THEN
            reg_out <= (others => '0');
        ELSIF rising_edge(clk) THEN
            IF chipselect = '1' AND write = '1' THEN
                reg_out <= writedata(7 downto 0) & writedata(15 downto 8) & writedata(23 downto 16) & writedata(31 downto 24);
            END IF;
        END IF;
    END PROCESS;

    -- Lecture du registre de sortie
    readdata <= reg_out WHEN chipselect = '1' AND read = '1' ELSE (others => '0');

END behavior;
