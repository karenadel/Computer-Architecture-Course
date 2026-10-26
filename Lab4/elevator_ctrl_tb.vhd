library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elevator_ctrl_tb is
end elevator_ctrl_tb;

architecture arch_ctrl_tb of elevator_ctrl_tb is
    component elevator_ctrl
        generic(
            N_FLOORS : positive := 10;
            CLK_DIV : positive := 50_000_000
        );
        port(
            clk : in  std_logic;
            rst : in  std_logic;
            floorNum : in  std_logic_vector(3 downto 0);
            key : in  std_logic;
            mv_up : out std_logic;
            mv_dn : out std_logic;
            door_open : out std_logic;
            floor : out std_logic_vector(3 downto 0);
            floor_ssd : out std_logic_vector(6 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 20 ns;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal floorNum : std_logic_vector(3 downto 0) := (others => '0');
    signal key : std_logic := '1';
    signal mv_up : std_logic;
    signal mv_dn : std_logic;
    signal door_open : std_logic;
    signal floor : std_logic_vector(3 downto 0);
    signal floor_ssd : std_logic_vector(6 downto 0);
    signal done : boolean := false;
begin
    clk <= not clk after CLK_PERIOD/2 when not done else '0';

    uut : elevator_ctrl
        generic map(
            N_FLOORS => 10,
            CLK_DIV  => 4
        )
        port map(
            clk => clk,
            rst => rst,
            floorNum => floorNum,
            key => key,
            mv_up => mv_up,
            mv_dn => mv_dn,
            door_open => door_open,
            floor => floor,
            floor_ssd => floor_ssd
        );

    process(mv_up, mv_dn, door_open)
    begin
        assert not (door_open = '1' and (mv_up = '1' or mv_dn = '1'))
            report "Door open while elevator moving"
            severity error;
        assert not (mv_up = '1' and mv_dn = '1')
            report "mv_up and mv_dn high at the same time"
            severity error;
    end process;

    process
    begin
        --idle state test
        rst <= '0';
        wait for 100 ns;
        assert to_integer(unsigned(floor)) = 0 and mv_up = '0' and mv_dn = '0' and door_open = '0'
            report "Reset failed"
            severity error;

        --request current floor while idle
        rst <= '1';
        wait for 100 ns;
        floorNum <= (others => '0');
        key <= '0';
        wait for 100 ns;
        key <= '1';
        if door_open = '0' then
            wait until door_open = '1' for 1 us;
        end if;
        assert door_open = '1'
            report "request current floor while idle failed"
            severity error;

        --request floor above current
        floorNum <= "0011";
        wait for 100 ns;
        key <= '0';
        wait for 100 ns;
        key <= '1';
        wait for 200 ns;
        assert mv_up = '1'
            report "Elevator did not move up"
            severity error;
        wait until to_integer(unsigned(floor)) = 3 for 2 us;
        assert to_integer(unsigned(floor)) = 3
            report "Elevator did not reach floor 3"
            severity error;
        wait for 100 ns;
        assert door_open = '1'
            report "Door did not open at floor 3"
            severity error;

        --Request a lower floor
        floorNum <= "0001";
        wait for 100 ns;
        key <= '0';
        wait for 100 ns;
        key <= '1';
        wait for 200 ns;
        assert mv_dn = '1'
            report "Elevator did not move down"
            severity error;
        wait until to_integer(unsigned(floor)) = 1 for 2 us;
        assert to_integer(unsigned(floor)) = 1
            report "Elevator did not reach floor 1"
            severity error;
        wait for 100 ns;
        assert door_open = '1'
            report "Door did not open at floor 1"
            severity error;

        --Multiple requests
        floorNum <= "0011";
        wait for 100 ns;
        key <= '0';
        wait for 100 ns;
        key <= '1';
        wait for 100 ns;
        floorNum <= "0101";
        wait for 100 ns;
        key <= '0';
        wait for 100 ns;
        key <= '1';
        wait until to_integer(unsigned(floor)) = 3 for 2 us;
        assert to_integer(unsigned(floor)) = 3
            report "Elevator did not reach floor 3"
            severity error;
        wait until to_integer(unsigned(floor)) = 5 for 2 us;
        assert to_integer(unsigned(floor)) = 5
            report "Elevator did not reach floor 5"
            severity error;

        --Request top floor (floor 9)
        floorNum <= "1001";
        wait for 100 ns;
        key <= '0';
        wait for 100 ns;
        key <= '1';
        wait until to_integer(unsigned(floor)) = 9 for 5 us;
        assert to_integer(unsigned(floor)) = 9
            report "Elevator did not reach top floor"
            severity error;
        assert mv_up = '0'
            report "Elevator still moving up at top floor"
            severity error;

        --Request lower floor (floor 0)
        floorNum <= "0000";
        wait for 100 ns;
        key <= '0';
        wait for 100 ns;
        key <= '1';
        wait until to_integer(unsigned(floor)) = 0 for 5 us;
        assert to_integer(unsigned(floor)) = 0
            report "Elevator did not return to floor 0"
            severity error;
        assert mv_dn = '0'
            report "Elevator still moving down at floor 0"
            severity error;

        --Reset while moving
        floorNum <= "0101";
        wait for 100 ns;
        key <= '0';
        wait for 100 ns;
        key <= '1';
        wait until to_integer(unsigned(floor)) = 2 for 2 us;
        assert mv_up = '1'
            report "Elevator was not moving before reset"
            severity error;
        rst <= '0';
        wait for 20 ns;
        assert to_integer(unsigned(floor)) = 0
            report "Floor did not reset to 0"
            severity error;
        assert mv_up = '0' and mv_dn = '0'
            report "Movement outputs not cleared by reset"
            severity error;
        assert door_open = '0'
            report "Door output not cleared by reset"
            severity error;

        --Invalid floor request
        rst <= '1';
        wait for 100 ns;
        floorNum <= "1100";
        wait for 100 ns;
        key <= '0';
        wait for 100 ns;
        key <= '1';
        wait for 200 ns;
        assert to_integer(unsigned(floor)) < 10
            report "Elevator entered an invalid floor"
            severity error;
        assert mv_up = '0' and mv_dn = '0' and door_open = '0'
            report "Elevator reacted to an invalid floor request"
            severity error;

        report "Testbench finished";
        done <= true;
        wait;
    end process;
end arch_ctrl_tb;