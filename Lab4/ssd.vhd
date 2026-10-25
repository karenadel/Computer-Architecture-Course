library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ssd is
    port(
        input : in std_logic_vector(3 downto 0);
        output : out std_logic_vector(6 downto 0)
    );
end ssd;
architecture arch_ssd of ssd is
begin
    process(input)
    begin
        case input is
            when "0000" => output <= "1000000";
            when "0001" => output <= "1111001";
            when "0010" => output <= "0100100";
            when "0011" => output <= "0110000";
            when "0100" => output <= "0011001";
            when "0101" => output <= "0010010";
            when "0110" => output <= "0000010";
            when "0111" => output <= "1111000";
            when "1000" => output <= "0000000";
            when "1001" => output <= "0010000";
            when others => output <= "1111111";
        end case;
    end process;
end arch_ssd;