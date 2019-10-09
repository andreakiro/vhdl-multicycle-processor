library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
    port(
        address : in  std_logic_vector(15 downto 0);
        cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
        cs_ROM  : out std_logic
    );
end decoder;

architecture synth of decoder is
begin
	cs_LEDS <= '1' when x"2000" <= address and address <= x"200C" else '0';
	cs_RAM  <= '1' when x"1000" <= address and address <= x"1FFC" else '0';
	cs_ROM  <= '1' when x"0000" <= address and address <= x"0FFC" else '0';
end synth;
