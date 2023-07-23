module CLock
(
	input  wire 	  CLK, // 1KHz
	input  wire 	  rst_n,
	input  wire       rst_counters,
	input  wire       enc_sec,
	input  wire	 	  en,
	input  wire       i_time_format,
	output wire [7:0] seconds,
	output wire [7:0] mins,
	output wire [7:0] hrs,
	output reg        Valid
);

wire       sec_plus_one;
wire 	   count_up_min;
wire 	   count_up_hr;
wire [7:0] hrs_12;
wire [7:0] hrs_24;

mux2X1 MUX (
	.i0(hrs_12),
	.i1(hrs_24),
	.sel(i_time_format),
	.out(hrs)
);

clk_count_sec SEC (
	.CLK(CLK), // 1KHz
	.rst_n(rst_n),
	.rst_counters(rst_counters),
	.enc_sec(enc_sec),
	.en(en),
	.sec_plus_one(sec_plus_one),
	.count_up_min(count_up_min),
	.seconds(seconds)
);

clk_count_min MINS (
	.CLK(CLK), // 1KHz
	.rst_n(rst_n),
	.rst_counters(rst_counters),
	.count_up_min(count_up_min),
	.count_up_hr(count_up_hr),
	.mins(mins)
);

clk_count_hr_12 HRS_12 (
	.CLK(CLK), // 1KHz
	.rst_n(rst_n),
	.rst_counters(rst_counters),
	.count_up_hr(count_up_hr),
	.hr_12(hrs_12)
);

clk_count_hr_24 HRS_24 (
	.CLK(CLK), // 1KHz
	.rst_n(rst_n),
	.rst_counters(rst_counters),
	.count_up_hr(count_up_hr),
	.hr_24(hrs_24)
);

always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		Valid <= 1'b0;
	end
	else if (enc_sec || sec_plus_one || count_up_min || count_up_hr || rst_counters) begin
		Valid <= 1'b1;
	end
	else begin
		Valid <= 1'b0;
	end
end

endmodule