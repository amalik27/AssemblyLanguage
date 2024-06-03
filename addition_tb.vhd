library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity addition_tb is
end addition_tb;

architecture Behavioral of addition_tb is

component controls is
port( 
    clk , en , rst : in std_logic;
    rID1 : out std_logic_vector(4 downto 0) := "00001"; 
    rID2 : out std_logic_vector (4 downto 0);
    wr_enR1 , wr_enR2 : out std_logic;
    regrD1 : in std_logic_vector(15 downto 0);
    regrD2 : in std_logic_vector (15 downto 0);
    regwD1 , regwD2 : out std_logic_vector (15 downto 0);
    fbRST : out std_logic ;
    fbAddr1 : out std_logic_vector (11 downto 0);
    fbDin1 : in std_logic_vector (15 downto 0);
    fbDout1 : out std_logic_vector (15 downto 0);
    irAddr : out std_logic_vector (13 downto 0);
    irWord : in std_logic_vector (31 downto 0);
    dAddr : out std_logic_vector (14 downto 0);
    d_wr_en : out std_logic;
    dOut : out std_logic_vector (15 downto 0);
    dIn : in std_logic_vector (15 downto 0);
    aluA , aluB : out std_logic_vector (15 downto 0);
    aluOp : out std_logic_vector (3 downto 0);
    aluResult : in std_logic_vector (15 downto 0);
    ready , newChar : in std_logic;
    sendUART : out std_logic;
    charRec : in std_logic_vector (7 downto 0);
    charSend : out std_logic_vector (7 downto 0)
    );
end component;

component regs is
port (
    clk, en, rst : in std_logic;
    id1, id2 : in std_logic_vector(4 downto 0);
    wr_en1, wr_en2 : in std_logic;
    din1, din2 : in std_logic_vector(15 downto 0);
    dout1, dout2 : out std_logic_vector(15 downto 0)
    );
end component;

component my_alu is
Port(
    opcode : in std_logic_vector(3 downto 0);
    clock : in std_logic;
    en : in std_logic;
    A : in std_logic_vector(15 downto 0);
    B : in std_logic_vector(15 downto 0);
    output : out std_logic_vector(15 downto 0)
    );
end component;

signal clk, en, rst : std_logic := '0';
signal rID1, rID2 : std_logic_vector(4 downto 0);
signal wr_enR1, wr_enR2 : std_logic;
signal regrD1, regrD2, regwD1, regwD2 : std_logic_vector(15 downto 0);
signal fbRST : std_logic;
signal fbAddr1 : std_logic_vector(11 downto 0);
signal fbDin1, fbDout1 : std_logic_vector(15 downto 0);
signal irAddr : std_logic_vector(13 downto 0);
signal irWord : std_logic_vector(31 downto 0) := x"00C85000";
signal dAddr : std_logic_vector(14 downto 0);
signal d_wr_en : std_logic;
signal dOut, dIn : std_logic_vector(15 downto 0);
signal aluA, aluB : std_logic_vector(15 downto 0);
signal aluOp : std_logic_vector(3 downto 0);
signal aluResult : std_logic_vector(15 downto 0);
signal ready, newChar : std_logic;
signal sendUART : std_logic;
signal charRec, charSend : std_logic_vector(7 downto 0);

begin

    controls_unit : controls port map(
        clk => clk,
        en => en,
        rst => rst,
        rID1 => rID1,
        rID2 => rID2,
        wr_enR1 => wr_enR1,
        wr_enR2 => wr_enR2,
        regrD1 => regrD1,
        regrD2 => regrD2,
        regwD1 => regwD1,
        regwD2 => regwD2,
        fbRST => fbRST,
        fbAddr1 => fbAddr1,
        fbDin1 => fbDin1,
        fbDout1 => fbDout1,
        irAddr => irAddr,
        irWord => irWord,
        dAddr => dAddr,
        d_wr_en => d_wr_en,
        dOut => dOut,
        dIn => dIn,
        aluA => aluA,
        aluB => aluB,
        aluOp => aluOp,
        aluResult => aluResult,
        ready => ready,
        newChar => newChar,
        sendUART => sendUART,
        charRec => charRec,
        charSend => charSend
    );

    regs_unit : regs port map(
        clk => clk,
        en => en,
        rst => rst,
        id1 => rID1,
        id2 => rID2,
        wr_en1 => wr_enR1,
        wr_en2 => wr_enR2,
        din1 => regwD1,
        din2 => regwD2,
        dout1 => regrD1,
        dout2 => regrD2
    );

    alu_unit : my_alu port map(
        opcode => aluOp,
        clock => clk,
        en => en,
        A => aluA,
        B => aluB,
        output => aluResult
    );

    clock_process : process
    begin
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
    end process;

end Behavioral;
