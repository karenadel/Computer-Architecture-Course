library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity testbench is
end testbench;
architecture arch_tb of testbench is
    component RegisterFile is
        generic (n:integer:=8);
        port(
            Clk,Rst,WE:in std_logic;
            writePort:in std_logic_vector(n-1 downto 0);
            readPort1,readPort2:out std_logic_vector(n-1 downto 0);
            Waddress,Raddress1,Raddress2:in std_logic_vector(2 downto 0)
        );
    end component;
    component MemoryArray is
        generic(n:integer:=8);
        port(
            Clk,Rst,WE:in std_logic;
            writePort:in std_logic_vector(n-1 downto 0);
            readPort1,readPort2:out std_logic_vector(n-1 downto 0);
            Waddress,Raddress1,Raddress2:in std_logic_vector(2 downto 0)
        );
    end component;
    signal Clk,Rst,WE:std_logic:= '1';
    signal writePort:std_logic_vector(7 downto 0):= (others => '0');
    signal readPort1mem,readPort2mem:std_logic_vector(7 downto 0);
    signal readPort1reg,readPort2reg:std_logic_vector(7 downto 0);
    signal Waddress,Raddress1,Raddress2:std_logic_vector(2 downto 0):= (others => '0');
begin
    --clock genration
    process
    begin
        Clk <= '0'; wait for 10 ns;
        Clk <= '1'; wait for 10 ns;
    end process;

    --simulation
    process
    begin
        --clock cycle 1
        Rst<='1'; WE<='0'; writePort<=(others=>'0'); Waddress<="000"; Raddress1<="000"; Raddress2<="000"; 
        wait for 20 ns;
        Assert (readPort1reg=x"00" and readPort2reg=x"00") 
        report "Reset failed for RegisterFile" 
        severity error;
        Assert (readPort1mem=x"00" and readPort2mem=x"00") 
        report "Reset failed for MemoryArray" 
        severity error;
        
        --initial write
        --clock cycle 2
        Rst<='0'; WE<='1'; writePort<= x"FF"; Waddress<="000"; Raddress1<="000"; Raddress2<="000"; 
        wait for 20 ns;
        Assert (readPort1reg=x"FF" and readPort2reg=x"FF") 
        report "Read failed for RegisterFile when reading reg0" 
        severity error;
        Assert (readPort1mem=x"FF" and readPort2mem=x"FF") 
        report "Read failed for MemoryArray when reading reg0" 
        severity error;
        --clock cycle 3
        Rst<='0'; WE<='1'; writePort<= x"11"; Waddress<="001"; Raddress1<="000"; Raddress2<="000"; 
        wait for 20 ns;
        Assert (readPort1reg=x"FF" and readPort2reg=x"FF") 
        report "Read failed for RegisterFile when reading reg0" 
        severity error;
        Assert (readPort1mem=x"FF" and readPort2mem=x"FF") 
        report "Read failed for MemoryArray when reading reg0" 
        severity error;
        --clock cycle 4
        Rst<='0'; WE<='1'; writePort<= x"90"; Waddress<="111"; Raddress1<="000"; Raddress2<="000"; 
        wait for 20 ns;
        Assert (readPort1reg=x"FF" and readPort2reg=x"FF") 
        report "Read failed for RegisterFile when reading reg0" 
        severity error;
        Assert (readPort1mem=x"FF" and readPort2mem=x"FF") 
        report "Read failed for MemoryArray when reading reg0" 
        severity error;
        --clock cycle 5
        Rst<='0'; WE<='1'; writePort<= x"08"; Waddress<="011"; Raddress1<="000"; Raddress2<="000"; 
        wait for 20 ns;
        Assert (readPort1reg=x"FF" and readPort2reg=x"FF") 
        report "Read failed for RegisterFile when reading reg0" 
        severity error;
        Assert (readPort1mem=x"FF" and readPort2mem=x"FF") 
        report "Read failed for MemoryArray when reading reg0" 
        severity error;

        --reading from the registers and memory
        --clock cycle 6
        Rst<='0'; WE<='1'; writePort<= x"03"; Waddress<="100"; Raddress1<="001"; Raddress2<="111"; 
        wait for 20 ns;
        Assert (readPort1reg=x"11" and readPort2reg=x"90") 
        report "Read failed for RegisterFile when reading reg1 and reg7"
        severity error;
        Assert (readPort1mem=x"11" and readPort2mem=x"90") 
        report "Read failed for MemoryArray when reading reg1 and reg7"
        severity error;
        --clock cycle 7
        Rst<='0'; WE<='0'; writePort<= x"00"; Waddress<="010"; Raddress1<="010"; Raddress2<="011"; 
        wait for 20 ns;
        Assert (readPort1reg=x"00" and readPort2reg=x"08") 
        report "Read failed for RegisterFile when reading reg2 and reg3"
        severity error;
        Assert (readPort1mem=x"00" and readPort2mem=x"08") 
        report "Read failed for MemoryArray when reading reg2 and reg3"
        severity error;
        --clock cycle 8
        Rst<='0'; WE<='0'; writePort<= x"00"; Waddress<="100"; Raddress1<="100"; Raddress2<="101"; 
        wait for 20 ns;
        Assert (readPort1reg=x"03" and readPort2reg=x"00") 
        report "Read failed for RegisterFile when reading reg4 and reg5"
        severity error;
        Assert (readPort1mem=x"03" and readPort2mem=x"00") 
        report "Read failed for MemoryArray when reading reg4 and reg5"
        severity error;
        --clock cycle 9
        Rst<='0'; WE<='1'; writePort<= x"01"; Waddress<="000"; Raddress1<="110"; Raddress2<="000"; 
        wait for 20 ns;
        Assert (readPort1reg=x"00" and readPort2reg=x"01") 
        report "Read failed for RegisterFile when reading reg6 and reg0"
        severity error;
        Assert (readPort1mem=x"00" and readPort2mem=x"01") 
        report "Read failed for MemoryArray when reading reg6 and reg0"
        severity error;
    wait;
    end process;

    --instantiating RegisterFile
    regfile: RegisterFile generic map (8) port map(Clk,Rst,WE,writePort,readPort1reg,readPort2reg,Waddress,Raddress1,Raddress2);
    --instantiating MemoryArray
    memarray: MemoryArray generic map (8) port map(Clk,Rst,WE,writePort,readPort1mem,readPort2mem,Waddress,Raddress1,Raddress2);
end arch_tb;