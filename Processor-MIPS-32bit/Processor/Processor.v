module Processor(rst, clk, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, SW, button);

input clk, rst;

output signed [0:6]HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
reg signed [0:6]HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;

input [15:0]SW;
input button;

// Control
wire Reg32_rden_a;
wire Reg32_rden_b;
wire Reg32_wren_a;
wire [1:0]Reg32_inMux;
wire [4:0]Reg32_address_a;
wire [4:0]Reg32_address_b;

wire ALU_wren;
wire [15:0]controlToALU_out;
wire [1:0]ALU_status;
wire [2:0]ALU_op;
wire ALU_inMux;

wire Mem_wren;
wire Mem_rdaddress_in;
wire [7:0]Mem_rdaddress;

wire out_update;
wire button;

wire PC_wren;
wire [7:0]controlToPC_out;
wire PC_offsetOrJump;

wire InstructionReg_wren;

// Reg32
wire signed [31:0]Reg32_out_a;
wire [31:0]Reg32_out_b;
reg [31:0]Reg32_in_a;

// ALU
wire [31:0]ALU_out;
wire [31:0]ALU_in_b;

//Memory
wire [31:0]Mem_out;
wire [7:0]rdAddress;

//PC
wire [7:0]PC_out;

//Instruction Register
wire [31:0]InstructionReg_out;

always@(*)
	case(Reg32_inMux)
		2'b00: Reg32_in_a = Mem_out;
		2'b01: Reg32_in_a = {{16{SW[15]}}, SW};
		2'b10: Reg32_in_a = {24'd0, PC_out + 8'd1};
		2'b11: Reg32_in_a = ALU_out;
	endcase

wire [7:0]mem_addr;
assign mem_addr = controlToALU_out[7:0] + Reg32_out_b[7:0];
assign ALU_in_b = ALU_inMux? Reg32_out_b : {{16{controlToALU_out[15]}},controlToALU_out};
assign Mem_rdaddress = Mem_rdaddress_in? PC_out : mem_addr;

ProcessorControl Control(
	clk, 
	rst, 
	InstructionReg_out, //instruction
	Reg32_rden_a,
	Reg32_rden_b,
	Reg32_wren_a,
	Reg32_address_a,
	Reg32_address_b,
	Reg32_inMux,
	ALU_wren,
	controlToALU_out,
	ALU_status,
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
	
ProcessorReg32 Reg32(
	Reg32_address_a,
	Reg32_address_b,
	clk,
	Reg32_in_a,
	32'd0,
	Reg32_rden_a,
	Reg32_rden_b,
	Reg32_wren_a,
	1'b0,
	Reg32_out_a,
	Reg32_out_b
	);
	
ProcessorALU ALU(
	clk,
	rst,
	Reg32_out_a,
	ALU_in_b,
	ALU_op,
	ALU_wren,
	ALU_status,
	ALU_out
	);
	
ProcessorMem Mem(
	clk,
	Reg32_out_a,
	Mem_rdaddress,
	1'b1,
	mem_addr,
	Mem_wren,
	Mem_out
	);
	
ProcessorProgramCounter PC(
	clk,
	rst,
	controlToPC_out,
	PC_offsetOrJump,
	PC_out,
	PC_wren
	);
	
ProcessorInstructionReg InstructionReg(
	clk,
	rst,
	Mem_out,
	InstructionReg_out,
	InstructionReg_wren
	);
	
reg signed [31:0] num;
reg signed [3:0]ones, tens, hundreds, thousands, tenthousands, hundredthousands, millions;
reg signed sign;
always@(posedge clk)
begin
	if (Reg32_out_a[31] == 1'b1)
	begin
		num <= (32'sb11111111111111111111111111111111 * Reg32_out_a);
		sign <= 1'b1;
	end
	else
	begin
		num <= (32'sb00000000000000000000000000000001 * Reg32_out_a);
		sign <= 1'b0;
	end
	ones <= num % 32'sd10;
	tens <= (num%32'sd100)/32'sd10;
	hundreds <= (num%32'sd1000)/32'sd100;
	thousands <= (num%32'sd10000)/32'sd1000;
	tenthousands <= (num%32'sd100000)/32'sd10000;
	hundredthousands <= (num%32'sd1000000)/32'sd100000;
	millions <= (num%32'sd10000000)/32'sd1000000;
end

always@(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		HEX0 <= 7'b0000001;
		HEX1 <= 7'b0000001;
		HEX2 <= 7'b0000001;
		HEX3 <= 7'b0000001;
		HEX4 <= 7'b0000001;
		HEX5 <= 7'b0000001;
		HEX6 <= 7'b0000001;
		HEX7 <= 7'b1111111;
	end
	
	else if (out_update == 1'b1)
	begin
		case (ones)
			4'd0: HEX0 <= 7'b0000001;
			4'd1: HEX0 <= 7'b1001111;
			4'd2: HEX0 <= 7'b0010010;
			4'd3: HEX0 <= 7'b0000110;
			4'd4: HEX0 <= 7'b1001100;
			4'd5: HEX0 <= 7'b0100100;
			4'd6: HEX0 <= 7'b0100000;
			4'd7: HEX0 <= 7'b0001111;
			4'd8: HEX0 <= 7'b0000000;
			4'd9: HEX0 <= 7'b0001100;
			default: HEX0 <= 7'b0110000;
		endcase
		case (tens)
			4'd0: HEX1 <= 7'b0000001;
			4'd1: HEX1 <= 7'b1001111;
			4'd2: HEX1 <= 7'b0010010;
			4'd3: HEX1 <= 7'b0000110;
			4'd4: HEX1 <= 7'b1001100;
			4'd5: HEX1 <= 7'b0100100;
			4'd6: HEX1 <= 7'b0100000;
			4'd7: HEX1 <= 7'b0001111;
			4'd8: HEX1 <= 7'b0000000;
			4'd9: HEX1 <= 7'b0001100;
			default: HEX1 <= 7'b0110000;
		endcase
		case (hundreds)
			4'd0: HEX2 <= 7'b0000001;
			4'd1: HEX2 <= 7'b1001111;
			4'd2: HEX2 <= 7'b0010010;
			4'd3: HEX2 <= 7'b0000110;
			4'd4: HEX2 <= 7'b1001100;
			4'd5: HEX2 <= 7'b0100100;
			4'd6: HEX2 <= 7'b0100000;
			4'd7: HEX2 <= 7'b0001111;
			4'd8: HEX2 <= 7'b0000000;
			4'd9: HEX2 <= 7'b0001100;
			default: HEX2 <= 7'b0110000;
		endcase
		case (thousands)
			4'd0: HEX3 <= 7'b0000001;
			4'd1: HEX3 <= 7'b1001111;
			4'd2: HEX3 <= 7'b0010010;
			4'd3: HEX3 <= 7'b0000110;
			4'd4: HEX3 <= 7'b1001100;
			4'd5: HEX3 <= 7'b0100100;
			4'd6: HEX3 <= 7'b0100000;
			4'd7: HEX3 <= 7'b0001111;
			4'd8: HEX3 <= 7'b0000000;
			4'd9: HEX3 <= 7'b0001100;
			default: HEX3 <= 7'b0110000;
		endcase
		case (tenthousands)
			4'd0: HEX4 <= 7'b0000001;
			4'd1: HEX4 <= 7'b1001111;
			4'd2: HEX4 <= 7'b0010010;
			4'd3: HEX4 <= 7'b0000110;
			4'd4: HEX4 <= 7'b1001100;
			4'd5: HEX4 <= 7'b0100100;
			4'd6: HEX4 <= 7'b0100000;
			4'd7: HEX4 <= 7'b0001111;
			4'd8: HEX4 <= 7'b0000000;
			4'd9: HEX4 <= 7'b0001100;
			default: HEX4 <= 7'b0110000;
		endcase
		case (hundredthousands)
			4'd0: HEX5 <= 7'b0000001;
			4'd1: HEX5 <= 7'b1001111;
			4'd2: HEX5 <= 7'b0010010;
			4'd3: HEX5 <= 7'b0000110;
			4'd4: HEX5 <= 7'b1001100;
			4'd5: HEX5 <= 7'b0100100;
			4'd6: HEX5 <= 7'b0100000;
			4'd7: HEX5 <= 7'b0001111;
			4'd8: HEX5 <= 7'b0000000;
			4'd9: HEX5 <= 7'b0001100;
			default: HEX5 <= 7'b0110000;
		endcase
		case (millions)
			4'd0: HEX6 <= 7'b0000001;
			4'd1: HEX6 <= 7'b1001111;
			4'd2: HEX6 <= 7'b0010010;
			4'd3: HEX6 <= 7'b0000110;
			4'd4: HEX6 <= 7'b1001100;
			4'd5: HEX6 <= 7'b0100100;
			4'd6: HEX6 <= 7'b0100000;
			4'd7: HEX6 <= 7'b0001111;
			4'd8: HEX6 <= 7'b0000000;
			4'd9: HEX6 <= 7'b0001100;
			default: HEX6 <= 7'b0110000;
		endcase
		case (sign)
			1'sb1: HEX7 <= 7'b1111110;
			1'sb0: HEX7 <= 7'b1111111;
		endcase
	end
end
	
endmodule