library ieee;
use ieee.std_logic_1164.all;

entity partB is
generic(n:integer:=8);
    port(
        A: in  std_logic_vector(n-1 downto 0);
        B: in  std_logic_vector(n-1 downto 0);
        S0: in  std_logic;
        S1: in  std_logic;
        F: out std_logic_vector(n-1 downto 0)
    );
end partB;

architecture partbArch of partB is
begin

    F <= A and B when S1 = '0' and S0 = '0'
	else A or  B when S1 = '0' and S0 = '1'
	else A xor B when S1 = '1' and S0 = '0'
	else not A;                                      

end partbArch;