library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
	signal reg : std_logic_vector(15 downto 0);
begin
	clock : process(clk)
	begin
		if rising_edge(clk) then
			if reset_n = '1' and en = '1' then
				reg <= std_logic_vector(unsigned(reg) + to_unsigned(4, 16));
			end if;
		end if;
	end process;
		
	reg <= std_logic_vector(15 downto 0 => '0') when reset_n = '0';
	addr <= std_logic_vector(15 downto 0) & reg;
end synth;
