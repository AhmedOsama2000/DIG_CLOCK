module FSM (
	input  wire rst_n,
	input  wire CLK, // 1KHz

	input  wire 	  i_set,
	input  wire 	  i_wake,
	input  wire [1:0] i_timer_mode,
	input  wire 	  i_err_disp_sync,

	output reg        rst_counters,
	output reg        en_deb_chk,
	output reg   	  en_disp,
	output reg   	  en_dig_clk,
	output reg   	  enc_sec_clk,
	output reg   	  en_stop_watch,
	output reg   	  rst_stop_watch,
	output reg   	  en_count_down,
	output reg   	  enc_sec_count_down
);

localparam SYS_RST            = 4'b0000;

localparam DIG_CLK_CONFIG     = 4'b0001;
localparam DIG_CLK_ENC        = 4'b0010;
localparam DIG_CLK_MODE       = 4'b0011;
localparam SLEEP              = 4'b0100;

localparam COUNT_DOWN_CONFIG  = 4'b0101;
localparam COUNT_DOWN_ENC     = 4'b0110;
localparam COUNT_DOWN_MODE    = 4'b0111;

localparam STOP_WATCH_ON      = 4'b1000;
localparam STOP_WATCH_STEADY1 = 4'b1001;
localparam STOP_WATCH_OFF     = 4'b1010;
localparam STOP_WATCH_STEADY2 = 4'b1011;

// Counters
reg  [14:0] count_30secs;
reg  [11:0] count_3secs_active;
reg  [11:0] count_3secs_idle;

// States 
reg [3:0]   CS;
reg [3:0]   NS;

wire        stp_watch_states;

wire pulse_gen;
wire kept_pressed;
reg  btn_pressed;

// Flags
wire        flag_30secs;
wire        flag_3secs_active; // For i_set kept pressed   for 3 secs
wire        flag_3secs_idle;   // For i_set kept unpressed for 3 secs

assign stp_watch_states = (NS == STOP_WATCH_ON || NS == STOP_WATCH_OFF || NS == STOP_WATCH_STEADY1 || NS == STOP_WATCH_STEADY2)? 1'b1:1'b0;

// Calculate three seconds out of 1KHz
always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		count_3secs_active <= 12'd0;
	end
	else if (i_err_disp_sync || (i_set && count_3secs_active == 12'd2999) || !i_set) begin
		count_3secs_active <= 12'd0;
	end
	else if (NS == COUNT_DOWN_MODE || NS == SLEEP || NS == DIG_CLK_MODE || stp_watch_states) begin
		count_3secs_active <= count_3secs_active + 1'b1;
	end
end

// Calculate three seconds out of 1KHz
always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		count_3secs_idle <= 12'd0;
	end
	else if (i_err_disp_sync || (!i_set && count_3secs_idle == 12'd2999) || i_set) begin
		count_3secs_idle <= 12'd0;
	end
	else if (NS == COUNT_DOWN_CONFIG || NS == DIG_CLK_CONFIG) begin
		count_3secs_idle <= count_3secs_idle + 1'b1;
	end
end

// Calculate thirty seconds out of 1KHz
always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		count_30secs  <= 12'd0;
	end
	else if ((count_30secs == 15'd29999 && !i_wake && !flag_30secs) || i_err_disp_sync || i_wake) begin
		count_30secs  <= 12'd0;
	end
	else if (NS == DIG_CLK_MODE) begin
		count_30secs  <= count_30secs + 1'b1;
	end
end

// Generate a pulse from i_set to detect a press
always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		btn_pressed <= 1'b0;
	end
	else if (i_err_disp_sync) begin
		btn_pressed <= 1'b0;
	end
	else begin
		btn_pressed <= i_set;
	end
end

assign pulse_gen    = btn_pressed ^ i_set;
assign kept_pressed = i_set       & btn_pressed;

assign flag_3secs_active  = ( i_set  && count_3secs_active  == 12'd2999)?  1'b1:1'b0;
assign flag_3secs_idle    = (!i_set  && count_3secs_idle    == 12'd2999)?  1'b1:1'b0;
assign flag_30secs        = (!i_wake && count_30secs        == 15'd29999)? 1'b1:1'b0;

// State Registering
always @(posedge CLK,negedge rst_n) begin
	if(!rst_n) begin
		CS <= SYS_RST;
	end 
	else begin
		CS <= NS;
	end
end

// States Transition
always @(*) begin
	enc_sec_clk        = 1'b0;
	enc_sec_count_down = 1'b0;
	if (i_err_disp_sync || !rst_n) begin
		NS = SYS_RST;
	end
	else begin
		NS = DIG_CLK_CONFIG;
		case (CS)
			DIG_CLK_CONFIG: begin
				if (flag_3secs_idle) begin
					NS = DIG_CLK_MODE;
				end
				else if (pulse_gen && i_set) begin
					NS = DIG_CLK_ENC;
				end
				else begin
					NS = DIG_CLK_CONFIG;
				end
			end
			DIG_CLK_ENC: begin
				if (pulse_gen) begin
					NS          = DIG_CLK_CONFIG;
					enc_sec_clk = 1'b1;
				end
				else begin
					NS          = DIG_CLK_ENC; 
					enc_sec_clk = 1'b0; 
				end
			end
			DIG_CLK_MODE: begin
				if (flag_3secs_active && i_timer_mode == 2'b01) begin
					NS = STOP_WATCH_ON;
				end
				else if (flag_3secs_active && i_timer_mode == 2'b10) begin
					NS = COUNT_DOWN_CONFIG;
				end
				else if (flag_30secs) begin
					NS = SLEEP;
				end
				else begin
					NS = DIG_CLK_MODE;
				end
			end
			SLEEP: begin
				if (flag_3secs_active && i_timer_mode == 2'b01) begin
					NS = STOP_WATCH_ON;
				end
				else if (flag_3secs_active && i_timer_mode == 2'b10) begin
					NS = COUNT_DOWN_CONFIG;
				end
				else if (i_wake) begin
					NS = DIG_CLK_MODE;
				end
				else begin
					NS = SLEEP;
				end
			end
			STOP_WATCH_ON: begin
				if (pulse_gen && i_set) begin
					NS = STOP_WATCH_STEADY1;
				end
				else begin
					NS = STOP_WATCH_ON;
				end
			end
			STOP_WATCH_STEADY1: begin
				if (flag_3secs_active && i_timer_mode == 2'b00) begin
					NS = DIG_CLK_MODE;
				end
				else if (flag_3secs_active && i_timer_mode == 2'b10) begin
					NS = COUNT_DOWN_CONFIG;
				end
				else if (pulse_gen) begin
					NS = STOP_WATCH_OFF;
				end
				else begin
					NS = STOP_WATCH_STEADY1;
				end
			end
			STOP_WATCH_OFF: begin
				if (pulse_gen) begin
					NS = STOP_WATCH_STEADY2;
				end
				else begin
					NS = STOP_WATCH_OFF;
				end
			end
			STOP_WATCH_STEADY2: begin
				if (flag_3secs_active && i_timer_mode == 2'b00) begin
					NS = DIG_CLK_MODE;
				end
				else if (flag_3secs_active && i_timer_mode == 2'b10) begin
					NS = COUNT_DOWN_CONFIG;
				end
				else if (pulse_gen) begin
					NS = STOP_WATCH_ON;
				end
				else begin
					NS = STOP_WATCH_STEADY2;
				end
			end
			COUNT_DOWN_CONFIG: begin
				if (flag_3secs_idle) begin
					NS = COUNT_DOWN_MODE;
				end
				else if (pulse_gen && i_set) begin
					NS = COUNT_DOWN_ENC;
				end
				else begin
					NS = COUNT_DOWN_CONFIG;
				end
			end
			COUNT_DOWN_ENC: begin
				if (pulse_gen) begin
					NS                 = COUNT_DOWN_CONFIG;
					enc_sec_count_down = 1'b1;
				end
				else begin
					NS = COUNT_DOWN_ENC; 
					enc_sec_count_down = 1'b0; 
				end
			end
			COUNT_DOWN_MODE: begin
				if (flag_3secs_active && i_timer_mode == 2'b00) begin
					NS = DIG_CLK_MODE;
				end
				else if (flag_3secs_active && i_timer_mode == 2'b01) begin
					NS = STOP_WATCH_ON;
				end
				else begin
					NS = COUNT_DOWN_MODE;
				end
			end
			default: begin
				NS = DIG_CLK_CONFIG;
			end
		endcase
	end

end

// FSM Output
always @(*) begin

	// Default Values
	en_disp            = 1'b1;
	en_dig_clk         = 1'b1;
	en_stop_watch      = 1'b0;
	rst_stop_watch     = 1'b1;
	en_count_down      = 1'b0;
	en_deb_chk         = 1'b1;
	rst_counters       = 1'b0;

	if (CS == SYS_RST) begin
		en_deb_chk     = 1'b0;
		rst_counters   = 1'b1;
		en_dig_clk     = 1'b0; 
		en_stop_watch  = 1'b0;
		en_count_down  = 1'b0;	
	end
	else if (CS == STOP_WATCH_ON) begin
		en_stop_watch  = 1'b1;
		rst_stop_watch = 1'b0;
	end
	else if (CS == STOP_WATCH_OFF || CS == STOP_WATCH_STEADY1 || CS == STOP_WATCH_STEADY2) begin
		rst_stop_watch = 1'b0;
	end
	else if (CS == SLEEP) begin
		en_disp       = 1'b0;
	end
	else if (CS == COUNT_DOWN_MODE) begin
		en_count_down = 1'b1;
	end
	else begin
		en_disp        = 1'b1;
		en_dig_clk     = 1'b1;
		en_stop_watch  = 1'b0;
		rst_stop_watch = 1'b1;
		en_count_down  = 1'b0;
		en_deb_chk     = 1'b1;
		rst_counters   = 1'b0;
	end
end

endmodule