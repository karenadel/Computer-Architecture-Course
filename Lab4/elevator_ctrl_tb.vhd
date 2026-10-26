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
begin
    clk <= not clk after CLK_PERIOD/2;

    uut : elevator_ctrl
        generic map(
            N_FLOORS => 10,
            CLK_DIV  => 50_000_000
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

        process
        begin
            --idle state test
            rst <= '0';
            wait for 100 ns;
            Assert (state = doorClosed and timer = 0 and dir = '1' and floor_reg = 0 and mv_up='0' and mv_dn='0' and door_open='0') 
            report "Reset failed" 
            severity error;
            
            --request current floor while idle
            rst<='1';
            wait for 100 ns;
            floorNum<=(others=>'0');
            key<='0';
            wait for 100 ns;
            key <= '1';       
            wait for 200 ns;
            Assert state = doorOpen
            report "request current floor while idle failed" 
            severity error;

            --request floor above current
            floorNum<="0011";
            key<='0';
            wait for 100 ns;
            key <= '1';      
            wait for 100 ns;
            assert mv_up = '1'
                report "Elevator did not move up"
                severity error;
            wait for 240 ns;
            assert unsigned(floor) = 3
                report "Elevator did not reach floor 3"
                severity error;
            wait for 100 ns;
            assert door_open = '1'
                report "Door did not open at floor 3"
                severity error;

            --Request a lower floor
            floorNum <= "0001";
            key <= '0';
            wait for 100 ns;
            key <= '1';
            wait for 100 ns;
            assert mv_dn = '1'
                report "Elevator did not move down"
                severity error;
            wait for 400 ns;
            assert unsigned(floor) = 1
                report "Elevator did not reach floor 1"
                severity error;
            wait for 100 ns;
            assert door_open = '1'
                report "Door did not open at floor 1"
                severity error;

            --Multiple requests
            floorNum <= "0011";
            key <= '0';
            wait for 100 ns;
            key <= '1';
            wait for 100 ns;
            floorNum <= "0101";
            wait for 100 ns;
            key <= '0';
            wait for 100 ns;
            key <= '1';
            wait for 400 ns;
            assert unsigned(floor) = 3
                report "Elevator did not reach floor 3"
                severity error;
            wait for 500 ns;
            assert unsigned(floor) = 5
                report "Elevator did not reach floor 5"
                severity error;

            --Request top floor (floor 9)
            floorNum <= "1001";
            key <= '0';
            wait for 100 ns;
            key <= '1';
            wait for 1200 ns;
            assert unsigned(floor) = 9
                report "Elevator did not reach top floor"
                severity error;
            assert mv_up = '0'
                report "Elevator still moving up at top floor"
                severity error;

            --Request lower floor (floor 0)
            floorNum <= "0000";
            key <= '0';
            wait for 100 ns;
            key <= '1';
            wait for 1200 ns;
            assert unsigned(floor) = 0
                report "Elevator did not return to floor 0"
                severity error;
            assert mv_dn = '0'
                report "Elevator still moving down at floor 0"
                severity error;

            --Reset while moving
            floorNum <= "0101";
            key <= '0';
            wait for 100 ns;
            key <= '1';
            wait for 150 ns;
            rst <= '0';
            wait for 20 ns;
            assert unsigned(floor) = 0
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
            key <= '0';
            wait for 100 ns;
            key <= '1';
            wait for 200 ns;
            assert unsigned(floor) < 10
                report "Elevator entered an invalid floor"
                severity error;

            wait;

