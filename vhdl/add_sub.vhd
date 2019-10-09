library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is
	signal nb : std_logic_vector(31 downto 0);
	signal na : std_logic_vector(31 downto 0);
	signal s_r : std_logic_vector(31 downto 0);
	signal sum : std_logic_vector(32 downto 0);
begin
	na  <= std_logic_vector(unsigned(a) + 1) when sub_mode = '1' else std_logic_vector(unsigned(a));
	nb  <= b xor (31 downto 0 => sub_mode);
	sum <= std_logic_vector(unsigned('0' & na) + unsigned('0' & nb));
	s_r <= std_logic_vector(unsigned(na) + unsigned(nb));	 
	
	carry <= sum(32);
	zero  <= '1' when s_r = (31 downto 0 => '0') else '0';
	r 	  <= s_r;
end synth;