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

    constant PWM_CONST : integer := 10210; -- 0x29C4
    constant GAIN_BIAS : integer := 120;

    signal pwm_d_i : integer range 0 to 10210  := 0;
    signal pwm_g_i : integer range 0 to 10210  := 0;

begin

    process(clk, reset_n)
        variable pos_i  : integer;
        variable bias_v : integer;
        variable pd_v   : integer;
        variable pg_v   : integer;
    begin
        if reset_n = '0' then
            pwm_d_i <= 0;
            pwm_g_i <= 0;
            fin_SL  <= '0';

        elsif rising_edge(clk) then

            if start_SL = '0' then
                pwm_d_i <= 0;
                pwm_g_i <= 0;
                fin_SL  <= '0';

            else
                if ligne_presente = '0' then
                    pwm_d_i <= 0;
                    pwm_g_i <= 0;
                    fin_SL  <= '1';
                else
                    fin_SL <= '0';

                    pos_i  := to_integer(POSL);
                    bias_v := pos_i * GAIN_BIAS;

                   pd_v := PWM_CONST - bias_v;
						 pg_v := PWM_CONST + bias_v;

                    if pd_v < 0 then
                        pd_v := 0;
                    elsif pd_v > 10480 then
                        pd_v := 10480;
                    end if;

                    if pg_v < 0 then
                        pg_v := 0;
                    elsif pg_v > 10480 then
                        pg_v := 10480;
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