library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity POS is
    port(
        vect_capt      : in  std_logic_vector(6 downto 0);
        POSL           : out signed(3 downto 0);
        ligne_presente : out std_logic
    );
end entity;

architecture combinatoire of POS is
begin

    process(vect_capt)
    begin
        -- prÃ©sence ou absence de ligne
        if vect_capt = "0000000" then
            ligne_presente <= '0';
        else
            ligne_presente <= '1';
        end if;

        -- position de la ligne
        case vect_capt is
            -- centre
            when "0001000" => POSL <= to_signed( 0, 4);

            -- gauche
            when "0011000" => POSL <= to_signed(-1, 4);
            when "0010000" => POSL <= to_signed(-2, 4);
            when "0110000" => POSL <= to_signed(-3, 4);
            when "0100000" => POSL <= to_signed(-4, 4);
            when "1100000" => POSL <= to_signed(-5, 4);
            when "1000000" => POSL <= to_signed(-6, 4);

            -- droite
            when "0001100" => POSL <= to_signed( 1, 4);
            when "0000100" => POSL <= to_signed( 2, 4);
            when "0000110" => POSL <= to_signed( 3, 4);
            when "0000010" => POSL <= to_signed( 4, 4);
            when "0000011" => POSL <= to_signed( 5, 4);
            when "0000001" => POSL <= to_signed( 6, 4);

            when others =>
                POSL <= to_signed(0, 4);
        end case;
    end process;

end architecture;