
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity my_alu is
    Port( signal opcode : in std_logic_vector(3 downto 0);
          signal clock : in std_logic;
          signal en : in std_logic;
          signal A : in std_logic_vector(15 downto 0);
          signal B : in std_logic_vector(15 downto 0);
          signal output : out std_logic_vector(15 downto 0));
end my_alu;

architecture Behavioral of my_alu is

begin
    process (clock)
        begin
            if(rising_edge(clock)) then
                if en = '1' then
                    case opcode is
                        when x"0" => output <= std_logic_vector(unsigned(A)+unsigned(B));
                        when x"1" => output <= std_logic_vector(unsigned(A)-unsigned(B));
                        when x"2" => output <= std_logic_vector(unsigned(A)+1);
                        when x"3" => output <= std_logic_vector(unsigned(A)-1);
                        when x"4" => output <= std_logic_vector(0-unsigned(A));
                        when x"5" => output <= std_logic_vector(shift_left(unsigned(A),1));
                        when x"6" => output <= std_logic_vector(shift_right(unsigned(A),1));
                        when x"7" => output <= std_logic_vector(shift_right(signed(A),1));
                        when x"8" => output <= A and B;
                        when x"9" => output <= A or B;
                        when x"A" => output <= A xor B;
                        when x"B" => if( signed(A) < signed(B)) then 
                                            output(0) <= '1'; 
                                       else 
                                            output(0) <= '0'; 
                                       end if;
                        when x"C" => if( signed(A) > signed(B)) then 
                                            output(0) <= '1'; 
                                       else 
                                            output(0) <= '0'; 
                                       end if;
                        when x"D" => if (A = B) then
                                            output(0) <= '1';
                                       else
                                            output(0) <= '0';
                                       end if;
                        when x"E" => if (A < B) then
                                            output(0) <= '1';
                                        else 
                                            output(0) <= '0';
                                        end if;
                        when x"F" => if (A > B) then
                                            output(0) <= '1';
                                       else
                                            output(0) <= '0';
                                       end if;
                        when others =>
                                    output <= (others => '0');
                    end case;
                end if;
            end if;
        end process;
end Behavioral;
