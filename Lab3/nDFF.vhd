
library ieee;
use ieee.std_logic_1164.all;
entity nDFF IS
    generic (n:integer:=8);
    port(
	Clk,Rst : in std_logic;
        d : in std_logic_vector(n-1 DOWNTO 0);
        q : out std_logic_vector(n-1 DOWNTO 0)
    );
end nDFF;
architecture arch_ndff of nDFF is
begin
    process(clk,Rst)
    begin
        if Rst = '1' then
            q <= (others => '0');
        elsif rising_edge(clk) then
            q <= d;
        end if;
    end process;

end arch_ndff ;