library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CTL_SL is
  generic(
    BIAS : natural := 15
  );
  port (
    clk        : in  std_logic;
    reset_n    : in  std_logic;

    start_SL   : in  std_logic;
    posi       : in  std_logic_vector(6 downto 0);

    base_duty  : in  std_logic_vector(13 downto 0);

    data_ready : in  std_logic;  -- <-- NEW: only update on new ADC data

    cmdL_SL    : out std_logic_vector(13 downto 0);
    cmdR_SL    : out std_logic_vector(13 downto 0);

    fin_SL     : out std_logic
  );
end entity;

architecture rtl of CTL_SL is

  function clamp12(x : integer) return unsigned is
    variable y : integer := x;
  begin
    if y < 0 then y := 0; end if;
    if y > 4095 then y := 4095; end if;
    return to_unsigned(y, 12);
  end function;

  function pack_cmd(go_i : std_logic; dir_i : std_logic; duty12 : unsigned(11 downto 0))
    return std_logic_vector is
    variable v : std_logic_vector(13 downto 0) := (others => '0');
  begin
    v(13) := go_i;
    v(12) := dir_i;
    v(11 downto 0) := std_logic_vector(duty12);
    return v;
  end function;

  function compute_err(v : std_logic_vector(6 downto 0)) return integer is
    variable sum_w : integer := 0;
    variable cnt   : integer := 0;
  begin
    -- v(6)=left ... v(0)=right
    if v(6)='1' then sum_w := sum_w + (-3); cnt := cnt + 1; end if;
    if v(5)='1' then sum_w := sum_w + (-2); cnt := cnt + 1; end if;
    if v(4)='1' then sum_w := sum_w + (-1); cnt := cnt + 1; end if;
    if v(3)='1' then sum_w := sum_w + ( 0); cnt := cnt + 1; end if;
    if v(2)='1' then sum_w := sum_w + ( 1); cnt := cnt + 1; end if;
    if v(1)='1' then sum_w := sum_w + ( 2); cnt := cnt + 1; end if;
    if v(0)='1' then sum_w := sum_w + ( 3); cnt := cnt + 1; end if;

    if cnt = 0 then
      return 0;
    else
      return sum_w; -- keep your behavior
    end if;
  end function;

  signal dr_d : std_logic := '0';  -- for rising-edge detect

begin

  process(clk, reset_n)
    variable base_i  : integer;
    variable err_i   : integer;
    variable dutyL_i : integer;
    variable dutyR_i : integer;
    variable line_ok : boolean;
    variable dr_rise : boolean;
  begin
    if reset_n = '0' then
      cmdL_SL <= pack_cmd('0','0', to_unsigned(0,12));
      cmdR_SL <= pack_cmd('0','0', to_unsigned(0,12));
      fin_SL  <= '0';
      dr_d    <= '0';

    elsif rising_edge(clk) then
      -- rising edge detect on data_ready
      dr_rise := (data_ready = '1') and (dr_d = '0');
      dr_d    <= data_ready;

      -- default: keep previous outputs unless we update on dr_rise or start_SL changes
      if start_SL = '0' then
        cmdL_SL <= pack_cmd('0','0', to_unsigned(0,12));
        cmdR_SL <= pack_cmd('0','0', to_unsigned(0,12));
        fin_SL  <= '0';

      else
        -- Only compute/update on a new valid ADC frame
        if dr_rise then
          base_i  := to_integer(unsigned(base_duty(11 downto 0)));
          line_ok := (posi /= "0000000");

          if not line_ok then
            cmdL_SL <= pack_cmd('0','0', to_unsigned(0,12));
            cmdR_SL <= pack_cmd('0','0', to_unsigned(0,12));
            fin_SL  <= '1';
          else
            err_i   := compute_err(posi);
            dutyR_i := base_i - (integer(BIAS) * err_i);
            dutyL_i := base_i + (integer(BIAS) * err_i);

            cmdL_SL <= pack_cmd('1','0', clamp12(dutyL_i));
            cmdR_SL <= pack_cmd('1','0', clamp12(dutyR_i));
            fin_SL  <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture;