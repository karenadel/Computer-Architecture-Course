library ieee;
use ieee.std_logic_1164.all;

entity ALU is
    port(
        A    : in  std_logic_vector(15 downto 0);
        B    : in  std_logic_vector(15 downto 0);
        Cin  : in  std_logic;
        S    : in std_logic_vector(3 downto 0);
        F    : out std_logic_vector(15 downto 0);
        Cout : out std_logic
    );
end ALU;

ARCHITECTURE aluArch OF ALU IS
COMPONENT partB IS
    PORT(
        A,B : in  std_logic_vector(15 downto 0);
        s0,s1: in std_logic;
        F : out std_logic_vector(15 downto 0)
    );
END COMPONENT;
COMPONENT partC IS
    PORT(
        A: in  std_logic_vector(15 downto 0);
        s0,s1,Cin: in std_logic;
        F : out std_logic_vector(15 downto 0);
        Cout: out std_logic;
    );
END COMPONENT;
COMPONENT partD IS
    PORT(
        A: in  std_logic_vector(15 downto 0);
        s0,s1,Cin: in std_logic;
        F : out std_logic_vector(15 downto 0);
        Cout: out std_logic;
    );
END COMPONENT;
signal F_B, F_C, F_D : std_logic_vector(15 downto 0);
signal Cout_C, Cout_D : std_logic;
BEGIN
   prtB: partB port map(A, B, S(0), S(1), F => F_B);
   prtC: partC PORT MAP (A,S(0),S(1),Cin,F=>F_C,Cout=>Cout_C);
   prtD: partD PORT MAP (A,S(0),S(1),Cin,F=>F_D,Cout=> Cout_D);

    F <= F_B when S(3 downto 2) = "01" else
            F_C when S(3 downto 2) = "10" else
            F_D when S(3 downto 2) = "11" else
            (others => '0');

    Cout <= Cout_C when S(3 downto 2) = "10" else
            Cout_D when S(3 downto 2) = "11" else
            '0';

end aluArch;