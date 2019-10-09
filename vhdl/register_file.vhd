library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
    port(
        clk    : in  std_logic;
        aa     : in  std_logic_vector(4 downto 0);
        ab     : in  std_logic_vector(4 downto 0);
        aw     : in  std_logic_vector(4 downto 0);
        wren   : in  std_logic;
        wrdata : in  std_logic_vector(31 downto 0);
        a      : out std_logic_vector(31 downto 0);
        b      : out std_logic_vector(31 downto 0)
    );
end register_file;

architecture synth of register_file is
	type reg_type is array(0 to 31) of std_logic_vector(31 downto 0); 
	signal reg: reg_type := (others => (others => '0'));
begin
	clock : process(clk, wren, aw)
	begin
		if wren = '1' and aw /= "00000" and rising_edge(clk) then
			reg(to_integer(unsigned(aw))) <= wrdata;
		end if;
	end process;
	
	a <= reg(to_integer(unsigned(aa)));
	b <= reg(to_integer(unsigned(ab)));
	
end synth;
