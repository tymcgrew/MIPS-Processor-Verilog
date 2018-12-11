module ProcessorProgramCounter(clk, rst, in, offsetOrJump, out, wren);

input rst, clk;
input wren;
input [7:0]in;
input offsetOrJump;

output [7:0]out;
reg [7:0]out;

always@(posedge clk or negedge rst)
begin

	if (rst == 1'b0)
		out <= 8'd0;
		
	else if (wren == 1'b1)
	begin
		if (offsetOrJump == 1'b1)
			out <= out + in;
		else
			out <= in;	
	end

end

endmodule