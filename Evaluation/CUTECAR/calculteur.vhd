library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calculateur is
  port(
    clk      : in  std_logic;
    reset_n  : in  std_logic;
    data_ir  : in  std_logic_vector(7 downto 0);
    data_jr  : in  std_logic_vector(7 downto 0);
    op_sel   : in  std_logic_vector(1 downto 0);
    result   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of calculateur is
  signal a_s, b_s : unsigned(7 downto 0);
  signal r_s      : unsigned(15 downto 0);
begin

  a_s <= unsigned(data_ir);
  b_s <= unsigned(data_jr);

  process(clk, reset_n)
  begin
    if reset_n = '0' then
      r_s <= (others => '0');

    elsif rising_edge(clk) then
      case op_sel is
        when "00" =>  -- addition
          r_s <= resize(a_s, 16) + resize(b_s, 16);

        when "01" =>  -- soustraction
          r_s <= resize(a_s, 16) - resize(b_s, 16);

        when "10" =>  -- amplification x2
          r_s <= shift_left(resize(a_s, 16), 1);

        when "11" =>  -- atténuation /2
          r_s <= shift_right(resize(a_s, 16), 1);

        when others =>
          r_s <= (others => '0');
      end case;
    end if;
  end process;

  result <= std_logic_vector(r_s);

end architecture;