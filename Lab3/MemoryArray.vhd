library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity MemoryArray is
    generic(n:integer:=8);
    port(
        Clk,Rst,WE:in std_logic;
        writePort:in std_logic_vector(n-1 downto 0);
        readPort1,readPort2:out std_logic_vector(n-1 downto 0);
        Waddress,Raddress1,Raddress2:in std_logic_vector(2 downto 0)
    );
end MemoryArray;
architecture arch_memarray of MemoryArray is
    type ram_type is array (0 to 7) of std_logic_vector(n-1 downto 0);
    signal ram:ram_type;
begin
    process(Clk,Rst)
    begin
        if Rst='1' then
            ram <= (others => (others => '0'));
        elsif rising_edge(Clk) then
            if WE='1' then
                ram(to_integer(unsigned(Waddress))) <= writePort;
            end if;
        end if;
    end process;
    readPort1 <= ram(to_integer(unsigned(Raddress1)));
    readPort2 <= ram(to_integer(unsigned(Raddress2)));
end arch_memarray;