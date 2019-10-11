library ieee;
use ieee.std_logic_1164.all;

entity extend is
    port(
        imm16  : in  std_logic_vector(15 downto 0);
        signed : in  std_logic;
        imm32  : out std_logic_vector(31 downto 0)
    );
end extend;

architecture synth of extend is
	constant zeroes_16bit : std_logic_vector(15 downto 0) := (others => '0');
	constant ones_16bit : std_logic_vector(15 downto 0) := (others => '1');
begin
	imm32 <= zeroes_16bit & imm16 when signed = '0' or imm16(15) = '0'
			 else ones_16bit & imm16;
end synth;
