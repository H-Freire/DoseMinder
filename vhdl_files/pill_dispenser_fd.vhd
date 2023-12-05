library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.math_real.all;
use work.pill_package.all;

entity pill_dispenser_fd is
    port (
        clock      : in  std_logic;
        reset      : in  std_logic;
        serial     : in  std_logic;
        echo       : in  std_logic;
        count      : in  std_logic;
        move       : in  std_logic;
        discount   : in  std_logic;
        -- outputs
        trigger    : out std_logic;
        check_end  : out std_logic;
        safety_end : out std_logic;
        pwm        : out std_logic_vector(CONTAINERS-1 downto 0);
        alert      : out std_logic; -- system is active and alert
        detected   : out std_logic; -- system can dispense pill 
        -- debug
        db_measurement : out std_logic_vector(11 downto 0);
        -- states
        rx_state     : out std_logic_vector(3 downto 0);
        sensor_state : out std_logic_vector(3 downto 0)
    );
end entity;

architecture df_arch of pill_dispenser_fd is

    constant pwm_period : natural := 1_000_000;

    -- 2 seconds timer [100_000_000 (2s)/ 1_000_000] (real/simu)
    constant check_timeout       : natural := 100_000_000;
    constant check_timeout_bits  : natural := natural(ceil(log2(real(check_timeout))));
    
    -- 500 milliseconds delay [40_000_000 / 250_000] (real/simu)
    constant safety_timeout      : natural := 40_000_000;
    constant safety_timeout_bits : natural := natural(ceil(log2(real(safety_timeout))));

    -- dosage and containers
    signal s_dosage          : std_logic_vector(6 downto 0);
    signal containers_enable : std_logic_vector(containers_range);
    signal pill_containers   : pill_count;

    -- distance measurement
    signal s_measurement : std_logic_vector(11 downto 0);
    signal meas_cm       : integer ;

    -- auxiliary signals
    signal s_pwm, s_count_reset, s_rx_received, s_alert, s_close, s_meas_ready : std_logic;
    signal s_width : std_logic_vector(1 downto 0);

begin

    s_count_reset <= not count;
    s_width       <= "11" when move='1' else "01";

    PWM_CIRCUIT: circuito_pwm
        generic map (
            conf_periodo => pwm_period, 
            largura_00   => 0,
            largura_01   => 30_000, -- 300
            largura_10   => 0,
            largura_11   => 80_000  -- 800
        )
        port map (
            clock   => clock,
            reset   => reset,
            largura => s_width,  
            pwm     => s_pwm
        );

    RX: rx_serial_7O1
        port map (
            clock             => clock,
            reset             => reset,
            dado_serial       => serial,
            dado_recebido     => s_dosage,
            paridade_recebida => open,
            pronto            => s_rx_received,
            db_dado_serial    => open,
            db_estado         => rx_state
        );

    HCSR04: interface_hcsr04
        port map (
            clock     => clock,
            reset     => reset,
            medir     => s_alert, -- ended serial reception. waiting to dispense all medication
            echo      => echo,
            trigger   => trigger,
            medida    => s_measurement,
            pronto    => s_meas_ready, -- ended one measurement: compare
            db_reset  => open, 
            db_medir  => open,
            db_estado => sensor_state
        );

    CHECK_TIMER: contador_m
        generic map (M => check_timeout, N => check_timeout_bits)
        port map (
            clock => clock,
            zera  => s_count_reset,
            conta => count,
            Q     => open,
            fim   => check_end,
            meio  => open
        );

    SAFETY_TIMER: contador_m
        generic map (M => safety_timeout, N => safety_timeout_bits)
        port map (
            clock => clock,
            zera  => s_count_reset,
            conta => count,
            Q     => open,
            fim   => safety_end,
            meio  => open
        );

    -- 4 bits to identify the container (6 downto 3) and
    -- the 3 least significant bits to indicate the proper dosage of the container (2 downto 0)
    CONTAINERS: for i in pill_containers'range generate
        containers_enable(i) <= '1' when i = to_integer(unsigned(s_dosage(6 downto 3))) and s_rx_received='1' else '0';
        pwm(i) <= '0' when pill_containers(i) = "000" else s_pwm;

        PILL_COUNT: downwards_counter
            generic map (N => 3)
            port map (
                clock  => clock,
                clear  => reset,
                count  => discount,  
                enable => containers_enable(i),
                D      => s_dosage(2 downto 0),
                Q      => pill_containers(i)
            );
    end generate;

    s_alert <= '0' when pill_containers = (pill_containers'range => (others => '0')) else '1'; 

    -- compare distance measurement to minimum of 6 cm
    meas_cm <= to_integer(unsigned(s_measurement));
    s_close <= '1' when (0 < meas_cm and 10 > meas_cm) else '0';
    
    detected       <= s_alert and s_close;
    alert          <= s_alert;
    db_measurement <= s_measurement;

end architecture;