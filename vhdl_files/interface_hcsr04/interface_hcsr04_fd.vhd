-------------------------------------------------------------------
-- Arquivo   : interface_hcsr04.vhd
-- Projeto   : Experiencia 3 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito de interface com
--             sensor de distancia
--             
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor                            Descricao
--     16/09/2023  1.0     Mariana Dutra e Henrique Silva   versao inicial
--
--------------------------------------------------------------------
--

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.math_real.all;


entity interface_hcsr04_fd is
    port (
        clock     : in  std_logic;
        reset     : in  std_logic;
        gera      : in  std_logic;
        pulso     : in  std_logic;
        registra  : in  std_logic;
        zera      : in  std_logic;
        trigger   : out std_logic;
        fim_medida: out std_logic;
        distancia : out std_logic_vector(11 downto 0); -- 3 digitos BCD
        delay     : out std_logic; -- delay between echo and new trigger
        timeout   : out std_logic;
        db_tick   : out std_logic
    );
end entity interface_hcsr04_fd;

architecture fd_arch of interface_hcsr04_fd is

    component contador_cm 
        generic (
            constant R : integer;
            constant N : integer
        );
        port (
            clock   : in  std_logic;
            reset   : in  std_logic;
            pulso   : in  std_logic;
            digito0 : out std_logic_vector(3 downto 0);
            digito1 : out std_logic_vector(3 downto 0);
            digito2 : out std_logic_vector(3 downto 0);
            fim     : out std_logic;
            pronto  : out std_logic;
            db_tick : out std_logic
        );
    end component;

    component registrador_n
        generic (
            constant N: integer
        );
        port (
            clock   : in std_logic;
            clear   : in std_logic;
            enable  : in std_logic;
            D       : in std_logic_vector(N-1 downto 0);
            Q       : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component gerador_pulso
        generic (
            largura: integer
       );
       port(
            clock  : in  std_logic;
            reset  : in  std_logic;
            gera   : in  std_logic;
            para   : in  std_logic;
            pulso  : out std_logic;
            pronto : out std_logic
       );
    end component;

    component contador_m 
        generic (
            constant M : integer;  
            constant N : integer 
        );
        port (
            clock : in  std_logic;
            zera  : in  std_logic;
            conta : in  std_logic;
            Q     : out std_logic_vector (N-1 downto 0);
            fim   : out std_logic;
            meio  : out std_logic
        );
    end component;

    -- sinais
    signal s_conta, s_tick, s_zera, s_zera_delay, s_delay : std_logic;
    signal s_distancia_in : std_logic_vector(11 downto 0);
    signal s_digito0, s_digito1, s_digito2 : std_logic_vector(3 downto 0);

    -- saidas
    signal s_fim_medida, s_trigger : std_logic;
    signal s_distancia_out : std_logic_vector(11 downto 0);

    -- timeout
    signal s_timeout : std_logic;
    constant check_timeout      : natural := 25_000_000; -- 0.5 segundo
    constant check_timeout_bits : natural := natural(ceil(log2(real(check_timeout))));

begin
    -- concatena
    s_distancia_in <= s_digito2 & s_digito1 & s_digito0;

    s_zera <= zera or reset;

    CCM: contador_cm
        generic map (
            R => 2941,
            N => 12
        )
        port map (
            clock   => clock,
            reset   => zera,
            pulso   => pulso,
            digito0 => s_digito0,
            digito1 => s_digito1,
            digito2 => s_digito2,
            fim     => open,
            pronto  => s_fim_medida,
            db_tick => s_tick
        );
 
    REG: registrador_n 
        generic map (
            N => 12
        )
        port map (
            clock   => clock,
            clear   => reset, 
            enable  => registra,
            D       => s_distancia_in,
            Q       => s_distancia_out
        );

    ECHO: gerador_pulso
        generic map (
            largura => 500
        )
        port map (
            clock  => clock,
            reset  => zera,
            gera   => gera,
            para   => '0',
            pulso  => s_trigger,
            pronto => open
        );
    
    -- timeout para enviar outro trigger caso não venha um echo
    TIMER: contador_m 
        generic map (
            M => check_timeout,
            N => check_timeout_bits 
        )
        port map (
            clock => clock,
            zera  => zera,
            conta => s_zera_delay,
            Q     => open,
            fim   => s_timeout,
            meio  => open
        );

    s_zera_delay <= not zera;
    s_conta <= zera and not s_delay;

    DELAY_TIMER: contador_m -- delay between echo and new trigger
        generic map (M => 25_000_000, N => 25)
        port map (
            clock => clock,
            zera  => s_zera_delay,
            conta => s_conta,
            Q     => open,
            fim   => s_delay,
            meio  => open
        );

    fim_medida  <= s_fim_medida;
    trigger     <= s_trigger;
    distancia   <= s_distancia_out;
    delay       <= s_delay;
    timeout     <= s_timeout;
    db_tick     <= s_tick;

end architecture fd_arch;
   