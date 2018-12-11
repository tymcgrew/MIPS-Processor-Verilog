module ProcessorALU (
	clk,
	rst,
	
	in1,
	in2,
	op,
		
	wren,
	status,
	out	
);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
input [31:0]in1;
input [31:0]in2;
input [2:0]op;
input clk, rst, wren;

output [1:0]status;
output [31:0]out;
reg [1:0]status;
reg [31:0]out;


//------------------------------------------------------------------
//                 -- Begin Declarations & Coding --                  
//------------------------------------------------------------------

parameter add = 3'd0,
			 sub = 3'd1,
			 aand = 3'd2,
			 oor = 3'd3,
			 nnot = 3'd4;


always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		out <= 32'h00000000;
		status <= 2'b00;
	end
	else if (wren == 1'b1)
	begin
		case (op)
			add: out <= in1 + in2;
			sub: out <= in1 - in2;
			aand: out <= in1 & in2;
			oor: out <= in1 | in2;
			nnot: out <= ~in1;
			default: out <= in1 + in2;
		endcase
		
		if (in1 == in2)
			status[1] <= 1'b1;
		else
			status[1] <= 1'b0;
			
		if (	(in1[31] == 1'b1 && in2[31] == 1'b0) || (in1[31] == in2[31] && in1 < in2) )
			status[0] <= 1'b1;
		else
			status[0] <= 1'b0;
			
	end
	
end



endmodule