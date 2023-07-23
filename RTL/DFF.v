module DFF (
	input  wire CLK,
	input  wire rst_n,
	input  wire D,
	output reg  Q
);

always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		Q <= 1'b0;
	end
	else begin
		Q <= D;
	end
end
endmodule