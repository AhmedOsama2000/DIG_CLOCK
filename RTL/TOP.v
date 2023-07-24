module DIGITAL_CLOCK (
	// Inputs
	input  wire       i_rst_n,
	input  wire       i_clk_dig,
	input  wire       i_clk_disp,
	input  wire [1:0] i_timer_mode,
	input  wire       i_time_format,
	input  wire       i_set,
	input  wire       i_wake,
	input  wire       i_err_disp,

	// Outputs
	output wire       o_en_disp,
	output wire [3:0] o_sec_l,
	output wire [3:0] o_sec_m,
	output wire [3:0] o_min_l,
	output wire [3:0] o_min_m,
	output wire [3:0] o_hour_l,
	output wire [3:0] o_hour_m
);

// Debounce Internal Signals
wire [1:0] clean_timer_mode;
wire [1:0] clean_timer_mode_mux_sel;
wire       clean_time_format;
wire       clean_set;
wire       clean_wake;


// Counters Internal Signals
wire [7:0] clk_sec;
wire [7:0] clk_min;
wire [7:0] clk_hr;

wire [7:0] stp_sec;
wire [7:0] stp_min;
wire [7:0] stp_hr;

wire [7:0] cnt_sec;
wire [7:0] cnt_min;
wire [7:0] cnt_hr;

// FSM Internal Signals
wire       rst_counters;
wire       en_deb_chk;
wire       en_dig_clk;
wire       enc_dig_clk;
wire       en_stop_watch;
wire       rst_stop_watch;
wire       en_count_down;
wire       enc_cnt_down;
wire       en_disp_comp;

// Syncronizers
// Register time_format output for CDC

wire        rst_n_domain_1;
wire        rst_n_domain_2;

wire        en_disp_async;
wire        err_disp_sync;

wire        Valid_clk;
wire        Valid_stp_watch;
wire        Valid_cnt_down;

wire        Valid_clk_sync;
wire        Valid_stp_watch_sync;
wire        Valid_cnt_down_sync;

wire [7:0]  clk_sec_sync;
wire [7:0]  clk_min_sync;
wire [7:0]  clk_hr_sync;

wire [7:0]  stp_sec_sync;
wire [7:0]  stp_min_sync;
wire [7:0]  stp_hr_sync;

wire [7:0]  cnt_sec_sync;
wire [7:0]  cnt_min_sync;
wire [7:0]  cnt_hr_sync;

// MUXES Internal Signals
wire [7:0] mux_sec;
wire [7:0] mux_min;
wire [7:0] mux_hr; 
  
DEB_CHK_1KHz timer_mode0 (
	.CLK(i_clk_dig), // 1KHz
	.rst_n(rst_n_domain_1),
	.en(en_deb_chk),
	.i_btn(i_timer_mode[0]),
	.o_btn(clean_timer_mode[0])
);

DEB_CHK_1KHz timer_mode1 (
	.CLK(i_clk_dig), // 1KHz
	.rst_n(rst_n_domain_1),
	.en(en_deb_chk),
	.i_btn(i_timer_mode[1]),
	.o_btn(clean_timer_mode[1])
);

DEB_CHK_1KHz time_format (
	.CLK(i_clk_dig), // 1KHz
	.rst_n(rst_n_domain_1),
	.en(en_deb_chk),
	.i_btn(i_time_format),
	.o_btn(clean_time_format)
);

DEB_CHK_1KHz set (
	.CLK(i_clk_dig), // 1KHz
	.rst_n(rst_n_domain_1),
	.en(en_deb_chk),
	.i_btn(i_set),
	.o_btn(clean_set)
);

DEB_CHK_1KHz wake (
	.CLK(i_clk_dig), // 1KHz
	.rst_n(rst_n_domain_1),
	.en(en_deb_chk),
	.i_btn(i_wake),
	.o_btn(clean_wake)
);

DEB_CHK_3KHz timer_mode0_mux_sel (
	.CLK(i_clk_disp), // 3KHz
	.rst_n(rst_n_domain_2),
	.en(en_deb_chk),
	.i_btn(i_timer_mode[0]),
	.o_btn(clean_timer_mode_mux_sel[0])
);

DEB_CHK_3KHz timer_mode1_mux_sel (
	.CLK(i_clk_disp), // 3KHz
	.rst_n(rst_n_domain_2),
	.en(en_deb_chk),
	.i_btn(i_timer_mode[1]),
	.o_btn(clean_timer_mode_mux_sel[1])
);

// Pulse Stretch
Pulse_Stretch err_disp (
	.CLK(i_clk_disp),
	.rst_n(rst_n_domain_2),
	.Async(i_err_disp),
	.pulse(err_disp_sync)
);

// FSM
FSM fsm (
	.rst_n(rst_n_domain_1),
	.CLK(i_clk_dig), // 1KHz
	.i_set(clean_set),
	.i_wake(clean_wake),
	.i_timer_mode(clean_timer_mode),
	.i_err_disp_sync(err_disp_sync),
	.en_deb_chk(en_deb_chk),
	.rst_counters(rst_counters),
	.en_disp(en_disp_comp),
	.en_dig_clk(en_dig_clk),
	.enc_sec_clk(enc_dig_clk),
	.en_stop_watch(en_stop_watch),
	.rst_stop_watch(rst_stop_watch),
	.en_count_down(en_count_down),
	.enc_sec_count_down(enc_cnt_down)
);

// Register enable display before sync
DFF reg_en_disp (
	.CLK(i_clk_dig),
	.rst_n(rst_n_domain_1),
	.D(en_disp_comp),
	.Q(en_disp_async)
);

CLock DIG_CLK (
	.CLK(i_clk_dig), // 1KHz
	.rst_n(rst_n_domain_1),
	.rst_counters(rst_counters),
	.enc_sec(enc_dig_clk),
	.en(en_dig_clk),
	.i_time_format(clean_time_format),
	.Valid(Valid_clk),
	.seconds(clk_sec),
	.mins(clk_min),
	.hrs(clk_hr)
);

Stop_Watch stp_watch (
	.CLK(i_clk_dig), // 1KHz
	.rst_n(rst_n_domain_1),
	.en(en_stop_watch),
	.rst_counters(rst_counters),
	.Valid(Valid_stp_watch),
	.stop(rst_stop_watch),
	.seconds(stp_sec),
	.mins(stp_min),
	.hrs(stp_hr)
);

Count_down cnt_down (
	.CLK(i_clk_dig), // 1KHz
	.rst_n(rst_n_domain_1),
	.rst_counters(rst_counters),
	.en(en_count_down),
	.Valid(Valid_cnt_down),
	.enc_sec(enc_cnt_down),
	.seconds(cnt_sec),
	.mins(cnt_min),
	.hrs(cnt_hr)
);

// Syncronizers
RST_SYNC domain_1 (
	.CLK(i_clk_dig),
	.rst_n(i_rst_n),
	.sync_rst_n(rst_n_domain_1)
);

RST_SYNC domain_2 (
	.CLK(i_clk_disp),
	.rst_n(i_rst_n),
	.sync_rst_n(rst_n_domain_2)
);

BIT_SYNC valid_clk (
	.CLK(i_clk_disp), // 3KHz
	.rst_n(rst_n_domain_2),
	.Async(Valid_clk),
	.Sync(Valid_clk_sync)
);

BUS_SYNC bus_clk_sync (
	.CLK(i_clk_disp), // 3KHz
	.rst_n(rst_n_domain_2),
	.EN(Valid_clk_sync),
	.Async({clk_hr,clk_min,clk_sec}),
	.Sync({clk_hr_sync,clk_min_sync,clk_sec_sync})
);

BIT_SYNC valid_stp (
	.CLK(i_clk_disp), // 3KHz
	.rst_n(rst_n_domain_2),
	.Async(Valid_stp_watch),
	.Sync(Valid_stp_watch_sync)
);

BUS_SYNC bus_stp_watch_sync (
	.CLK(i_clk_disp), // 3KHz
	.rst_n(rst_n_domain_2),
	.EN(Valid_stp_watch_sync),
	.Async({stp_hr,stp_min,stp_sec}),
	.Sync({stp_hr_sync,stp_min_sync,stp_sec_sync})
);

BIT_SYNC valid_cnt (
	.CLK(i_clk_disp), // 3KHz
	.rst_n(rst_n_domain_2),
	.Async(Valid_cnt_down),
	.Sync(Valid_cnt_down_sync)
);

BUS_SYNC bus_cnt_down_sync (
	.CLK(i_clk_disp), // 3KHz
	.rst_n(rst_n_domain_2),
	.EN(Valid_cnt_down_sync),
	.Async({cnt_hr,cnt_min,cnt_sec}),
	.Sync({cnt_hr_sync,cnt_min_sync,cnt_sec_sync})
);

mux4X1 sec_sel (
	.i0(clk_sec_sync),
	.i1(stp_sec_sync),
	.i2(cnt_sec_sync),
	.sel(clean_timer_mode_mux_sel),
	.out(mux_sec)
);

mux4X1 min_sel (
	.i0(clk_min_sync),
	.i1(stp_min_sync),
	.i2(cnt_min_sync),
	.sel(clean_timer_mode_mux_sel),
	.out(mux_min)
);

mux4X1 hr_sel (
	.i0(clk_hr_sync),
	.i1(stp_hr_sync),
	.i2(cnt_hr_sync),
	.sel(clean_timer_mode_mux_sel),
	.out(mux_hr)
);

// Binary To BCD Convsersion
Bin2BCD Binary2BCD (
	.CLK(i_clk_disp), // 3KHz
	.rst_n(rst_n_domain_2),
	.Sec_bin(mux_sec),
	.Min_bin(mux_min),
	.Hr_bin(mux_hr),
	.Sec_Least(o_sec_l),
	.Sec_Most(o_sec_m),
	.Min_Least(o_min_l),
	.Min_Most(o_min_m),
	.Hr_Least(o_hour_l),
	.Hr_Most(o_hour_m)
);

BIT_SYNC en_disp_sync (
	.CLK(i_clk_disp), // 3KHz
	.rst_n(rst_n_domain_2),
	.Async(en_disp_async),
	.Sync(o_en_disp)
);

endmodule