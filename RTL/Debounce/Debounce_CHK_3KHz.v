module DEB_CHK_3KHz
(
	input  wire  CLK, // 3KHz
	input  wire  rst_n,
	input  wire  en,
	input  wire  i_btn,
	output reg   o_btn
);

localparam ZERO    = 2'b00;
localparam WAIT1_1 = 2'b01;
localparam WAIT0_1 = 2'b10;
localparam ONE     = 2'b11;

wire       ticks_done;
reg  [1:0] CS;
reg  [1:0] NS;
reg  [4:0] count_10ms;

always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		count_10ms <= 5'b0;
	end
	else if (count_10ms == 5'd29 || CS == ZERO || CS == ONE) begin
		count_10ms <= 5'b0;
	end
	else if (en) begin
		count_10ms <= count_10ms + 1'b1;
	end
end

assign ticks_done = (count_10ms == 5'd29)? 1'b1:1'b0;

always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		CS <= ZERO;
	end
	else begin
		CS <= NS;
	end
end

// States
always @(*) begin
	case (CS)
		ZERO: begin
			if (i_btn) begin
				NS = WAIT1_1;
			end
			else begin
				NS = ZERO;
			end
		end
		WAIT1_1: begin
			if (i_btn && !ticks_done) begin
				NS = WAIT1_1;
			end
			else if (i_btn && ticks_done) begin
				NS = ONE;
			end
			else begin
				NS = ZERO;
			end
		end
		WAIT0_1: begin
			if (!i_btn && !ticks_done) begin
				NS = WAIT0_1;
			end
			else if (!i_btn && ticks_done) begin
				NS = ZERO;
			end
			else begin
				NS = ONE;
			end
		end
		ONE: begin
			if (!i_btn) begin
				NS = WAIT0_1;
			end
			else begin
				NS = ONE;
			end
		end
		default: NS = ZERO;
	endcase
end

// FSM Output
always @(*) begin
	if (CS == ZERO) begin
		o_btn = 1'b0;
	end
	else if (CS == ONE) begin
		o_btn = 1'b1;
	end
	else begin
		o_btn = 1'b0;
	end
end

endmodule