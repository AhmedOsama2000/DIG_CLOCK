module stp_count_min
(
	input  wire 	  CLK,
	input  wire 	  rst_n,
	input  wire       stop,
	input  wire       rst_counters,
	input  wire       count_up_min,
	output wire       count_up_hr,
	output reg  [7:0] mins
);

always @(posedge CLK,negedge rst_n) begin
	if (!rst_n || stop || rst_counters) begin
		mins <= 8'b0;
	end
	else if (mins == 8'd59 && count_up_min) begin
		mins <= 8'b0;
	end
	else if (count_up_min) begin
		mins <= mins + 1'b1;
    end
end

assign count_up_hr = (mins == 8'd59 && count_up_min)? 1'b1:1'b0;

endmodule