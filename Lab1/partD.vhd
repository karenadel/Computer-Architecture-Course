library ieee;
use ieee.std_logic_1164.all;

entity partD is
    port(
        A    : in  std_logic_vector(15 downto 0);
        Cin  : in  std_logic;
        S0   : in  std_logic;
        S1   : in  std_logic;
        F    : out std_logic_vector(15 downto 0);
        Cout : out std_logic
    );
end partD;

architecture partdArch of partD is
begin
    Cout <= '0' when (S1 = '1' and S0 = '1') else  
            A(15);                                 

    F <= A(14 downto 0) & '0'    when (S1 = '0' and S0 = '0') else  
         A(14 downto 0) & A(15) when (S1 = '0' and S0 = '1') else 
         A(14 downto 0) & Cin   when (S1 = '1' and S0 = '0') else  
         (others => '0');                                         

end partdArch;