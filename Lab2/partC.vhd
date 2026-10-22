library ieee;
use ieee.std_logic_1164.all;

entity partC is
generic(n:integer:=8);
    port(
        A: in  std_logic_vector(n-1 downto 0);
        Cin: in  std_logic;
        S0: in  std_logic;
        S1: in  std_logic;
        F: out std_logic_vector(n-1 downto 0);
        Cout: out std_logic
    );
end partC;

architecture partcArch of partC is
begin

    Cout <= A(0);  

    F <= '0'   & A(n-1 downto 1) when S1 = '0' and S0 = '0'
	else A(0)  & A(n-1 downto 1) when S1 = '0' and S0 = '1'
	else Cin   & A(n-1 downto 1) when S1 = '1' and S0 = '0'
	else A(n-1) & A(n-1 downto 1);                                    

end partcArch;