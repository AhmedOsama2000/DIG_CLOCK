module clk_count_hr_12
(
	input  wire 	  CLK,
	input  wire 	  rst_n,
	input  wire       rst_counters,
	input  wire       count_up_hr,
	output reg  [7:0] hr_12
);

always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		hr_12 <= 8'b0;
	end
	else if (rst_counters) begin
	    hr_12 <= 8'b0;
    end
	else if (hr_12 == 8'd11 && count_up_hr) begin
		hr_12 <= 8'b0;
	end
	else if (count_up_hr) begin
		hr_12 <= hr_12 + 1'b1;
    end
end

endmodule