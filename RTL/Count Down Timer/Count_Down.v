module Count_down
(
	input  wire 	  CLK, // 1KHz
	input  wire 	  rst_n,
	input  wire	 	  en,
	input  wire       enc_sec,
	input  wire       rst_counters,
	output reg [7:0]  seconds,
	output reg [7:0]  mins,
	output reg [7:0]  hrs,
	output reg        Valid
);

wire 	  count_up_min;
wire      count_up_hr;
wire      sec_minus_one;
reg [9:0] count_cycle;

// Calculates 1-sec from 1KHz CLK
always @(posedge CLK,negedge rst_n) begin
	if (!rst_n || rst_counters) begin
		count_cycle <= 10'b0;
	end
    else if (count_cycle == 10'd999) begin
    	count_cycle <= 10'b0;
    end
	else if (en) begin
		count_cycle <= count_cycle + 1'b1;
    end
end

assign sec_minus_one = (count_cycle == 10'd999)? 1'b1:1'b0;

// Decrement Mode
always @(posedge CLK,negedge rst_n) begin
	if (!rst_n || rst_counters) begin
		seconds <= 8'b0;
	end
	else if (sec_minus_one && seconds == 8'd0 && mins == 8'd0 && hrs != 8'd0) begin
		seconds <= 8'd59;
		mins    <= 8'd59;
		hrs     <= hrs - 1'b1;
	end
	else if (sec_minus_one && seconds == 8'd0 && mins != 8'd0) begin
		seconds <= 8'd59;
		mins    <= mins - 1'b1;
	end
	else if (sec_minus_one && seconds != 8'd0) begin
		seconds <= seconds - 1'b1;
	end
    else if (enc_sec && seconds == 8'd59) begin
    	seconds <= 8'd0;
    end
	else if (enc_sec) begin
		seconds <= seconds + 1'b1;
    end
end

// Adjustment Mode
// MINS
always @(posedge CLK,negedge rst_n) begin
	if (!rst_n || rst_counters) begin
		mins <= 8'b0;
	end
	else if (mins == 8'd59 && count_up_min) begin
		mins <= 8'b0;
	end
	else if (count_up_min) begin
		mins <= mins + 1'b1;
    end
end

// HRS_24
always @(posedge CLK,negedge rst_n) begin
	if (!rst_n || rst_counters) begin
		hrs <= 8'b0;
	end
	else if (hrs == 8'd23 && count_up_hr) begin
		hrs <= 8'b0;
	end
	else if (count_up_hr) begin
		hrs <= hrs + 1'b1;
    end
end

assign count_up_min = (seconds == 8'd59 && enc_sec)? 1'b1:1'b0;
assign count_up_hr  = (mins == 8'd59 && count_up_min)? 1'b1:1'b0;

always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		Valid <= 1'b0;
	end
	else if (enc_sec || sec_minus_one || count_up_min || count_up_hr || rst_counters) begin
		Valid <= 1'b1;
	end
	else begin
		Valid <= 1'b0;
	end
end

endmodule