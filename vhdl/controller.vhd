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
begin
	

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
	operation : process(op, opx) 	-- to be completed later on 
	begin
		case op is 
			-- R-type operations	
			when "111010" => 
				case opx is 
					when "110001" => op_alu <= "000100";  		-- add operation  
					when "111001" => op_alu <= "001000"; 		-- sub operation
					when "001000" => op_alu <= "011001"; 		-- cmple operation
					when "010000" => op_alu <= "011010"; 		-- cmpgt operation
					when "000110" => op_alu <= "100000"; 		-- nor operation
					when "001110" => op_alu <= "100001"; 		-- and operation
					when "010110" => op_alu <= "100010"; 		-- or operation
					when "011110" => op_alu <= "100011"; 		-- xnor operation
					when "010011" => op_alu <= "110010"; 		-- sll operation
					when "011011" => op_alu <= "110011"; 		-- srl operation
					when "111011" => op_alu <= "111111"; 		-- sra operation
					when "010010" => op_alu <= "111010"; 		-- slli operation
					when "011010" => op_alu <= "111011"; 		-- srli operation
					when "111010" => op_alu <= "111111"; 		-- srai operation
					when "011000" => op_alu <= "011011"; 		-- cmpne operation
					when "100000" => op_alu <= "011100"; 		-- cmpeq operation
					when "101000" => op_alu <= "011101"; 		-- cmpleu operation
					when "110000" => op_alu <= "011110"; 		-- cmpgtu operation
					when "000011" => op_alu <= "111000"; 		-- rol operation
					when "001011" => op_alu <= "111001"; 		-- ror operation
					when "000010" => op_alu <= "111000"; 		-- roli operation
					when others => op_alu <= "000000";
				end case;
		
		-- I-type operations
			when "010111" => op_alu <= "000100"; 			-- ldw and stw
			when "010101" => op_alu <= "000100"; 			-- ldw and stw
			when "000110" => op_alu <= "011100";				-- ble operation
			when "001110" => op_alu <= "011001";				-- ble operation
			when "010110" => op_alu <= "011010";				-- bgt operation
			when "011110" => op_alu <= "011011";				-- bne operation
			when "100110" => op_alu <= "011100";				-- beq operation
			when "101110" => op_alu <= "011101"; 			-- bleu operation
			when "110110" => op_alu <= "011110";				-- bgtu operation
			when "000100" => op_alu <= "000100";				-- addi operation
			when "001100" => op_alu <= "100001";				-- andi operation
			when "010100" => op_alu <= "100010";				-- ori operation
			when "011100" => op_alu <= "100011";				-- xnori operation
			when "001000" => op_alu <= "011001";				-- cmplei operation
			when "010000" => op_alu <= "011010";				-- cmpgti operation
			when "011000" => op_alu <= "011011";				-- cmpnei operation
			when "100000" => op_alu <= "011100";				-- cmpeqi operation
			when "101000" => op_alu <= "011101";				-- cmpleui operation
			when "110000" => op_alu <= "011110";				-- cmpgtui operation
			when others => op_alu <= "000000";			-- undefined alu operations (br, call)
		end case;
	end process;
		
	-- transition logic
	next_state <= FETCH2 when cur_state = FETCH1 else
			  	  DECODE when cur_state = FETCH2 else
			  	  R_OP   when cur_state = DECODE and op = "111010"
			 								     and (opx = "110001" 
			 								     or   opx = "111001"
			 								     or   opx = "001000"
			 								     or   opx = "010000"
			 								     or   opx = "000110"
			 								     or   opx = "001110"
			 								     or   opx = "010110"
			 								     or   opx = "011110"
			 								     or   opx = "010011"
			 								     or   opx = "011011"
			 								     or   opx = "111011"
			 								     or   opx = "011000"
			 								     or   opx = "100000"
			 								     or   opx = "101000"
			 								     or   opx = "110000"
			 								     or   opx = "000011"
			 								     or   opx = "001011") else
			  	  RI_OP   when cur_state = DECODE and op = "111010"
			 								     and (opx = "010010" 
			 								     or   opx = "011010"
			 								     or   opx = "111010"
			 								     or   opx = "000010") else
			  	  STORE  when cur_state = DECODE and op = "010101" else
			  	  BREAK  when cur_state = DECODE and op = "111010" 
			 									 and opx = "110100" else
			  	  BREAK  when cur_state = BREAK  else
			  	  LOAD1  when cur_state = DECODE and op = "010111" else
			  	  LOAD2  when cur_state = LOAD1  else
			 	  I_OP   when cur_state = DECODE and (op = "000100"
			 	  								   or op = "001000"
			 	  								   or op = "010000"
			 	  								   or op = "011000"
			 	  								   or op = "100000") else
			 	  UI_OP  when cur_state = DECODE and (op = "001100"
			 	  								   or op = "010100"		
			 	  								   or op = "011100"
			 	  								   or op = "101000"
			 	  								   or op = "110000") else 
			 	  BRANCH when cur_state = DECODE and (op = "000110"
			 	  								 or op = "001110"
			 	  								 or op = "010110"
			 	  								 or op = "011110"
			 	  								 or op = "100110"
			 	  								 or op = "101110"
			 	  								 or op = "110110")
			 	  								 else
			 	  CALL 	 when cur_state = DECODE and op = "000000" else
			 	  CALLR  when cur_state = DECODE and op = "111010" 
			 	  								 and opx = "011101" else
			 	  JMP 	 when cur_state = DECODE and op = "111010"
			 	  								 and (opx = "001101" 
			 	  								  or opx = "000101") else
			 	  JMPI   when cur_state = DECODE and op = "000001" else
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
