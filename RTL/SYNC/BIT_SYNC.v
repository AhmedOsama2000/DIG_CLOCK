module BIT_SYNC (
	input  wire  CLK,
	input  wire  rst_n,
	input  wire  Async,
	output wire  Sync
);

// Number of stages
reg [1:0] NFFS;

always @(posedge CLK , negedge rst_n) begin
	if(!rst_n) begin
		NFFS <= 2'b00;
	end
	else begin			
		NFFS <= {Async,NFFS[1]};
	end
end

assign Sync = NFFS[0];

endmodule