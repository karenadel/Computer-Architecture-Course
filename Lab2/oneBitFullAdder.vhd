library ieee;
use ieee.std_logic_1164.all;

entity oneBitFullAdder is
    port(
        a,b,cin: in  std_logic;
        cout,s: out std_logic
    );
end oneBitFullAdder;

architecture a_onefullAdder of oneBitFullAdder is
begin

        s <= a XOR b XOR cin;
        cout <= (a AND b) or (cin AND (a XOR b));

end a_onefullAdder;