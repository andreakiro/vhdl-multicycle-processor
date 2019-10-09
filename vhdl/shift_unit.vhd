library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_unit is
    port(
        a  : in  std_logic_vector(31 downto 0);
        b  : in  std_logic_vector(4 downto 0);
        op : in  std_logic_vector(2 downto 0);
        r  : out std_logic_vector(31 downto 0)
    );
end shift_unit;

architecture synth of shift_unit is
	signal rotate_left : std_logic_vector(31 downto 0);		-- rotate left (rol)
	signal rotate_right : std_logic_vector(31 downto 0);	-- rotate right (ror)
	signal shift_left : std_logic_vector(31 downto 0);		-- shift left logical (sll)
	signal shift_right : std_logic_vector(31 downto 0);		-- shift right logical (srl)
	signal shift_right_a : std_logic_vector(31 downto 0);	-- shift right arithmetic (sra)
begin
	-- rotate left
	ro_left : process(a, b)
		variable v : std_logic_vector(31 downto 0);
	begin
		v := a;
		for i in 0 to 4 loop
			if (b(i) = '1') then
				v := v(31 - (2 ** i) downto 0) & v(31 downto 31 - ((2 ** i) - 1));
			end if;
		end loop;
		rotate_left <= v;
	end process;
	
	-- rotate right
	ro_right : process(a, b)
		variable v : std_logic_vector(31 downto 0);
	begin
		v := a;
		for i in 0 to 4 loop
			if (b(i) = '1') then
				v := v((2 ** i) - 1 downto 0) & v(31 downto (2 ** i));
			end if;
		end loop;
		rotate_right <= v;
	end process;
	
	-- shift left logical
	sh_left : process(a, b)
		variable v : std_logic_vector(31 downto 0);
	begin
		v := a;
		for i in 0 to 4 loop
			if (b(i) = '1') then
				v := v(31 - (2 ** i) downto 0) & ((2 ** i) - 1 downto 0 => '0');
			end if;
		end loop;
		shift_left <= v;
	end process;
	
	-- shift right logical
	sh_right : process(a, b)
		variable v : std_logic_vector(31 downto 0);
	begin
		v := a;
		for i in 0 to 4 loop
			if (b(i) = '1') then
				v := ((2 ** i) - 1 downto 0 => '0') & v(31 downto (2 ** i));
			end if;
		end loop;
		shift_right <= v;
	end process;
	
	-- shift right arithmetic
	sh_right_a : process(a, b)
		variable v : std_logic_vector(31 downto 0);
	begin
		v := a;
		for i in 0 to 4 loop
			if (b(i) = '1') then
				if a(31) = '1' then
					v := ((2 ** i) - 1 downto 0 => '1') & v(31 downto (2 ** i));
				else
					v := ((2 ** i) - 1 downto 0 => '0') & v(31 downto (2 ** i));
				end if;
			end if;
		end loop;
		shift_right_a <= v;
	end process;
	
	r <= rotate_left when op = "000" else
		 rotate_right when op = "001" else
		 shift_left when op = "010" else
		 shift_right when op = "011" else
		 shift_right_a when op = "111";
end synth;
