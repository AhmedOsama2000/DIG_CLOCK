module stp_count_sec
(
	input  wire 	  CLK, // 1KHz
	input  wire 	  rst_n,
	input  wire	 	  en,
	input  wire       stop,
	input  wire       rst_counters,
	output wire       count_up_min, 
	output wire       sec_plus_one,
	output reg  [7:0] seconds
);

reg [9:0] count_cycle;

// Calculates 1-sec from 1KHz CLK
always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		count_cycle <= 10'b0;
	end
	else if (rst_counters) begin
	   count_cycle  <= 10'b0;
	end
    else if (count_cycle == 10'd999) begin
    	count_cycle <= 10'b0;
    end
	else if (en) begin
		count_cycle <= count_cycle + 1'b1;
    end
end

assign sec_plus_one = (count_cycle == 10'd999)? 1'b1:1'b0;

always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		seconds <= 8'b0;
	end
	else if (stop || rst_counters) begin
		seconds <= 8'b0;
	end
    else if (sec_plus_one && seconds == 8'd59) begin
    	seconds <= 8'd0;
    end
	else if (sec_plus_one) begin
		seconds <= seconds + 1'b1;
    end

end

assign count_up_min = (seconds == 8'd59 && count_cycle == 10'd999)? 1'b1:1'b0;

endmodule