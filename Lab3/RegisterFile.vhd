library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity RegisterFile is
    generic (n:integer:=8);
    port(
        Clk,Rst,WE:in std_logic;
        writePort:in std_logic_vector(n-1 downto 0);
        readPort1,readPort2:out std_logic_vector(n-1 downto 0);
        Waddress,Raddress1,Raddress2:in std_logic_vector(2 downto 0)
    );
end RegisterFile;
architecture arch_regfile of RegisterFile is

    component nDFF is
        generic ( n : integer := 8);
        port( 
            Clk,Rst : in std_logic;
            d : in std_logic_vector(n-1 DOWNTO 0);
            q : out std_logic_vector(n-1 DOWNTO 0)
        );
    end component;

    signal s0,s1,s2,s3,s4,s5,s6,s7:std_logic;
    signal qCurr0,qCurr1,qCurr2,qCurr3,qCurr4,qCurr5,qCurr6,qCurr7:std_logic_vector(n-1 downto 0);
    signal dNext0,dNext1,dNext2,dNext3,dNext4,dNext5,dNext6,dNext7:std_logic_vector(n-1 downto 0);
    signal WaddressVector:std_logic_vector(7 downto 0);



begin
    --changes with changing the Waddress
    process (Waddress)
    begin
        WaddressVector <= (others => '0');
        WaddressVector(to_integer(unsigned(Waddress))) <= '1';
    end process;

    --setting the write enable signals for each register
    s0 <= WaddressVector(0) and WE; s1 <= WaddressVector(1) and WE; s2 <= WaddressVector(2) and WE; s3 <= WaddressVector(3) and WE;
    s4 <= WaddressVector(4) and WE; s5 <= WaddressVector(5) and WE; s6 <= WaddressVector(6) and WE; s7 <= WaddressVector(7) and WE;

    -- instantiating the registers
    register0: nDFF generic map (n => n) port map(Clk,Rst,dNext0,qCurr0);
    dNext0 <= writePort when s0='1' else qCurr0;

    register1: nDFF generic map (n => n) port map(Clk,Rst,dNext1,qCurr1);
    dNext1 <= writePort when s1='1' else qCurr1;

    register2: nDFF generic map (n => n) port map(Clk,Rst,dNext2,qCurr2);
    dNext2 <= writePort when s2='1' else qCurr2;

    register3: nDFF generic map (n => n) port map(Clk,Rst,dNext3,qCurr3);
    dNext3 <= writePort when s3='1' else qCurr3;

    register4: nDFF generic map (n => n) port map(Clk,Rst,dNext4,qCurr4);
    dNext4 <= writePort when s4='1' else qCurr4;

    register5: nDFF generic map (n => n) port map(Clk,Rst,dNext5,qCurr5);
    dNext5 <= writePort when s5='1' else qCurr5;

    register6: nDFF generic map (n => n) port map(Clk,Rst,dNext6,qCurr6);
    dNext6 <= writePort when s6='1' else qCurr6;

    register7: nDFF generic map (n => n) port map(Clk,Rst,dNext7,qCurr7);
    dNext7 <= writePort when s7='1' else qCurr7;

    --setting the read ports based on the read addresses async
    with Raddress1 select
        readPort1 <=qCurr0 when "000",
                    qCurr1 when "001",
                    qCurr2 when "010",
                    qCurr3 when "011",
                    qCurr4 when "100",
                    qCurr5 when "101",
                    qCurr6 when "110",
                    qCurr7 when others;

    with Raddress2 select
        readPort2 <=qCurr0 when "000",
                    qCurr1 when "001",
                    qCurr2 when "010",
                    qCurr3 when "011",
                    qCurr4 when "100",
                    qCurr5 when "101",
                    qCurr6 when "110",
                    qCurr7 when others;
end arch_regfile;