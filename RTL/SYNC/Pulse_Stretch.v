module Pulse_Stretch
(
	input  wire CLK,
	input  wire rst_n,
	input  wire Async,
	output wire pulse
);

// Number of stages
reg [2:0] NFFS;

always @(posedge CLK , negedge rst_n) begin
	if(!rst_n) begin
		NFFS <= 5'b0;
	end
	else begin
		NFFS <= {Async,NFFS[2:1]};
	end
end

assign pulse = NFFS[2] | NFFS[1] | NFFS[0];

endmodule