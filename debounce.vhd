library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity debounce is
    Port( clk : in std_logic;
          btn : in std_logic;
          dbnc : out std_logic);
end debounce;

architecture Behavioral of debounce is
    signal count_value : std_logic_vector(21 downto 0) := (others => '0');
    signal btn_stabilizer : std_logic_vector(1 downto 0) := (others => '0');
    signal temp_btn : std_logic;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            temp_btn <= btn_stabilizer(0);
            btn_stabilizer(0) <= btn;
            btn_stabilizer(1) <= temp_btn;
            if btn_stabilizer(1) = '1' then
                count_value <= std_logic_vector(unsigned(count_value)+1);
                if unsigned(count_value) = 2500000 then
                    dbnc <= '1';
                end if;
            else 
                count_value <= (others => '0');
                dbnc <= '0';
            end if;
        end if;
    end process;

end Behavioral;
