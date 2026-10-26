library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elevator_ctrl is
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
end elevator_ctrl;

architecture arch_ctrl of elevator_ctrl is

    component ssd
        port(
            input : in  std_logic_vector(3 downto 0);
            output : out std_logic_vector(6 downto 0)
        );
    end component;

    type state_type is (doorClosed, doorOpen, movingUp, movingDown);
    signal state, next_state : state_type := doorClosed;

    signal pendingRequests : std_logic_vector(N_FLOORS-1 downto 0) := (others => '0');

    signal pendingLarger : std_logic := '0';
    signal pendingSmaller : std_logic := '0';

    signal timer, next_timer : integer range 0 to 1 := 0;
    signal dir, next_dir : std_logic := '1';

    signal floor_reg, next_floor : integer range 0 to N_FLOORS-1 := 0;
    signal floor_bin : std_logic_vector(3 downto 0);

    signal sec_en : std_logic := '0';
    signal cnt : integer range 0 to CLK_DIV-1 := 0;

    signal key_s1, key_s2, key_prev : std_logic := '1';

begin

    floor_bin <= std_logic_vector(to_unsigned(floor_reg, 4));
    floor <= floor_bin;
    ssd_inst : ssd port map(input => floor_bin, output => floor_ssd);

    process(clk, rst) -- prescaler
    begin
        if rst = '0' then
            cnt <= 0;
            sec_en <= '0';
        elsif rising_edge(clk) then
            sec_en <= '0';
            if cnt = CLK_DIV-1 then
                cnt <= 0;
                sec_en <= '1';
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    process(clk, rst) -- register
    begin
        if rst = '0' then
            state <= doorClosed;
            timer <= 0;
            dir <= '1';
            floor_reg <= 0;
        elsif rising_edge(clk) then
            if sec_en = '1' then
                state <= next_state;
                timer <= next_timer;
                dir <= next_dir;
                floor_reg <= next_floor;
            end if;
        end if;
    end process;

    process(clk, rst) -- request resolver
        variable f : integer;
    begin
        if rst = '0' then
            key_s1 <= '1';
            key_s2 <= '1';
            key_prev <= '1';
            pendingRequests <= (others => '0');
        elsif rising_edge(clk) then
            key_s1 <= key;
            key_s2 <= key_s1;
            key_prev <= key_s2;

            if state = doorOpen then
                pendingRequests(floor_reg) <= '0';
            end if;

            if key_prev = '1' and key_s2 = '0' then
                f := to_integer(unsigned(floorNum));
                if f < N_FLOORS then
                    pendingRequests(f) <= '1';
                end if;
            end if;
        end if;
    end process;

    process(pendingRequests, floor_reg)
        variable larger, smaller : std_logic;
    begin
        larger := '0';
        smaller := '0';
        for i in 0 to N_FLOORS-1 loop
            if pendingRequests(i) = '1' then
                if i > floor_reg then larger := '1'; end if;
                if i < floor_reg then smaller := '1'; end if;
            end if;
        end loop;
        pendingLarger <= larger;
        pendingSmaller <= smaller;
    end process;

    process(state, dir, timer, floor_reg, pendingRequests, pendingLarger, pendingSmaller)
        -- State transition
    begin
        next_state <= state;
        next_timer <= timer;
        next_dir <= dir;
        next_floor <= floor_reg;
------------------------------------------------------------------------
        case state is

            when doorClosed =>
                next_timer <= 0;
                if pendingRequests(floor_reg) = '1' then
                    next_state <= doorOpen;
                elsif dir = '1' then
                    if pendingLarger = '1' then
                        next_state <= movingUp;
                        next_dir <= '1';
                    elsif pendingSmaller = '1' then
                        next_state <= movingDown;
                        next_dir <= '0';
                    end if;
                else
                    if pendingSmaller = '1' then
                        next_state <= movingDown;
                        next_dir <= '0';
                    elsif pendingLarger = '1' then
                        next_state <= movingUp;
                        next_dir <= '1';
                    end if;
                end if;

            when doorOpen =>
                if timer = 1 then
                    next_state <= doorClosed;
                    next_timer <= 0;
                else
                    next_timer <= timer + 1;
                end if;

            when movingUp =>
                if timer = 1 then
                    next_timer <= 0;
                    if floor_reg < N_FLOORS-1 then
                        next_floor <= floor_reg + 1;
                        if pendingRequests(floor_reg + 1) = '1' then
                            next_state <= doorOpen;
                        end if;
                    else
                        next_state <= doorClosed;
                    end if;
                else
                    next_timer <= timer + 1;
                end if;

            when movingDown =>
                if timer = 1 then
                    next_timer <= 0;
                    if floor_reg > 0 then
                        next_floor <= floor_reg - 1;
                        if pendingRequests(floor_reg - 1) = '1' then
                            next_state <= doorOpen;
                        end if;
                    else
                        next_state <= doorClosed;
                    end if;
                else
                    next_timer <= timer + 1;
                end if;

        end case;
    end process;

-------------------------------------------------------------------------------------------------
--maybe led's lighting up
    mv_up <= '1' when state = movingUp   else '0';
    mv_dn <= '1' when state = movingDown else '0';
    door_open <= '1' when state = doorOpen   else '0';

end arch_ctrl;