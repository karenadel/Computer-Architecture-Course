library ieee;
use ieee.std_logic_1164.all;

entity partA is
generic (n:integer:=8);
    port(
        A,B: in std_logic_vector (n-1 downto 0);
        cin,S0,S1: in std_logic;
        F: out std_logic_vector (n-1 downto 0);
        cout: out std_logic
    );
end partA;

architecture partaArch of partA is

component NBitFullAdder is
generic (n:integer:=8);
    port(
        a, b : in std_logic_vector(n-1 downto 0);
        cin : in std_logic;
        s : out std_logic_vector(n-1 downto 0);
        cout : out std_logic
    );
end component;

signal B_not: std_logic_vector(n-1 downto 0);
signal Y: std_logic_vector(n-1 downto 0);
signal SUM: std_logic_vector(n-1 downto 0);
signal adder_cout: std_logic;

begin

    B_not <= not B;

    Y<= (others=>'0') when S1='0' AND S0='0'
    else B when S1='0' AND S0='1'
    else B_not when S1='1' AND S0='0'
    else (others => '1');

    adder: NBitFullAdder
        generic map (n=>n)
        port map (
            a=> A,
            b=> Y,
            cin=> cin,
            s=> SUM,
            cout=> adder_cout
        );
    
    F<= (others=>'0') when S0='1' AND S1='1' AND cin='1'
    else SUM; 

    cout<= '0' when S0='1' AND S1='1' AND cin='1'
    else adder_cout;

end partaArch;