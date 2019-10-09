library ieee;
use ieee.std_logic_1164.all;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM;

architecture synth of ROM is
	signal block_out : std_logic_vector(31 downto 0);
	
	component ROM_Block is
	port (
		address		: in std_logic_vector(9 downto 0);
		clock		: in std_logic := '1';
		q		    : out std_logic_vector(31 downto 0));
	end component;
	
begin
	
	rb : ROM_Block
	port map(
		address => address,
		clock => clk,
		q => block_out
	);
	
	read_process : process(clk)
	begin
		if rising_edge(clk) then
			if cs = '1' and read = '1' then
				rddata <= block_out;
			else rddata <= (others => 'Z');
			end if;
		end if;
	end process;
	
end synth;
