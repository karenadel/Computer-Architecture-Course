library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elevator_ctrl_tb is
end elevator_ctrl_tb;

architecture arch_ctrl_tb of elevator_ctrl_tb is
    component elevator_ctrl
        generic(
            N_FLOORS : positive := 10;
            CLK_DIV  : positive := 50_000_000
        );
        port(
            clk       : in  std_logic;
            rst       : in  std_logic;
            floorNum  : in  std_logic_vector(3 downto 0);
            key       : in  std_logic;
            mv_up     : out std_logic;
            mv_dn     : out std_logic;
            door_open : out std_logic;
            floor     : out std_logic_vector(3 downto 0);
            floor_ssd : out std_logic_vector(6 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 20 ns;

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal floorNum  : std_logic_vector(3 downto 0) := (others => '0');
    signal key       : std_logic := '1';
    signal mv_up     : std_logic;
    signal mv_dn     : std_logic;
    signal door_open : std_logic;
    signal floor     : std_logic_vector(3 downto 0);
    signal floor_ssd : std_logic_vector(6 downto 0);
begin
    clk <= not clk after CLK_PERIOD/2;

    uut : elevator_ctrl
        generic map(
            N_FLOORS => 10,
            CLK_DIV  => 50_000_000
        )
        port map(
            clk       => clk,
            rst       => rst,
            floorNum  => floorNum,
            key       => key,
            mv_up     => mv_up,
            mv_dn     => mv_dn,
            door_open => door_open,
            floor     => floor,
            floor_ssd => floor_ssd
        );

        process
        begin
            
    -- process
    -- begin
    --     rst <= '0';
    --     wait for 100 ns;
    --     rst <= '1';
    --     wait for 100 ns;

    --     -- Request to go to floor 3
    --     floorNum <= "0011";
    --     key <= '0';
    --     wait for 20 ns;
    --     key <= '1';
    --     wait for 5 sec;

    --     -- Request to go to floor 7
    --     floorNum <= "0111";
    --     key <= '0';
    --     wait for 20 ns;
    --     key <= '1';
    --     wait for 5 sec;