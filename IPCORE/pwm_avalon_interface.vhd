library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM_avalon_interface is
    port (
        clock       : in  std_logic;
        resetn      : in  std_logic;

        -- Avalon-MM slave
        address     : in  std_logic_vector(0 downto 0);
        write       : in  std_logic;
        read        : in  std_logic;
        chipselect  : in  std_logic;
        byteenable  : in  std_logic_vector(1 downto 0);
        writedata   : in  std_logic_vector(15 downto 0);
        readdata    : out std_logic_vector(15 downto 0);

        -- Conduit vers l'extérieur
        dc_motor_p_R : out std_logic;
        dc_motor_n_R : out std_logic;
        dc_motor_p_L : out std_logic;
        dc_motor_n_L : out std_logic
    );
end entity;

architecture Structure of PWM_avalon_interface is

    signal cmd_R : std_logic_vector(15 downto 0) := (others => '0');
    signal cmd_L : std_logic_vector(15 downto 0) := (others => '0');

    component PWM_generation is
        port (
            clk             : in  std_logic;
            reset_n         : in  std_logic;
            s_writedataR    : in  std_logic_vector(15 downto 0);
            s_writedataL    : in  std_logic_vector(15 downto 0);
            dc_motor_p_R    : out std_logic;
            dc_motor_n_R    : out std_logic;
            dc_motor_p_L    : out std_logic;
            dc_motor_n_L    : out std_logic
        );
    end component;

begin

    process(clock)
    begin
        if rising_edge(clock) then
            if resetn = '0' then
                cmd_R <= (others => '0');
                cmd_L <= (others => '0');
            else
                if chipselect = '1' and write = '1' then
                    if address = "0" then
                        if byteenable(0) = '1' then
                            cmd_R(7 downto 0) <= writedata(7 downto 0);
                        end if;
                        if byteenable(1) = '1' then
                            cmd_R(15 downto 8) <= writedata(15 downto 8);
                        end if;
                    else
                        if byteenable(0) = '1' then
                            cmd_L(7 downto 0) <= writedata(7 downto 0);
                        end if;
                        if byteenable(1) = '1' then
                            cmd_L(15 downto 8) <= writedata(15 downto 8);
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    with address select
        readdata <= cmd_R when "0",
                    cmd_L when others;

    U_PWM : PWM_generation
        port map (
            clk          => clock,
            reset_n      => resetn,
            s_writedataR => cmd_R,
            s_writedataL => cmd_L,
            dc_motor_p_R => dc_motor_p_R,
            dc_motor_n_R => dc_motor_n_R,
            dc_motor_p_L => dc_motor_p_L,
            dc_motor_n_L => dc_motor_n_L
        );

end architecture;