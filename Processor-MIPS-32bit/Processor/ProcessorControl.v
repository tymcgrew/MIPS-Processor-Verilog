module ProcessorControl(
	clk,
	rst, 
	
	instruction,
	
	Reg32_rden_a,
	Reg32_rden_b,
	Reg32_wren_a,
	Reg32_address_a,
	Reg32_address_b,
	Reg32_inMux,
	
	ALU_wren,
	controlToALU_out,
	status,
	ALU_op,
	ALU_inMux,
	
	Mem_rdaddress_in,
	Mem_wren,
	
	Reg32_out_a,
	
	out_update,
	
	button,
	
	PC_wren,
	controlToPC_out,
	PC_offsetOrJump,
	
	InstructionReg_wren
);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------

	input clk, rst;
	input [31:0]instruction;
	
	output Reg32_rden_a, Reg32_rden_b, Reg32_wren_a;
	output [4:0]Reg32_address_a, Reg32_address_b;
	output [1:0]Reg32_inMux;
	reg Reg32_rden_a, Reg32_rden_b, Reg32_wren_a;
	reg [4:0]Reg32_address_a, Reg32_address_b;
	reg [1:0]Reg32_inMux;
	
	input [1:0]status;	
	output [15:0]controlToALU_out;
	output ALU_wren;
	output [2:0]ALU_op;
	output ALU_inMux;
	reg [15:0]controlToALU_out;
	reg ALU_wren;
	reg [2:0]ALU_op;
	reg ALU_inMux;
	
	output Mem_rdaddress_in;
	output Mem_wren;
	reg Mem_rdaddress_in;
	reg Mem_wren;
	
	input [31:0]Reg32_out_a;
	
	output out_update;
	reg out_update;
	input button;
	
	output PC_wren;
	output [7:0]controlToPC_out;
	output PC_offsetOrJump;
	reg PC_wren;
	reg [7:0]controlToPC_out;
	reg PC_offsetOrJump;
	
	output InstructionReg_wren;
	reg InstructionReg_wren;

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

reg [7:0]target;
reg [26:0]counter;
reg [31:0]Reg32toControl;

parameter START = 7'd0,
          FETCH1 = 7'd1,
          FETCH2 = 7'd2,
          FETCH3 = 7'd3,
          DECODE = 7'd4,
          ADDU1 = 7'd5,
          ADDU2 = 7'd6,
          ADDU3 = 7'd7,
          ADDU4 = 7'd8,
          SUBU1 = 7'd9,
          SUBU2 = 7'd10,
          SUBU3 = 7'd11,
          SUBU4 = 7'd12,
          ADDIU1 = 7'd13,
          ADDIU2 = 7'd14,
          ADDIU3 = 7'd15,
          ADDIU4 = 7'd16,
          AND1 = 7'd17,
          AND2 = 7'd18,
          AND3 = 7'd19,
          AND4 = 7'd20,
          OR1 = 7'd21,
          OR2 = 7'd22,
          OR3 = 7'd23,
          OR4 = 7'd24,
          ANDI1 = 7'd25,
          ANDI2 = 7'd26,
          ANDI3 = 7'd27,
          ANDI4 = 7'd28,
          ORI1 = 7'd29,
          ORI2 = 7'd30,
          ORI3 = 7'd31,
          ORI4 = 7'd32,
          LW1 = 7'd33,
          LW2 = 7'd34,
          SW1 = 7'd35,
          SW2 = 7'd36,
          BEQ1 = 7'd37,
          BEQ2 = 7'd38,
          BNE1 = 7'd39,
          BNE2 = 7'd40,
          J = 7'd41,
          JR1 = 7'd42,
          JR2 = 7'd43,
          JAL1 = 7'd44,
          JAL2 = 7'd45,
          BLTZ1 = 7'd46,
          BLTZ2 = 7'd47,
          SLT1 = 7'd48,
          SLT2 = 7'd49,
          SLT3 = 7'd50,
          SLT4 = 7'd51,
          SLT5 = 7'd52,
          SLT6 = 7'd53,
          SYSCALL1 = 7'd54,
          SYSCALL2 = 7'd55,
          PRINTINT1 = 7'd56,
          PRINTINT2 = 7'd57,
          READINT1 = 7'd58,
          READINT2 = 7'd59,
          READINT3 = 7'd60,
          SLEEP1 = 7'd61,
          SLEEP2 = 7'd62,
          SLEEP3 = 7'd63,
          SLEEP4 = 7'd64,
          EXIT = 7'd65,
          INCREMENTPC1 = 7'd66,
          INCREMENTPC2 = 7'd67,
          JUMP1 = 7'd68,
          JUMP2 = 7'd69,
          BRANCH1 = 7'd70,
          BRANCH2 = 7'd71;

reg [6:0]STATE, NEXT_STATE;

parameter add = 3'd0,
			 sub = 3'd1,
			 aand = 3'd2,
			 oor = 3'd3,
			 nnot = 3'd4;
			 

//------------------------------------------------------------------
//                 -- Begin Declarations & Coding --                  
//------------------------------------------------------------------

always@(posedge clk or negedge rst)     // Determine STATE
begin

	if (rst == 1'b0)
		STATE <= START;
	else
		STATE <= NEXT_STATE;

end


always@(*)                              // Determine NEXT_STATE
begin
	case(STATE)

	START:
	begin
		NEXT_STATE = FETCH1;
	end

	FETCH1:
	begin
		if (counter < 27'd10000000)
			NEXT_STATE = FETCH1;
		else
			NEXT_STATE = FETCH2;
	end

	FETCH2:
	begin
		NEXT_STATE = FETCH3;
	end

	FETCH3:
	begin
		if (counter < 2'd3)
			NEXT_STATE = FETCH3;
		else
			NEXT_STATE = DECODE;
	end

	DECODE:
	begin
		if (instruction[31:26] == 6'b000000 && (instruction[5:0] == 6'b100000 || instruction[5:0] == 6'b100001))
			NEXT_STATE = ADDU1;
		else if (instruction[31:26] == 6'b000000 && (instruction[5:0] == 6'b100010 || instruction[5:0] == 6'b100011))
			NEXT_STATE = SUBU1;
		else if (instruction[31:26] == 6'b001000 || instruction[31:26] == 6'b001001)
			NEXT_STATE = ADDIU1;
		else if (instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100100)
			NEXT_STATE = AND1;
		else if (instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100101)
			NEXT_STATE = OR1;
		else if (instruction[31:26] == 6'b001100)
			NEXT_STATE = ANDI1;
		else if (instruction[31:26] == 6'b001101)
			NEXT_STATE = ORI1;
		else if (instruction[31:26] == 6'b100011)
			NEXT_STATE = LW1;
		else if (instruction[31:26] == 6'b101011)
			NEXT_STATE = SW1;
		else if (instruction[31:26] == 6'b000100)
			NEXT_STATE = BEQ1;
		else if (instruction[31:26] == 6'b000101)
			NEXT_STATE = BNE1;
		else if (instruction[31:26] == 6'b000010)
			NEXT_STATE = J;
		else if (instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b001000)
			NEXT_STATE = JR1;
		else if (instruction[31:26] == 6'b000011)
			NEXT_STATE = JAL1;
		else if (instruction[31:26] == 6'b000001 && instruction[20:16] == 5'b00000)
			NEXT_STATE = BLTZ1;
		else if (instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b101010)
			NEXT_STATE = SLT1;
		else if (instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b001100)
			NEXT_STATE = SYSCALL1;
		else
			NEXT_STATE = EXIT;
	end

ADDU1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = ADDU1;
		else
			NEXT_STATE = ADDU2;
	end

	ADDU2:
	begin
		NEXT_STATE = ADDU3;
	end

	ADDU3:
	begin
		if (counter < 2'd3)
			NEXT_STATE = ADDU3;
		else
			NEXT_STATE = ADDU4;
	end

	ADDU4:
	begin
		NEXT_STATE = INCREMENTPC1;
	end

	SUBU1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = SUBU1;
		else
			NEXT_STATE = SUBU2;
	end

	SUBU2:
	begin
		NEXT_STATE = SUBU3;
	end

	SUBU3:
	begin
		if (counter < 2'd3)
			NEXT_STATE = SUBU3;
		else
			NEXT_STATE = SUBU4;
	end

	SUBU4:
	begin
		NEXT_STATE = INCREMENTPC1;
	end

	ADDIU1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = ADDIU1;
		else
			NEXT_STATE = ADDIU2;
	end

	ADDIU2:
	begin
		NEXT_STATE = ADDIU3;
	end

	ADDIU3:
	begin
		if (counter < 2'd3)
			NEXT_STATE = ADDIU3;
		else
			NEXT_STATE = ADDIU4;
	end

	ADDIU4:
	begin
		NEXT_STATE = INCREMENTPC1;
	end

	AND1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = AND1;
		else
			NEXT_STATE = AND2;
	end

	AND2:
	begin
		NEXT_STATE = AND3;
	end

	AND3:
	begin
		if (counter < 2'd3)
			NEXT_STATE = AND3;
		else
			NEXT_STATE = AND4;
	end

	AND4:
	begin
		NEXT_STATE = INCREMENTPC1;
	end

	OR1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = OR1;
		else
			NEXT_STATE = OR2;
	end

	OR2:
	begin
		NEXT_STATE = OR3;
	end

	OR3:
	begin
		if (counter < 2'd3)
			NEXT_STATE = OR3;
		else
			NEXT_STATE = OR4;
	end

	OR4:
	begin
		NEXT_STATE = INCREMENTPC1;
	end

	ANDI1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = ANDI1;
		else
			NEXT_STATE = ANDI2;
	end

	ANDI2:
	begin
		NEXT_STATE = ANDI3;
	end

	ANDI3:
	begin
		if (counter < 2'd3)
			NEXT_STATE = ANDI3;
		else 
			NEXT_STATE = ANDI4;
	end

	ANDI4:
	begin
		NEXT_STATE = INCREMENTPC1;
	end

	ORI1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = ORI1;
		else
			NEXT_STATE = ORI2;
	end

	ORI2:
	begin
		NEXT_STATE = ORI3;
	end

	ORI3:
	begin
		if (counter < 2'd3)
			NEXT_STATE = ORI3;
		else
			NEXT_STATE = ORI4;
	end

	ORI4:
	begin
		NEXT_STATE = INCREMENTPC1;
	end

	LW1:
	begin
		if (counter < 3'd7)
			NEXT_STATE = LW1;
		else
			NEXT_STATE = LW2;
	end
	
	LW2:
	begin
		NEXT_STATE = INCREMENTPC1;
	end
	
	SW1:
	begin
		if (counter < 3'd7)
			NEXT_STATE = SW1;
		else
			NEXT_STATE = SW2;
	end
	
	SW2:
	begin
		NEXT_STATE = INCREMENTPC1;
	end

	BEQ1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = BEQ1;
		else
			NEXT_STATE = BEQ2;
	end

	BEQ2:
	begin
		if (status[1] == 1'b1)
			NEXT_STATE = BRANCH1;
		else
			NEXT_STATE = INCREMENTPC1;
	end

	BNE1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = BNE1;
		else
			NEXT_STATE = BNE2;
	end

	BNE2:
	begin
		if (status[1] == 1'b0)
			NEXT_STATE = BRANCH1;
		else
			NEXT_STATE = INCREMENTPC1;
	end

	J:
	begin
		NEXT_STATE = JUMP1;
	end

	JR1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = JR1;
		else
			NEXT_STATE = JR2;
	end

	JR2:
	begin
		NEXT_STATE = JUMP1;
	end

	JAL1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = JAL1;
		else
			NEXT_STATE = JAL2;
	end

	JAL2:
	begin
		NEXT_STATE = JUMP1;
	end

	BLTZ1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = BLTZ1;
		else
			NEXT_STATE = BLTZ2;
	end

	BLTZ2:
	begin
		if (status[0] == 1'b1)
			NEXT_STATE = BRANCH1;
		else
			NEXT_STATE = INCREMENTPC1;
	end

	SLT1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = SLT1;
		else
			NEXT_STATE = SLT2;
	end

	SLT2:
	begin
		NEXT_STATE = SLT3;
	end

	SLT3:
	begin
		if (counter < 2'd3)
			NEXT_STATE = SLT3;
		else	
			NEXT_STATE = SLT4;
	end

	SLT4:
	begin
		NEXT_STATE = SLT5;
	end

	SLT5:
	begin
		if (counter < 2'd3)
			NEXT_STATE = SLT5;
		else
			NEXT_STATE = SLT6;
	end

	SLT6:
	begin
		NEXT_STATE = INCREMENTPC1;
	end

	SYSCALL1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = SYSCALL1;
		else
			NEXT_STATE = SYSCALL2;
	end

	SYSCALL2:
	begin
		if (Reg32toControl == 32'd1)
			NEXT_STATE = PRINTINT1;
		else if (Reg32toControl == 32'd5)
			NEXT_STATE = READINT1;
		else if (Reg32toControl == 32'd32)
			NEXT_STATE = SLEEP1;
		else
			NEXT_STATE = EXIT;
	end

	PRINTINT1:
	begin
		if (counter < 3'd5)
			NEXT_STATE = PRINTINT1;
		else 
			NEXT_STATE = PRINTINT2;
	end

	PRINTINT2:
	begin
		NEXT_STATE = INCREMENTPC1;
	end

	READINT1:
	begin
		if (button == 1'b1)
			NEXT_STATE = READINT1;
		else
			NEXT_STATE = READINT2;
	end

	READINT2:
	begin
		if (counter < 27'd25000000)
			NEXT_STATE = READINT2;
		else
			NEXT_STATE = READINT3;
	end

	READINT3:
	begin
		NEXT_STATE = INCREMENTPC1;
	end

	SLEEP1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = SLEEP1;
		else
			NEXT_STATE = SLEEP2;
	end

	SLEEP2:
	begin
		NEXT_STATE = SLEEP3;
	end

	SLEEP3:
	begin
		if (counter < ({11'd0, Reg32toControl[15:0]} * 27'd50000))
			NEXT_STATE = SLEEP3;
		else
			NEXT_STATE = SLEEP4;
	end

	SLEEP4:
	begin
		NEXT_STATE = INCREMENTPC1;
	end

	EXIT:
	begin
		NEXT_STATE = EXIT;
	end

	INCREMENTPC1:
	begin
		NEXT_STATE = INCREMENTPC2;
	end

	INCREMENTPC2:
	begin
		NEXT_STATE = FETCH3;
	end

	JUMP1:
	begin
		if (counter < 2'd3)
			NEXT_STATE = JUMP1;
		else
			NEXT_STATE = JUMP2;
	end

	JUMP2:
	begin
		NEXT_STATE = FETCH3;
	end

	BRANCH1:
	begin
		NEXT_STATE = BRANCH2;
	end

	BRANCH2:
	begin
		NEXT_STATE = FETCH3;
	end

	default:
	begin
		NEXT_STATE = EXIT;
	end

	endcase
end


always@(posedge clk or negedge rst)     // Determine outputs
begin

	if (rst == 1'b0)
	begin

		Reg32_rden_a <= 1'b0;
		Reg32_rden_b <= 1'b0;
		Reg32_wren_a <= 1'b0;
		Reg32_address_a <= 5'd0;
		Reg32_address_b <= 5'd0;
		Reg32_inMux = 2'b00;
		ALU_wren <= 1'b1;
		controlToALU_out <= 16'd0;
		ALU_op <= 3'd0;
		ALU_inMux <= 1'b0;
		Mem_rdaddress_in <= 1'b1;
		Mem_wren <= 1'b0;
		PC_wren <= 1'b0;
		controlToPC_out <= 8'd0;
		PC_offsetOrJump <= 1'b0;
		InstructionReg_wren <= 1'b0;
		target <= 8'd0;
		counter <= 27'd0;
		Reg32toControl <= 32'd0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			
			Reg32_rden_a <= 1'b0;
			Reg32_rden_b <= 1'b0;
			Reg32_wren_a <= 1'b0;
			Reg32_address_a <= 5'd0;
			Reg32_address_b <= 5'd0;
			Reg32_inMux = 2'b00;
			ALU_wren <= 1'b1;
			controlToALU_out <= 16'd0;
			ALU_op <= 3'd0;
			ALU_inMux <= 1'b0;
			Mem_rdaddress_in <= 1'b1;
			Mem_wren <= 1'b0;
			PC_wren <= 1'b0;
			controlToPC_out <= 8'd0;
			PC_offsetOrJump <= 1'b0;
			InstructionReg_wren <= 1'b0;
			target <= 8'd0;
			counter <= 27'd0;
			Reg32toControl <= 32'd0;
			
		end

		FETCH1:
		begin
			counter <= counter + 1'b1;
		end

		FETCH2:
		begin
			counter <= 27'd0;
		end

		FETCH3:
		begin
			InstructionReg_wren <= 1'b1;
			counter <= counter + 1'b1;
		end

		DECODE:
		begin
			InstructionReg_wren = 1'b0;
			counter <= 27'd0;
		end

		ADDU1:
		begin
			Reg32_address_a <= instruction[25:21];
			Reg32_address_b <= instruction[20:16];
			Reg32_rden_a <= 1'b1;
			Reg32_rden_b <= 1'b1;
			ALU_wren <= 1'b1;
			ALU_op <= add;
			ALU_inMux <= 1'b1;
			counter <= counter + 1'b1;
		end

		ADDU2:
		begin
			counter <= 27'd0;
		end

		ADDU3:
		begin
			Reg32_address_b <= 5'd0;
			Reg32_rden_a <= 1'b0;
			Reg32_rden_b <= 1'b0;
			ALU_wren <= 1'b0;
			Reg32_address_a <= instruction[15:11];
			Reg32_wren_a <= 1'b1;
			Reg32_inMux <= 2'b11;
			counter <= counter + 1'b1;
		end

		ADDU4:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_wren_a <= 1'b0;
			counter <= 27'd0;
		end

		SUBU1:
		begin
			Reg32_address_a <= instruction[25:21];
			Reg32_address_b <= instruction[20:16];
			Reg32_rden_a <= 1'b1;
			Reg32_rden_b <= 1'b1;
			ALU_wren <= 1'b1;
			ALU_op <= sub;
			ALU_inMux <= 1'b1;
			counter <= counter + 1'b1;
		end

		SUBU2:
		begin
			counter <= 27'd0;
		end

		SUBU3:
		begin
			Reg32_address_b <= 5'd0;
			Reg32_rden_a <= 1'b0;
			Reg32_rden_b <= 1'b0;
			ALU_wren <= 1'b0;
			Reg32_address_a <= instruction[15:11];
			Reg32_wren_a <= 1'b1;
			Reg32_inMux <= 2'b11;
			counter <= counter + 1'b1;
		end

		SUBU4:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_wren_a <= 1'b0;
			counter <= 27'd0;
		end

		ADDIU1:
		begin
			Reg32_address_a <= instruction[25:21];
			Reg32_rden_a <= 1'b1;
			controlToALU_out <= instruction[15:0];
			ALU_inMux <= 1'b0;
			ALU_wren <= 1'b1;
			ALU_op <= add;
			counter <= counter + 1'b1;
		end

		ADDIU2:
		begin
			counter <= 27'd0;
		end

		ADDIU3:
		begin
			Reg32_rden_a <= 1'b0;
			controlToALU_out <= 16'd0;
			ALU_wren <= 1'b0;
			Reg32_wren_a <= 1'b1;
			Reg32_address_a <= instruction[20:16];
			Reg32_inMux <= 2'b11;
			counter <= counter + 1'b1;
		end

		ADDIU4:
		begin
			Reg32_wren_a <= 1'b0;
			Reg32_address_a <= 5'd0;
			counter <= 27'd0;
		end

		AND1:
		begin
			Reg32_address_a <= instruction[25:21];
			Reg32_address_b <= instruction[20:16];
			Reg32_rden_a <= 1'b1;
			Reg32_rden_b <= 1'b1;
			ALU_wren <= 1'b1;
			ALU_op <= aand;
			ALU_inMux <= 1'b1;
			counter <= counter + 1'b1;
		end

		AND2:
		begin
			counter <= 27'd0;
		end

		AND3:
		begin
			Reg32_address_b <= 5'd0;
			Reg32_rden_a <= 1'b0;
			Reg32_rden_b <= 1'b0;
			ALU_wren <= 1'b0;
			Reg32_address_a <= instruction[15:11];
			Reg32_wren_a <= 1'b1;
			Reg32_inMux <= 2'b11;
			counter <= counter + 1'b1;
		end

		AND4:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_wren_a <= 1'b0;
			counter <= 27'd0;
		end

		OR1:
		begin
			Reg32_address_a <= instruction[25:21];
			Reg32_address_b <= instruction[20:16];
			Reg32_rden_a <= 1'b1;
			Reg32_rden_b <= 1'b1;
			ALU_wren <= 1'b1;
			ALU_op <= oor;
			ALU_inMux <= 1'b1;
			counter <= counter + 1'b1;
		end

		OR2:
		begin
			counter <= 27'd0;
		end

		OR3:
		begin
			Reg32_address_b <= 5'd0;
			Reg32_rden_a <= 1'b0;
			Reg32_rden_b <= 1'b0;
			ALU_wren <= 1'b0;
			Reg32_address_a <= instruction[15:11];
			Reg32_wren_a <= 1'b1;
			Reg32_inMux <= 2'b11;
			counter <= counter + 1'b1;
		end

		OR4:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_wren_a <= 1'b0;
			counter <= 27'd0;
		end

		ANDI1:
		begin
			Reg32_address_a <= instruction[25:21];
			Reg32_rden_a <= 1'b1;
			controlToALU_out <= instruction[15:0];
			ALU_inMux <= 1'b0;
			ALU_wren <= 1'b1;
			ALU_op <= aand;
			counter <= counter + 1'b1;
		end

		ANDI2:
		begin
			counter <= 27'd0;
		end

		ANDI3:
		begin
			Reg32_rden_a <= 1'b0;
			controlToALU_out <= 16'd0;
			ALU_wren <= 1'b0;
			Reg32_wren_a <= 1'b1;
			Reg32_address_a <= instruction[20:16];
			Reg32_inMux <= 2'b11;
			counter <= counter + 1'b1;
		end

		ANDI4:
		begin
			Reg32_wren_a <= 1'b0;
			Reg32_address_a <= 5'd0;
			counter <= 27'd0;
		end

		ORI1:
		begin
			Reg32_address_a <= instruction[25:21];
			Reg32_rden_a <= 1'b1;
			controlToALU_out <= instruction[15:0];
			ALU_inMux <= 1'b0;
			ALU_wren <= 1'b1;
			ALU_op <= oor;
			counter <= counter + 1'b1;
		end

		ORI2:
		begin
			counter <= 27'd0;
		end

		ORI3:
		begin
			Reg32_rden_a <= 1'b0;
			controlToALU_out <= 16'd0;
			ALU_wren <= 1'b0;
			Reg32_wren_a <= 1'b1;
			Reg32_address_a <= instruction[20:16];
			Reg32_inMux <= 2'b11;
			counter <= counter + 1'b1;

		end

		ORI4:
		begin
			Reg32_wren_a <= 1'b0;
			Reg32_address_a <= 5'd0;
			counter <= 27'd0;
		end

		LW1:
		begin
			controlToALU_out <= instruction[7:0];
			Mem_rdaddress_in <= 1'b0;
			Reg32_address_a <= instruction[20:16];
			Reg32_wren_a <= 1'b1;
			Reg32_address_b <= instruction[25:21];
			Reg32_rden_b <= 1'b1;
			Reg32_inMux <= 2'b00;
			counter <= counter + 1'b1;
		end
		
		LW2:
		begin
			Mem_rdaddress_in <= 1'b1;
			Reg32_address_a <= 5'd0;
			Reg32_address_b <= 5'd0;
			Reg32_wren_a <= 1'b0;
			Reg32_rden_b <= 1'b0;
			counter <= 27'd0;
			controlToALU_out <= 8'd0;
		end
		
		SW1:
		begin
			controlToALU_out <= instruction[7:0];
			Mem_wren <= 1'b1;
			Reg32_address_a <= instruction[20:16];
			Reg32_rden_a <= 1'b1;
			Reg32_address_b <= instruction[25:21];
			Reg32_rden_b <= 1'b1;
			counter <= counter + 1'b1;

		end
		
		SW2:
		begin
			controlToALU_out <= 8'd0;
			Mem_wren <= 1'b0;
			Reg32_rden_a <= 1'b0;
			Reg32_rden_b <= 1'b0;
			Reg32_address_a <= 5'd0;
			Reg32_address_b <= 5'd0;
			counter <= 27'd0;
		end

		BEQ1:
		begin
			Reg32_address_a <= instruction[25:21];
			Reg32_rden_a <= 1'b1;
			Reg32_address_b <= instruction[20:16];
			Reg32_rden_b <= 1'b1;
			ALU_inMux <= 1'b1;
			ALU_wren <= 1'b1;
			counter <= counter + 1'b1;
		end

		BEQ2:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_address_b <= 5'd0;
			Reg32_rden_a <= 1'b0;
			Reg32_rden_b <= 1'b0;
			ALU_wren <= 1'b0;
			counter <= 27'd0;
		end

		BNE1:
		begin
			Reg32_address_a <= instruction[25:21];
			Reg32_rden_a <= 1'b1;
			Reg32_address_b <= instruction[20:16];
			Reg32_rden_b <= 1'b1;
			ALU_inMux <= 1'b1;
			ALU_wren <= 1'b1;
			counter <= counter + 1'b1;
		end

		BNE2:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_address_b <= 5'd0;
			Reg32_rden_a <= 1'b0;
			Reg32_rden_b <= 1'b0;
			ALU_wren <= 1'b0;
			counter <= 27'd0;
		end

		J:
		begin
			target <= instruction[7:0];
		end

		JR1:
		begin
			Reg32_address_a <= instruction[25:21];
			Reg32_rden_a <= 1'b1;
			Reg32toControl <= Reg32_out_a;
			counter <= counter + 1'b1;
		end

		JR2:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_rden_a <= 1'b0;
			counter <= 27'd0;
			target <= Reg32toControl[7:0];
		end

		JAL1:
		begin
			target <= instruction[7:0];
			Reg32_address_a <= 5'b11111;
			Reg32_wren_a <= 1'b1;
			Reg32_inMux <= 2'b10;
			counter <= counter + 1'b1;
		end

		JAL2:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_wren_a <= 1'b0;
			counter <= 27'd0;
		end

		BLTZ1:
		begin
			Reg32_address_a <= instruction[25:21];
			Reg32_rden_a <= 1'b1;
			Reg32_address_b <= 5'd0;
			Reg32_rden_b <= 1'b1;
			counter <= counter + 1'b1;
			ALU_wren <= 1'b1;
		end

		BLTZ2:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_rden_a <= 1'b0;
			Reg32_address_b <= 5'd0;
			Reg32_rden_b <= 1'b0;
			ALU_wren <= 1'b0;
			counter <= 27'd0;
		end

		SLT1:
		begin
			Reg32_address_a <= instruction[25:21];
			Reg32_address_b <= instruction[20:16];
			Reg32_rden_a <= 1'b1;
			Reg32_rden_b <= 1'b1;
			ALU_inMux <= 1'b1;
			ALU_wren <= 1'b1;
			counter <= counter + 1'b1;
		end

		SLT2:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_address_b <= 5'd0;
			Reg32_rden_a <= 1'b0;
			Reg32_rden_b <= 1'b0;
			ALU_wren <= 1'b0;
			counter <= 27'd0;
			if (status[0] == 1'b1)
				controlToALU_out <= 16'd1;
			else
				controlToALU_out <= 16'd0;
		end

		SLT3:
		begin
			Reg32_rden_a <= 1'b1;
			ALU_inMux <= 1'b0;
			ALU_op <= add;
			ALU_wren <= 1'b1;
			counter <= counter + 1'b1;
		end

		SLT4:
		begin
			counter <= 27'd0;
			controlToALU_out <= 16'd0;
			Reg32_rden_a <= 1'b0;
			ALU_wren <= 1'b0;
		end

		SLT5:
		begin
			Reg32_address_a <= instruction[15:11];
			Reg32_wren_a <= 1'b1;
			Reg32_inMux <= 2'b11;
			counter <= counter + 1'b1;
		end

		SLT6:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_wren_a <= 1'b0;
			counter <= 27'd0;
		end

		SYSCALL1:
		begin
			Reg32_address_a <= 5'd2;
			Reg32_rden_a <= 1'b1;
			counter <= counter + 1'b1;
			Reg32toControl <= Reg32_out_a;
		end

		SYSCALL2:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_rden_a <= 1'b0;
			counter <= 27'd0;
		end

		PRINTINT1:
		begin
			Reg32_address_a <= 5'd4;
			Reg32_rden_a <= 1'b1;
			out_update <= 1'b1;
			counter <= counter + 1'b1;
		end

		PRINTINT2:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_rden_a <= 1'b0;
			counter <= 27'd0;
			out_update <= 1'b0;
		end

		READINT1:
		begin
		end

		READINT2:
		begin
			Reg32_address_a <= 5'd2;
			Reg32_wren_a <= 1'b1;
			Reg32_inMux <= 2'b01;
			counter <= counter + 1'b1;
		end

		READINT3:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_wren_a <= 1'b0;
			counter <= 27'd0;
		end

		SLEEP1:
		begin
			Reg32_address_a <= 5'd4;
			Reg32_rden_a <= 1'b1;
			Reg32toControl <= Reg32_out_a;
			counter <= counter + 1'b1;
		end

		SLEEP2:
		begin
			Reg32_address_a <= 5'd0;
			Reg32_rden_a <= 1'b0;
			counter <= 27'd0;
		end

		SLEEP3:
		begin
			counter <= counter + 1'b1;
		end

		SLEEP4:
		begin
			counter <= 27'd0;
		end

		EXIT:
		begin
		end

		INCREMENTPC1:
		begin
			controlToPC_out <= 8'd1;
			PC_offsetOrJump <= 1'b1;
			PC_wren <= 1'b1;
		end

		INCREMENTPC2:
		begin
			controlToPC_out <= 8'd0;
			PC_wren <= 1'b0;
			Mem_rdaddress_in <= 1'b1;
		end

		JUMP1:
		begin
			controlToPC_out <= target;
			PC_offsetOrJump <= 1'b0;
			PC_wren <= 1'b1;
			counter <= counter + 1'b1;
		end

		JUMP2:
		begin
			controlToPC_out <= 8'd0;
			PC_wren <= 1'b0;
			counter <= 27'd0;
			Mem_rdaddress_in <= 1'b1;
		end

		BRANCH1:
		begin
			controlToPC_out <= instruction[7:0] + 8'd1;
			PC_offsetOrJump <= 1'b1;
			PC_wren <= 1'b1;
		end

		BRANCH2:
		begin
			controlToPC_out <= 8'd0;
			PC_wren <= 1'b0;
			Mem_rdaddress_in <= 1'b1;
		end

		endcase
	end

end


endmodule