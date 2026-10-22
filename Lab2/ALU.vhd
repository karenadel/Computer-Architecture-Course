library ieee;
use ieee.std_logic_1164.all;

entity ALU is
generic (n:integer:=8);
    port(
        A,B: in  std_logic_vector(n-1 downto 0);
        Cin: in  std_logic;
        S: in std_logic_vector(3 downto 0);
        F: out std_logic_vector(n-1 downto 0);
        Cout: out std_logic
    );
end ALU;

architecture aluArch OF ALU IS

component partA is
generic (n:integer:=8);
    port(
        A,B: in  std_logic_vector(n-1 downto 0);
        Cin,s0,s1: in std_logic;
        F : out std_logic_vector(n-1 downto 0);
        Cout: out std_logic
    );
end component;

component partB IS
generic (n:integer:=8);
    port(
        A,B : in  std_logic_vector(n-1 downto 0);
        s0,s1: in std_logic;
        F : out std_logic_vector(n-1 downto 0)
    );
end component;

component partC IS
generic (n:integer:=8);
    port(
        A: in  std_logic_vector(n-1 downto 0);
        Cin,s0,s1: in std_logic;
        F : out std_logic_vector(n-1 downto 0);
        Cout: out std_logic
    );
end component;

component partD IS
generic (n:integer:=8);
    port(
        A: in  std_logic_vector(n-1 downto 0);
        Cin,s0,s1: in std_logic;
        F : out std_logic_vector(n-1 downto 0);
        Cout: out std_logic
    );
end component;

signal F_B, F_C, F_D, F_A : std_logic_vector(n-1 downto 0);
signal Cout_C, Cout_D, Cout_A : std_logic;

begin

    prtA: partA generic map (n => n) port map(A, B, Cin, S(0), S(1), F => F_A, Cout => Cout_A);
    prtB: partB generic map (n => n) port map(A, B, S(0), S(1), F => F_B);
    prtC: partC generic map (n => n) port map(A, Cin, S(0), S(1), F => F_C, Cout => Cout_C);
    prtD: partD generic map (n => n) port map(A, Cin, S(0), S(1), F => F_D, Cout => Cout_D);
    

    with S(3 downto 2) select
    F <= F_A when "00",
        F_B when "01",
        F_C when "10",
        F_D when "11",
        (others => '0') when others;

    with S(3 downto 2) select
    Cout <= Cout_A when "00",
            Cout_C when "10",
            Cout_D when "11",
            '0'    when others;

end aluArch;