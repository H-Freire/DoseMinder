library ieee;
use ieee.std_logic_1164.all;
use work.pill_package.CONTAINERS;

entity pill_dispenser_tb is
end entity;

architecture tb of pill_dispenser_tb is
  
    component pill_dispenser is
        port (
            clock     : in  std_logic;
            reset     : in  std_logic;
            db_switch : in  std_logic_vector(1 downto 0);
            echo      : in  std_logic;
            serial    : in  std_logic;
            pwm       : out std_logic_vector(CONTAINERS-1 downto 0);
            trigger   : out std_logic;
            alert     : out std_logic;
            -- debug
            db_reset   : out std_logic;
            db_pwm     : out std_logic;
            db_echo    : out std_logic;
            db_trigger : out std_logic;
            db_state       : out std_logic_vector(6 downto 0);
            db_measurement : out std_logic_vector(20 downto 0)
        );
    end component;
  
    signal clock_in         : std_logic := '0';
    signal reset_in         : std_logic := '0';
    signal db_switch_in     : std_logic_vector(1 downto 0) := "00";
    signal echo_in          : std_logic := '0';
    signal serial_in        : std_logic := '1';
    signal pwm_out          : std_logic_vector(CONTAINERS-1 downto 0) := (others => '0');
    signal trigger_out      : std_logic := '0';
    signal alert_out        : std_logic := '0';
    signal i                : integer := 0; -- iterable

  -- Configurações do clock
  constant clock_period  : time      := 20 ns;            -- 50MHz clock
  constant bit_period    : time      := 434*clock_period; -- 115.200 bauds
  signal keep_simulating : std_logic := '0';              -- limits the simulation
  
  -- Array de posicoes de teste
  type width_test_type is record
      id    : natural; 
      width : integer;     
  end record;

  -- 
    type width_test_array is array (natural range <>) of width_test_type;
    constant width_test : width_test_array :=
        ( 
            ( 1, 1200 ), -- 20cm (1200 us) 
            ( 2,  294 ), --  5cm ( 294 us)
            ( 3,  580 ), -- 10cm ( 580 us)
            ( 4,  235 ),  --  4cm ( 235 us)
            ( 5,  235 ),  --  4cm ( 235 us)
            ( 6,  235 )
        );

    signal case_id : natural := 0;

    procedure UART_WRITE_BYTE (
        data_in           : in  std_logic_vector(7 downto 0);
        signal serial_out : out std_logic
    ) is
    begin

        -- send start bit
        serial_out <= '0';
        wait for bit_period;

        -- envia 8 bits seriais
        for j in 0 to 7 loop
            serial_out <= data_in(j);
            wait for bit_period;
        end loop;

        -- envia 2 Stop Bits
        serial_out <= '1';
        wait for 2*bit_period;

    end UART_WRITE_BYTE;

begin

  clock_in <= (not clock_in) and keep_simulating after clock_period/2;

  i <= i+1 after 100000 * clock_period; -- 1500 us
  
  -- Conecta DUT (Device Under Test)
  DUT: pill_dispenser
        port map( 
            clock          => clock_in,
            reset          => reset_in,
            db_switch      => db_switch_in,
            echo           => echo_in,
            serial         => serial_in,
            pwm            => pwm_out,
            trigger        => trigger_out,
            alert          => alert_out,
            -- debug
            db_reset       => open,
            db_pwm         => open,
            db_echo        => open,
            db_trigger     => open,
            db_state       => open,
            db_measurement => open
        );

  -- geracao dos sinais de entrada (estimulos)
  STIMULUS: process is
  begin
  
    assert false report "Inicio das simulacoes" severity note;
    keep_simulating <= '1';

    ---- reset ----
    reset_in <= '1'; 
    wait for 2 us;
    reset_in <= '0';
    -- check that the system doesn't trigger anything without external stimulus 
    wait for 10 us;
    wait until falling_edge(clock_in);
    
    assert false report "Serial " & integer'image(width_test(i).id) severity note; --& integer'image(width_test(i).id)
    assert false report integer'image(i) severity note;
    -- serial entry for 6 pills
    UART_WRITE_BYTE (data_in => "01110110", serial_out => serial_in);
    serial_in <= '1';
    --wait for 10 us;
    
    ---- loop different widths
    while i < 5 loop
        case_id <= width_test(i).id;

        assert false report "Echo " & integer'image(case_id) & " " & integer'image(width_test(i).width) severity note;
        -- wait for trigger
        
        -- wait for 400us (estimated time between trigger and echo)
        wait for 400 us;
        
        -- generate echo pulse
        echo_in <= '1';
        wait for width_test(i).width * 1 us;
        echo_in <= '0';
        
        --wait for 100 us;
        wait until (falling_edge(trigger_out));
    end loop;

    -- tests termination
    assert false report "End of simulation" severity note;
    keep_simulating <= '0';
    
    wait; -- simu end: awaits indefinitely
  end process;

end architecture;