module BUS_SYNC (
	input  wire 	   CLK,
	input  wire 	   rst_n,
	input  wire        EN,
	input  wire [23:0] Async,
	output reg  [23:0] Sync
);

always @(posedge CLK , negedge rst_n) begin
	if(!rst_n) begin
		Sync <= 24'b0;
	end
	else if (EN) begin
		Sync <= Async;
	end
end

endmodule