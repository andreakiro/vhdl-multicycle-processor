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
        -- immediate value sign extension
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
	type state is (FETCH1, FETCH2, DECODE, R_OP, RI_OP, STORE, BREAK,
		LOAD1, LOAD2, I_OP, UI_OP, BRANCH, CALL, CALLR, JMP, JMPI);
	signal cur_state, next_state : state;
	signal s_op, s_opx : std_logic_vector(7 downto 0);
begin
	s_op <= "00" & op;
	s_opx <= "00" & opx;
	
	-- flipflop
	dff : process(reset_n, clk)
	begin
		if reset_n = '0' then
			cur_state <= FETCH1;
		elsif rising_edge(clk) then
			cur_state <= next_state;
		end if;
	end process;
	
	-- selecting the appropriate op-code for op_alu, depending on the operation 
	operation : process(s_op, s_opx) 	-- to be completed later on 
	begin
	--	if s_op = x"04" then 
	--		op_alu <= op; 					-- add operation
		
		-- R-type operations	
		if s_op = x"3A" then
			if s_opx = x"31" then 			-- add operation
				op_alu <= "000100"; 
			elsif s_opx = x"39" then 		-- sub operation
				op_alu <= "001000";
			elsif s_opx = x"08" then 		-- cmple operation
				op_alu <= "011001"; 
			elsif s_opx = x"10" then 		-- cmpgt operation
				op_alu <= "011010"; 
			elsif s_opx = x"06" then 		-- nor operation
				op_alu <= "100000"; 
			elsif s_opx = x"0E" then 		-- and operation
				op_alu <= "100001"; 
			elsif s_opx = x"16" then 		-- or operation
				op_alu <= "100010"; 
			elsif s_opx = x"1E" then 		-- xnor operation
				op_alu <= "100011"; 
			elsif s_opx = x"13" then 		-- sll operation
				op_alu <= "110010"; 
			elsif s_opx = x"1B" then 		-- srl operation
				op_alu <= "110011"; 
			elsif s_opx = x"3B" then 		-- sra operation
				op_alu <= "111111";
			elsif s_opx = x"12" then 		-- slli operation
				op_alu <= "111010";
			elsif s_opx = x"1A" then 		-- srli operation
				op_alu <= "111011";
			elsif s_opx = x"3A" then 		-- srai operation
				op_alu <= "111111";
			elsif s_opx = x"18" then 		-- cmpne operation
				op_alu <= "011011";
			elsif s_opx = x"20" then 		-- cmpeq operation
				op_alu <= "011100";
			elsif s_opx = x"28" then 		-- cmpleu operation
				op_alu <= "011101";
			elsif s_opx = x"30" then 		-- cmpgtu operation
				op_alu <= "011110";
			elsif s_opx = x"03" then 		-- rol operation
				op_alu <= "111000";
			elsif s_opx = x"0B" then 		-- ror operation
				op_alu <= "111001";
			elsif s_opx = x"02" then 		-- roli operation
				op_alu <= "111000";
			end if;
		
		-- I-type operations
		elsif s_op = x"17" or s_op = x"15" then 
			op_alu <= "000100"; 			-- ldw and stw
		elsif s_op = x"0E" then
			op_alu <= "011001";				-- ble operation
		elsif s_op <= x"16" then
			op_alu <= "011010";				-- bgt operation
		elsif s_op = x"1E" then
			op_alu <= "011011";				-- bne operation
		elsif s_op = x"26" then
			op_alu <= "011100";				-- beq operation
		elsif s_op = x"2E" then
			op_alu <= "011101"; 			-- bleu operation
		elsif s_op = x"36" then
			op_alu <= "011110";				-- bgtu operation
		elsif s_op = x"04" then				-- addi operation
			op_alu <= "000100";
		elsif s_op = x"0C" then				-- andi operation
			op_alu <= "100001";
		elsif s_op = x"14" then				-- ori operation
			op_alu <= "100010";
		elsif s_op = x"1C" then				-- xnori operation
			op_alu <= "100011";
		elsif s_op = x"08" then				-- cmplei operation
			op_alu <= "011001";
		elsif s_op = x"10" then				-- cmpgti operation
			op_alu <= "011010";
		elsif s_op = x"18" then				-- cmpnei operation
			op_alu <= "011011";
		elsif s_op = x"20" then				-- cmpeqi operation
			op_alu <= "011100";
		elsif s_op = x"28" then				-- cmpleui operation
			op_alu <= "011101";
		elsif s_op = x"30" then				-- cmpgtui operation
			op_alu <= "011110";
		else op_alu <= "000000";			-- undefined alu operations (br, call)
		end if;
	end process;
		
	-- transition logic
	next_state <= FETCH2 when cur_state = FETCH1 else
			  	  DECODE when cur_state = FETCH2 else
			  	  R_OP   when cur_state = DECODE and s_op = x"3A"
			 								     and (s_opx = x"31" 
			 								     or   s_opx = x"39"
			 								     or   s_opx = x"08"
			 								     or   s_opx = x"10"
			 								     or   s_opx = x"06"
			 								     or   s_opx = x"0E"
			 								     or   s_opx = x"16"
			 								     or   s_opx = x"1E"
			 								     or   s_opx = x"13"
			 								     or   s_opx = x"1B"
			 								     or   s_opx = x"3B"
			 								     or   s_opx = x"18"
			 								     or   s_opx = x"20"
			 								     or   s_opx = x"28"
			 								     or   s_opx = x"30"
			 								     or   s_opx = x"03"
			 								     or   s_opx = x"0B") else
			  	  RI_OP   when cur_state = DECODE and s_op = x"3A"
			 								     and (s_opx = x"12" 
			 								     or   s_opx = x"1A"
			 								     or   s_opx = x"3A"
			 								     or   s_opx = x"02") else
			  	  STORE  when cur_state = DECODE and s_op = x"15" else
			  	  BREAK  when cur_state = DECODE and s_op = x"3A" 
			 									 and s_opx = x"34" else
			  	  BREAK  when cur_state = BREAK  else
			  	  LOAD1  when cur_state = DECODE and s_op = x"17" else
			  	  LOAD2  when cur_state = LOAD1  else
			 	  I_OP   when cur_state = DECODE and (s_op = x"04"
			 	  								   or s_op = x"08"
			 	  								   or s_op = x"10"
			 	  								   or s_op = x"18"
			 	  								   or s_op = x"20") else
			 	  UI_OP  when cur_state = DECODE and (s_op = x"0C"
			 	  								   or s_op = x"14"		
			 	  								   or s_op = x"1C"
			 	  								   or s_op = x"28"
			 	  								   or s_op = x"30") else 
			 	  BRANCH when cur_state = DECODE and (s_op = x"06"
			 	  								 or s_op = x"0E"
			 	  								 or s_op = x"16"
			 	  								 or s_op = x"1E"
			 	  								 or s_op = x"26"
			 	  								 or s_op = x"2E"
			 	  								 or s_op = x"36")
			 	  								 else
			 	  CALL 	 when cur_state = DECODE and s_op = x"00" else
			 	  CALLR  when cur_state = DECODE and s_op = x"3A" 
			 	  								 and s_opx = x"1D" else
			 	  JMP 	 when cur_state = DECODE and s_op = x"3A"
			 	  								 and (s_opx = x"0D" 
			 	  								  or s_opx = x"05") else
			 	  JMPI   when cur_state = DECODE and s_op = x"01" else
			  	  FETCH1 when cur_state = R_OP
			 			   or cur_state = RI_OP
			 			   or cur_state = STORE
			 			   or cur_state = LOAD2
			 			   or cur_state = I_OP
			 			   or cur_state = UI_OP
			 			   or cur_state = BRANCH
			 			   or cur_state = CALL
			 			   or cur_state = CALLR
			 			   or cur_state = JMP
			 			   or cur_state = JMPI;
			 			   	
	-- output logic
	-- activates branch condition
    branch_op  <= '1' when cur_state = BRANCH else '0';
        
    -- immediate value sign extension
	imm_signed <= '1' when cur_state = I_OP -- to be changed
	                    or cur_state = LOAD1 
	                    or cur_state = STORE else '0';
	                    
	-- instruction register enable
	ir_en 	   <= '1' when cur_state = FETCH2 else '0'; -- enable instruction
	
	-- pc control signals
	pc_en 	   <= '1' when cur_state = FETCH2  			-- enable increment address by 4
						or (cur_state = BRANCH and s_op = x"06")
						or cur_state = CALL 
						or cur_state = CALLR
						or cur_state = JMP 
						or cur_state = JMPI else '0';
	pc_add_imm <= '1' when cur_state = BRANCH else '0';	-- enable pc when branch state
	pc_sel_imm <= '1' when cur_state = CALL 
						or cur_state = JMPI else '0';	-- enable pc when call state
	pc_sel_a   <= '1' when cur_state = CALLR 
						or cur_state = JMP else '0'; 	-- take a rather then imm 
	
	-- register file enable
	rf_wren    <= '1' when cur_state = I_OP 
					 	or cur_state = UI_OP
					 	or cur_state = R_OP
					 	or cur_state = RI_OP
					 	or cur_state = LOAD2
					 	or cur_state = CALL 
					 	or cur_state = CALLR else '0';  -- enable write into register
					 
	-- multiplexers selections
	sel_addr   <= '1' when cur_state = LOAD1 
					  	or cur_state = STORE else '0';  -- read at ALU-specified address
	sel_b 	   <= '1' when cur_state = R_OP 
						or cur_state = BRANCH else '0'; -- select second operand (immediate or from register)
	sel_mem    <= '1' when cur_state = LOAD2 else '0';  -- write from memory (and not from ALU) into register
	sel_pc 	   <= '1' when cur_state = CALL 
						or cur_state = CALLR else '0';	-- select address rather then alu
	sel_ra 	   <= '1' when cur_state = CALL 
						or cur_state = CALLR else '0';	-- select write address
	sel_rC     <= '1' when cur_state = R_OP
						or cur_state = RI_OP else '0';   -- select write address
	
	-- read/write from/to memory
	read 	   <= '1' when cur_state = FETCH1   		-- ready to read from memory
				  		or cur_state = LOAD1 else '0';
	write      <= '1' when cur_state = STORE else '0';  -- write to memory
		
end synth;
