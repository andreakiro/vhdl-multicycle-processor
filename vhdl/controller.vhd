library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is
	type state is (FETCH1, FETCH2, DECODE, R_OP, STORE, BREAK, LOAD1, LOAD2, I_OP);
	signal cur_state, next_state : state;
	signal s_op, s_opx : std_logic_vector(7 downto 0);
begin
	s_op <= "00" & op;
	s_opx <= "00" & opx;
	
	-- selecting the appropriate op-code for op_alu, depending on the operation 
	-- (following the tutorial)
	operation : process(s_op, s_opx)
	begin
		if s_op = x"04" then -- to be improved later on 
			op_alu <= op;
		elsif s_op = x"3A" then
			op_alu <= opx;
		end if;
	end process;
		
	-- FlipFlop
	dff : process(reset_n, clk)
	begin
		if reset_n = '0' then
			cur_state <= FETCH1;
		elsif rising_edge(clk) then
			cur_state <= next_state;
		end if;
	end process;
			
	-- TRANSITION LOGIC
	next_state <= FETCH2 when cur_state = FETCH1
			 else DECODE when cur_state = FETCH2
			 else R_OP when cur_state = DECODE and s_op = x"3A"
			 	and (s_opx = x"0E" or s_opx = x"1B")
			 else STORE when cur_state = DECODE and s_op = x"15"
			 else BREAK when cur_state = DECODE and s_op = x"3A" 
			 	and s_opx = x"34"
			 else BREAK when cur_state = BREAK
			 else LOAD1 when cur_state = DECODE and s_op = x"17"
			 else LOAD2 when cur_state = LOAD1
			 else I_OP when cur_state = DECODE and s_op = x"04"
			 else FETCH1 when cur_state = R_OP
			 			   or cur_state = STORE
			 			   or cur_state = LOAD2
			 			   or cur_state = I_OP;
	
	-- OUTPUT LOGIC
	read <= '1' when cur_state = FETCH1 else '0'; -- ready for new instruction
	ir_en <= '1' when cur_state = FETCH2 else '0'; -- enable instruction
	pc_en <= '1' when cur_state = FETCH2 else '0'; -- enable increment address by 4
	imm_signed <= '1' when cur_state = I_OP else '0'; -- from her table ¯\_(ツ)_/¯
	rf_wren <= '1' when cur_state = I_OP 
					 or cur_state = R_OP else '0'; -- enable write into register
	sel_b <= '1' when cur_state = R_OP else '0'; -- select second operand (immediate
												 -- or from register)
	sel_rC <= '1' when cur_state = R_OP else '0'; -- select write address
		
end synth;
