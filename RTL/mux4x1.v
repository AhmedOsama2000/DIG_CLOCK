module mux4X1
(
	input  wire [7:0] i0,
	input  wire [7:0] i1,
	input  wire [7:0] i2,
	input  wire [1:0] sel,
	output reg  [7:0] out
);

always @(*) begin
	if (sel == 2'b00) begin
		out = i0;
	end
	else if (sel == 2'b01) begin
		out = i1;
	end
	else if (sel == 2'b10) begin
		out = i2;
	end
	else begin
		out = i0;
	end
end

endmodule