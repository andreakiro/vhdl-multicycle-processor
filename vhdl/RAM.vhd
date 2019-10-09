library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is
	type reg_type is array(0 to 1023) of std_logic_vector(31 downto 0);
	signal reg: reg_type := (others => (others => '0'));
begin
	
	read_process : process(clk)
	begin
		if rising_edge(clk) then
			if cs = '1' and read = '1' then
				rddata <= reg(to_integer(unsigned(address)));
			else rddata <= (others => 'Z');
			end if;
		end if;
	end process;

	write_process : process(clk, cs, write)
	begin
		if rising_edge(clk) and cs = '1' and write = '1' then
			reg(to_integer(unsigned(address))) <= wrdata;
		end if;
	end process;
	
end synth;