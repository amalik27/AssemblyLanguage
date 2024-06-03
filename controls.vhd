library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity controls is
port (
    -- Timing Signals
    clk , en , rst : in std_logic;
    
    -- Register File IO
    rID1 : out std_logic_vector(4 downto 0) := "00001";
    rID2 : out std_logic_vector (4 downto 0);
    wr_enR1 , wr_enR2 : out std_logic;
    regrD1 : in std_logic_vector(15 downto 0);
    regrD2 : in std_logic_vector (15 downto 0);
    regwD1 , regwD2 : out std_logic_vector (15 downto 0);
    
    -- Framebuffer IO
    fbRST : out std_logic ;
    fbAddr1 : out std_logic_vector (11 downto 0);
    fbDin1 : in std_logic_vector (15 downto 0);
    fbDout1 : out std_logic_vector (15 downto 0);
    wr_en : out std_logic;
    
    -- Instruction Memory IO
    irAddr : out std_logic_vector (13 downto 0);
    irWord : in std_logic_vector (31 downto 0);
    
    -- Data Memory IO
    dAddr : out std_logic_vector (14 downto 0);
    d_wr_en : out std_logic;
    dOut : out std_logic_vector (15 downto 0);
    dIn : in std_logic_vector (15 downto 0);
    
    -- ALU IO
    aluA , aluB : out std_logic_vector (15 downto 0);
    aluOp : out std_logic_vector (3 downto 0);
    aluResult : in std_logic_vector (15 downto 0);
    
    -- UART IO
    ready , newChar : in std_logic;
    sendUART : out std_logic;
    charRec : in std_logic_vector (7 downto 0);
    charSend : out std_logic_vector (7 downto 0)
);
end controls;

architecture fsm of controls is

type state is (fetch, settingReg, decode, waitDecode, rops, ropsWait, iops, iopsWait, jops, calc,calcWait, store, storeWait, jr, recv, rpix,rpixwait, wpix, 
               wpixWait, send, equals, nequal, ori, lw,lwWait, sw,swWait, jmp, jal, clrscr, finish);
               
signal curr : state := fetch;

--During the "fetch" state we store "regrD1" into this signal
signal pc_signal : std_logic_vector(15 downto 0);
signal instruction : std_logic_vector(31 downto 0);
signal opcode : std_logic_vector(4 downto 0);
signal reg1Addr : std_logic_vector(4 downto 0);
signal reg1 : std_logic_vector(15 downto 0);
signal reg2 : std_logic_vector(15 downto 0);
signal reg3 : std_logic_vector(15 downto 0);
signal immediate : std_logic_vector(15 downto 0);
signal resultALU : std_logic_vector(15 downto 0) := aluResult;
signal sum_for_lw : std_logic_vector(15 downto 0);

begin

process(clk)
begin
if (rising_edge(clk)) then
    case curr is
		when fetch => 
			--Set the address to 1 for register 1
			pc_signal <= regrD1;
			curr <= decode;
			
		when decode =>
			--what does it mean irMem[pc_signal]??????
			--Ignoring the first 2 top bits because the instruction memory block only has 14 bits of physical memory
			irAddr <= pc_signal(13 downto 0);
			wr_enR1 <= '1';
			curr <= waitDecode;
			
		when waitDecode =>
			if irWord(31 downto 30) = "00" or irWord(31 downto 30) = "01" then
				curr <= rops;
			elsif irWord(31 downto 30) = "10" then
				curr <= iops;
			else
				curr <= jops;
			end if;
			--Incrementing pc signal
			regwD1 <= std_logic_vector(unsigned(pc_signal)+1);
			wr_enR1 <= '0';
			instruction <= irWord;
			
		when rops =>
			opcode <= instruction(31 downto 27);
			--Address of reg2
			rID1 <= instruction(21 downto 17);
			--Address of reg3
			rID2 <= instruction(16 downto 12);
			--Address of reg1
			reg1Addr <= instruction(26 downto 22);
			curr <= ropsWait;
			
		when ropsWait =>
			reg2 <= regrD1;
			reg3 <= regrD2;
			
			if opcode = "01101" then
			    rID1 <= reg1Addr;
				curr <= jr;
				
			elsif opcode = "01100" then
				curr <= recv;
				
			elsif opcode = "01111" then	
				curr <= rpix;
				
			elsif opcode = "01110" then
				curr <= wpix;
				rID1 <= reg1Addr;
				
			elsif opcode = "01011" then
				curr <= send;
			    rID1 <= reg1Addr;

			else
				curr <= calc;
			end if;
			
		when iops => 
		  opcode <= instruction(31 downto 27);
		  --Address of reg1
		  reg1Addr <= instruction(26 downto 22);
		  --Address of reg2
		  rID1 <= instruction(21 downto 17);
		  --Immediate
		  immediate <= instruction(16 downto 1);
		 
		  curr <= iopsWait;
		  
	   when iopsWait =>
	       reg2 <= regrD1;
	       if opcode(2 downto 0) = "000" then
	           curr <= equals;
	           --Set address to reg1
	           rID1 <= reg1Addr;
	       elsif opcode(2 downto 0) = "001" then
	           curr <= nequal;
	           --Set address to reg1
	           rID1 <= reg1Addr;
	       elsif opcode(2 downto 0) = "010" then
	           curr <= ori;
	       elsif opcode(2 downto 0) = "011" then
	           sum_for_lw <= std_logic_vector(unsigned(reg2)+unsigned(immediate));
	           curr <= lw;
	           
	       else 
	           sum_for_lw <= std_logic_vector(unsigned(reg2)+unsigned(immediate));
	           rID1 <= reg1Addr;
	           curr <= sw;
	       end if;
	       
	   when store =>
	       rID2 <= reg1Addr;
	       wr_enR2 <= '1';
	       curr <= storeWait;
	       
	   when storeWait =>
	       regwD2 <= resultALU;
	       curr <= finish;
	  
	       
	   when jops =>
	       immediate <= instruction(26 downto 11); 
	       if opcode = "11000" then
	           rID1 <= "00001";
	           wr_enR1 <= '1';
	           curr <= jmp;
	       elsif opcode = "11001" then
	           rID1 <= "00001";
	           wr_enR1 <= '1';
	           rID2 <= "00010";
	           wr_enR2 <= '1';
	           curr <= jal;
	       else
	           curr <= clrscr;
	       end if;
	   when jr =>
	        resultALU <= regrD1;
	        --Setting address back to register 1
	        reg1Addr <= "00001";
	        --Setting the write enable to 1 for store state to write
	        curr <= store;
	        
	   when recv =>
	       resultALU <= x"00" & charRec;
	       if newChar = '0' then
	           curr <= recv;
	       else
	           curr <= store;
	       end if;
	  
	   when rpix =>
	       fbAddr1 <= reg2(11 downto 0);
	       curr <= rpixWait;
	       
	   when rpixWait =>
	       resultALU <= fbDin1;
	       curr <= store;
	       
	  when wpix => 
	       fbAddr1 <= regrD1(11 downto 0);
	       wr_en <= '1';
	       curr <= wpixWait;
	  
	  when wpixWait =>
	       fbDout1 <= reg2;
	       curr <= finish;
	       
	  when send =>
	       sendUART <= '1';
	       charSend <= regrD1(7 downto 0);
	       
	       if ready = '1' then
	           curr <= finish;
	       else
	           curr <= send;
	       end if;
	  
	  when calc =>
	       aluA <= reg2;
	       aluB <= reg3;
	       aluOp <= opcode(3 downto 0);
	       curr <= calcWait;
	  
	  when calcWait =>
	       resultALU <= aluresult;
	       curr <= store;
	  
	  when equals =>
	       if (regrD1 = reg2) then
	           resultALU <= immediate;
	           reg1Addr <= "00001";
	           curr <= store;
	       end if;
	  
	  when nequal =>
	       if (regrD1 /= reg2) then
	           resultALU <= immediate;
	           reg1Addr <= "00001";
	           curr <= store;
	       end if;  
	  
	  when ori =>
	       resultALU <= immediate or reg2;
	       curr <= store;
	  
	  when lw =>
	       dAddr <= sum_for_lw(14 downto 0);
	       curr <= lwWait;
	       
	  when lwWait =>
	       resultALU <= dIn;
	       curr <= store;
	   
	  when sw =>
	       d_wr_en <= '1';
	       dAddr <= sum_for_lw(14 downto 0);
	       curr <= swWait;
	  
	  when swWait =>
	       dOut <= regrD1;
	       curr <= finish;
	       
	 when jmp =>
	       regwD1 <= immediate;
	       wr_enR1 <= '0';
	       curr <= finish;
	 when jal =>
	       regwD2 <= pc_signal;
	       regwD1 <= immediate;
	       wr_enR1 <= '0';
	       wr_enR2 <= '0';
	       curr <= finish;
	 
	 when clrscr =>
	       fbRST <= '1';
	       curr <= finish;
	 
	 when finish =>
	       wr_en <= '0';
	       wr_enR1 <= '0';
	       wr_enR2 <= '0';
	       d_wr_en <= '0';
	       rID1 <= "00001";
	       curr <= fetch; 
	 when others =>
	       curr <= finish;   
	end case;
end if;
end process;		
end fsm;
