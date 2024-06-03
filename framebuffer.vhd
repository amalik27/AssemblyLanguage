library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity framebuffer is
  Port (clk1, en1, en2          : in std_logic;
        addr1, addr2            : in std_logic_vector(11 downto 0);
        wr_en1                  : in std_logic;
        din1                    : in std_logic_vector(15 downto 0);
        dout1, dout2            : out std_logic_vector(15 downto 0)
         );
end framebuffer;

architecture Behavioral of framebuffer is

type words is array (0 to 4095) of std_logic_vector(15 downto 0);
signal framemem : words;

begin

process(clk1) 
begin
    if (rising_edge(clk1)) then
        if en1 = '1' then
            dout1 <= framemem(to_integer(unsigned(addr1)));
            
            if wr_en1 = '1' then
                framemem(to_integer(unsigned(addr1))) <= din1;
            end if;
     end if;
 end if;
 end process; 
 
process(clk1)
begin
    if (rising_edge(clk1)) then
        if en2 = '1' then
            dout2 <= framemem(to_integer(unsigned(addr2)));
        end if;
    end if;
end process;
            

end Behavioral;
