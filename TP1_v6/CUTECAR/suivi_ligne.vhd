library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity suivi_ligne is
    port(
        clk            : in  std_logic;
        reset_n        : in  std_logic;
        start_SL       : in  std_logic;
        POSL           : in  signed(3 downto 0);
        ligne_presente : in  std_logic;
        pwm_droit      : out std_logic_vector(13 downto 0);
        pwm_gauche     : out std_logic_vector(13 downto 0);
        fin_SL         : out std_logic
    );
end entity;

architecture rtl of suivi_ligne is

    constant PWM_CONST       : integer := 10210;
    constant GAIN_BIAS       : integer := 120;

    constant PWM_SEARCH_FAST : integer := 10210;
    constant PWM_SEARCH_SLOW : integer := 0;

    -- Exemple pour clk = 50 MHz : 0,15 s
    constant SEARCH_MIN_TICKS : integer := 7500000;

    signal pwm_d_i : integer range 0 to 10210 := 0;
    signal pwm_g_i : integer range 0 to 10210 := 0;

    signal last_pos_s      : integer range -7 to 7 := 0;
    signal search_mode_s   : std_logic := '0';
    signal search_count_s  : integer range 0 to SEARCH_MIN_TICKS := 0;

begin

    process(clk, reset_n)
        variable pos_i  : integer;
        variable bias_v : integer;
        variable pd_v   : integer;
        variable pg_v   : integer;
    begin
        if reset_n = '0' then
            pwm_d_i        <= 0;
            pwm_g_i        <= 0;
            fin_SL         <= '0';
            last_pos_s     <= 0;
            search_mode_s  <= '0';
            search_count_s <= 0;

        elsif rising_edge(clk) then
            if start_SL = '0' then
                pwm_d_i        <= 0;
                pwm_g_i        <= 0;
                fin_SL         <= '0';
                last_pos_s     <= 0;
                search_mode_s  <= '0';
                search_count_s <= 0;

            else
                fin_SL <= '0';

                -- entrée en mode recherche dès que la ligne est perdue
                if (search_mode_s = '0') and (ligne_presente = '0') then
                    search_mode_s  <= '1';
                    search_count_s <= 0;
                end if;

                -- gestion du mode recherche
                if search_mode_s = '1' then
                    -- le compteur continue même si la ligne revient
                    if search_count_s < SEARCH_MIN_TICKS then
                        search_count_s <= search_count_s + 1;
                    end if;

                    -- on quitte la recherche seulement si :
                    -- 1) le temps minimal est écoulé
                    -- 2) la ligne est détectée
                    if (search_count_s >= SEARCH_MIN_TICKS) and (ligne_presente = '1') then
                        search_mode_s  <= '0';
                        search_count_s <= 0;
                    end if;
                end if;

                -- commande moteurs
                if search_mode_s = '1' then
                    -- rotation/recherche prioritaire
                    if last_pos_s < 0 then
                        -- dernière ligne vue à gauche
                        pwm_d_i <= PWM_SEARCH_FAST;
                        pwm_g_i <= PWM_SEARCH_SLOW;
                    elsif last_pos_s > 0 then
                        -- dernière ligne vue à droite
                        pwm_d_i <= PWM_SEARCH_SLOW;
                        pwm_g_i <= PWM_SEARCH_FAST;
                    else
                        -- cas neutre
                        pwm_d_i <= PWM_SEARCH_SLOW;
                        pwm_g_i <= PWM_SEARCH_FAST;
                    end if;

                else
                    -- suivi normal dès que la ligne est retrouvée
                    pos_i := to_integer(POSL);

                    if pos_i < -7 then
                        last_pos_s <= -7;
                    elsif pos_i > 7 then
                        last_pos_s <= 7;
                    else
                        last_pos_s <= pos_i;
                    end if;

                    bias_v := pos_i * GAIN_BIAS;

                    pd_v := PWM_CONST - bias_v;
                    pg_v := PWM_CONST + bias_v;

                    if pd_v < 0 then
                        pd_v := 0;
                    elsif pd_v > 10210 then
                        pd_v := 10210;
                    end if;

                    if pg_v < 0 then
                        pg_v := 0;
                    elsif pg_v > 10210 then
                        pg_v := 10210;
                    end if;

                    pwm_d_i <= pd_v;
                    pwm_g_i <= pg_v;
                end if;
            end if;
        end if;
    end process;

    pwm_droit  <= std_logic_vector(to_unsigned(pwm_d_i, 14));
    pwm_gauche <= std_logic_vector(to_unsigned(pwm_g_i, 14));

end architecture;