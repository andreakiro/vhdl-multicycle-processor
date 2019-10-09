library ieee;
use ieee.std_logic_1164.all;

entity comparator is
    port(
        a_31    : in  std_logic;
        b_31    : in  std_logic;
        diff_31 : in  std_logic;
        carry   : in  std_logic;
        zero    : in  std_logic;
        op      : in  std_logic_vector(2 downto 0);
        r       : out std_logic
    );
end comparator;

architecture synth of comparator is
	signal s1 : std_logic;
	signal s2 : std_logic;
begin
	s1 <= (a_31 and (b_31 xor '1')) or ((a_31 xnor b_31) and (diff_31 or zero));
	s2 <= ((a_31 xor '1') and b_31) or ((a_31 xnor b_31) and ((diff_31 xor '1') and (zero xor '1')));
	
	r <= s1 					  when op = "001" else
		 s2 					  when op = "010" else
		 zero xor '1' 			  when op = "011" else
		 zero 					  when op = "100" else
		 (carry xor '1') or zero  when op = "101" else
		 carry and (zero xor '1') when op = "110" else
		 zero; -- for undefined cases, we compute A == B
end synth;
