module stp_count_hr_24
(
	input  wire 	  CLK,
	input  wire 	  rst_n,
	input  wire       stop,
	input  wire       rst_counters,
	input  wire       count_up_hr,
	output reg  [7:0] hr_24
);

always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		hr_24 <= 8'b0;
	end
	else if (stop || rst_counters) begin
	   hr_24  <= 8'b0;
	end
	else if (hr_24 == 8'd23 && count_up_hr) begin
		hr_24 <= 8'b0;
	end
	else if (count_up_hr) begin
		hr_24 <= hr_24 + 1'b1;
    end
end

endmodule