LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg16_avalon_interface IS
    PORT (
        clock      : IN  STD_LOGIC;
        resetn     : IN  STD_LOGIC;
        read       : IN  STD_LOGIC;
        write      : IN  STD_LOGIC;
        chipselect : IN  STD_LOGIC;
        writedata  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        byteenable : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        readdata   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Q_export   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END reg16_avalon_interface;

ARCHITECTURE Structure OF reg16_avalon_interface IS

    SIGNAL local_byteenable : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL to_reg, from_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);

    COMPONENT reg16
        PORT (
            clock      : IN  STD_LOGIC;
            resetn     : IN  STD_LOGIC;
            D          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            byteenable : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            Q          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

BEGIN

    -- Copier les données d'écriture
    to_reg <= writedata;

    -- Gérer le byteenable selon chipselect et write
    local_byteenable <= byteenable WHEN (chipselect = '1' AND write = '1') ELSE "00";

    -- Instanciation du registre
    reg_instance : reg16
        PORT MAP (
            clock      => clock,
            resetn     => resetn,
            D          => to_reg,
            byteenable => local_byteenable,
            Q          => from_reg
        );

    -- Assignation des sorties
    readdata <= from_reg;
    Q_export <= from_reg;

END Structure;