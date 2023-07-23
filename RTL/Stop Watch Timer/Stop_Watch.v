module Stop_Watch
(
	input  wire 	  CLK, // 1KHz
	input  wire 	  rst_n,
	input  wire	 	  en,
	input  wire       stop,
	input  wire       rst_counters,
	output wire [7:0] seconds,
	output wire [7:0] mins,
	output wire [7:0] hrs,
	output reg        Valid
);

wire sec_plus_one;
wire count_up_min;
wire count_up_hr;

stp_count_sec SEC (
	.CLK(CLK), // 1KHz
	.rst_n(rst_n),
	.stop(stop),
	.rst_counters(rst_counters),
	.en(en),
	.sec_plus_one(sec_plus_one),
	.count_up_min(count_up_min),
	.seconds(seconds)
);

stp_count_min MINS (
	.CLK(CLK), // 1KHz
	.rst_n(rst_n),
	.stop(stop),
	.rst_counters(rst_counters),
	.count_up_min(count_up_min),
	.count_up_hr(count_up_hr),
	.mins(mins)
);

stp_count_hr_24 HRS_24 (
	.CLK(CLK), // 1KHz
	.rst_n(rst_n),
	.stop(stop),
	.rst_counters(rst_counters),
	.count_up_hr(count_up_hr),
	.hr_24(hrs)
);

always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		Valid <= 1'b0;
	end
	else if (stop || sec_plus_one || count_up_min || count_up_hr || rst_counters) begin
		Valid <= 1'b1;
	end
	else begin
		Valid <= 1'b0;
	end
end

endmodule