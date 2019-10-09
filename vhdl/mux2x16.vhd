library ieee;
use ieee.std_logic_1164.all;

entity mux2x16 is
    port(
        i0  : in  std_logic_vector(15 downto 0);
        i1  : in  std_logic_vector(15 downto 0);
        sel : in  std_logic;
        o   : out std_logic_vector(15 downto 0)
    );
end mux2x16;

architecture synth of mux2x16 is
begin
end synth;
