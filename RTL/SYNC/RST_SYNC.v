module RST_SYNC (
	input  wire CLK,
	input  wire rst_n,
	output reg  sync_rst_n
);

reg [1:0] NFFS;

always @(posedge CLK, negedge rst_n) begin

	if (!rst_n) begin
		NFFS  <= 0;
	end
	else begin
		NFFS <= {1'b1,NFFS[1]};
	end

end

always @(*) begin
	sync_rst_n = NFFS[0];
end

endmodule