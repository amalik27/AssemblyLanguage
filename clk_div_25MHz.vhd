
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;



entity clock_div_25MHz is
    Port( signal clock_in : in std_logic;
          signal clock_out : out std_logic);
end clock_div_25MHz;

architecture Behavioral of clock_div_25MHz is
signal count : std_logic_vector(25 downto 0) := (others => '0');

begin

process(clock_in)
    begin
        if rising_edge(clock_in) then
            count <= std_logic_vector(unsigned(count)+1);
            if unsigned(count)=4 then
                clock_out <= '1';
                count <= (others => '0');
            else
                clock_out <= '0';
            end if;
        end if;
 end process;

end Behavioral;