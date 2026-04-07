library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CTL_Rot is
  generic(
    Rotspeed_hex : std_logic_vector(11 downto 0) := x"800";
    POSI_STOP    : std_logic_vector(6 downto 0)  := "0001000"  -- unused, kept
  );
  port (
    clk        : in  std_logic;   -- CLOCK_50
    reset_n    : in  std_logic;

    start_Rot  : in  std_logic;
    dir_Rot    : in  std_logic;

    posi       : in  std_logic_vector(6 downto 0);  -- async (clk40)
    data_ready : in  std_logic;                     -- async (clk40)

    cmdL_rot   : out std_logic_vector(13 downto 0);
    cmdR_rot   : out std_logic_vector(13 downto 0);

    fin_rot    : out std_logic
  );
end entity;

architecture rtl of CTL_Rot is

  type state_t is (IDLE, ROTATE, DONE);
  signal state : state_t := IDLE;

  -- sync data_ready
  signal dr_ff1, dr_ff2 : std_logic := '0';
  signal dr_prev        : std_logic := '0';

  -- latched sample (for debug / stability)
  signal posi_lat : std_logic_vector(6 downto 0) := (others => '0');

  -- hold fin_rot until start_Rot drops
  signal fin_rot_r : std_logic := '0';

  -- detect start_Rot rising edge (re-arm)
  signal sr_prev : std_logic := '0';

  function mk_cmd(go, dir : std_logic; duty12 : std_logic_vector(11 downto 0))
    return std_logic_vector is
    variable v : std_logic_vector(13 downto 0);
  begin
    v := (others => '0');
    v(13) := go;
    v(12) := dir;
    v(11 downto 0) := duty12;
    return v;
  end function;

  function is_centered(v : std_logic_vector(6 downto 0)) return boolean is
  begin
    return v(3) = '1';  -- centered if center sensor is 1
  end function;

begin
  fin_rot <= fin_rot_r;

  process(clk, reset_n)
    variable dr_rise   : boolean;
    variable sr_rise   : boolean;
    variable sample    : std_logic_vector(6 downto 0);
  begin
    if reset_n = '0' then
      state     <= IDLE;
      fin_rot_r <= '0';
      cmdL_rot  <= mk_cmd('0','0',x"000");
      cmdR_rot  <= mk_cmd('0','0',x"000");

      dr_ff1    <= '0';
      dr_ff2    <= '0';
      dr_prev   <= '0';

      sr_prev   <= '0';
      posi_lat  <= (others => '0');

    elsif rising_edge(clk) then

      -- sync data_ready
      dr_ff1 <= data_ready;
      dr_ff2 <= dr_ff1;
      dr_rise := (dr_ff2 = '1') and (dr_prev = '0');
      dr_prev <= dr_ff2;

      -- detect start_Rot rising edge (re-arm)
      sr_rise := (start_Rot = '1') and (sr_prev = '0');
      sr_prev <= start_Rot;

      -- default
      if start_Rot = '0' then
        fin_rot_r <= '0';
      end if;

      -- latch sample when new data arrives (use variable for immediate use)
      sample := posi_lat;
      if dr_rise then
        sample := posi;     -- capture current posi at ready pulse
        posi_lat <= sample; -- store for later/debug
      end if;

      -- re-arm if new start arrives
      if sr_rise then
        state     <= ROTATE;
        fin_rot_r <= '0';
      end if;

      case state is

        when IDLE =>
          cmdL_rot <= mk_cmd('0','0',x"000");
          cmdR_rot <= mk_cmd('0','0',x"000");
          fin_rot_r <= '0';
          if start_Rot = '1' then
            state <= ROTATE;
          end if;

        when ROTATE =>
          -- drive rotation continuously
          if dir_Rot = '0' then
            cmdL_rot <= mk_cmd('1','1', Rotspeed_hex);
            cmdR_rot <= mk_cmd('1','0', Rotspeed_hex);
          else
            cmdL_rot <= mk_cmd('1','0', Rotspeed_hex);
            cmdR_rot <= mk_cmd('1','1', Rotspeed_hex);
          end if;

          -- stop decision only on a new sample (CDC-safe)
          if dr_rise and is_centered(sample) then
            cmdL_rot <= mk_cmd('0','0',x"000");
            cmdR_rot <= mk_cmd('0','0',x"000");
            state <= DONE;
          end if;

          if start_Rot = '0' then
            state <= IDLE;
          end if;

        when DONE =>
          -- hold fin_rot high until start_Rot drops (handshake)
          fin_rot_r <= '1';
          cmdL_rot  <= mk_cmd('0','0',x"000");
          cmdR_rot  <= mk_cmd('0','0',x"000");
          if start_Rot = '0' then
            fin_rot_r <= '0';
            state <= IDLE;
          end if;

      end case;
    end if;
  end process;

end architecture;