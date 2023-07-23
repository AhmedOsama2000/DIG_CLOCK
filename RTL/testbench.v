`timescale 1ms/1us
module testbench;

	reg        i_rst_n;
	reg        i_clk_dig;
	reg        i_clk_disp;
	reg [1:0]  i_timer_mode;
	reg        i_time_format;
	reg        i_set;
	reg        i_wake;
	reg        i_err_disp;

	wire       o_en_disp;
	wire [3:0] o_sec_l;
	wire [3:0] o_sec_m;
	wire [3:0] o_min_l;
	wire [3:0] o_min_m;
	wire [3:0] o_hour_l;
	wire [3:0] o_hour_m;

	// DUT Instantiation
	DIGITAL_CLOCK DUT (
		// Inputs
		.i_rst_n(i_rst_n),
		.i_clk_dig(i_clk_dig),
		.i_clk_disp(i_clk_disp),
		.i_timer_mode(i_timer_mode),
		.i_time_format(i_time_format),
		.i_set(i_set),
		.i_wake(i_wake),
		.i_err_disp(i_err_disp),
		// Outputs
		.o_en_disp(o_en_disp),
		.o_sec_l(o_sec_l),
		.o_sec_m(o_sec_m),
		.o_min_l(o_min_l),
		.o_min_m(o_min_m),
		.o_hour_l(o_hour_l),
		.o_hour_m(o_hour_m)
	);

	integer i;

	// 1KHz CLK
	always begin
		#0.5
		i_clk_dig = !i_clk_dig;
	end

	// 3KHz CLK
	always begin
		#0.33333
		i_clk_disp = !i_clk_disp;
	end

	initial begin

		initialize_DUT();

		// ------------------------------- I- Check CLK Mode (set timers with 30:45) ------------------------------- //
		i_rst_n = 1'b1;
		for (i = 0;i < 3690;i = i + 1) begin
			i_set = !i_set;
			repeat (20) @(negedge i_clk_dig); // Press for more that 10ms
		end
		i_set = 1'b0;
		repeat (3000) @(negedge i_clk_dig); // Now the i_set is idle for 3secs and we are in digital clock mode

		repeat (1000_000) @(negedge i_clk_dig); // Monitor the behavior of the clock

		format_1(); // Change the format

		repeat (1000_000) @(negedge i_clk_dig); // Monitor the behavior of the clock again

		press_i_wake();
                  
		repeat (1000_000) @(negedge i_clk_dig); // Monitor the behavior of the clock again

		// ------------------------------- II- Check Stop Watch Mode ------------------------------- //

		// II- Check Stop Watch Mode
		stp_watch_mode();

		repeat (1000_000) @(negedge i_clk_dig); // Monitor the behavior of the clock

		press_i_set(); // Stop the watch

		repeat (1000) @(negedge i_clk_dig); // Monitor the behavior of the clock

		press_i_set(); // resume the watch 

		repeat (1000_000) @(negedge i_clk_dig); // Monitor the behavior of the clock

		clk_mode();             // Go back to digital clock mode

		press_i_set_3secs();

		repeat (1000_000) @(negedge i_clk_dig); // The clock should be working while stop watch is on

		// ------------------------------- III- Check Count Down Mode ------------------------------- //

		cnt_down_mode();

		press_i_set_3secs();

		for (i = 0;i < 1260;i = i + 1) begin // set the time at 00:10:30 for example (press the i_set for 3690 times)
			i_set = !i_set;
			repeat (20) @(negedge i_clk_dig); // Press for more that 10ms
		end

		repeat (3000_000) @(negedge i_clk_dig); // Monitor the behavior of the count down timer

		clk_mode();             // Go back to digital clock mode

		press_i_set_3secs();

		repeat (1000_000) @(negedge i_clk_dig); // The clock should be working while count down timer is on

		// ------------------------------- IV- Check Err Display ------------------------------- //
		err_disp_chk();
		repeat (1000) @(negedge i_clk_dig); // Counters should be reset

		$stop;
	end

task press_i_set_3secs;
	begin
		i_set = 1'b1;
		repeat (20) @(negedge i_clk_dig);       // Press for more that 10ms
		repeat (3000) @(negedge i_clk_dig);     // i_set is active for 3secs to change the mode
		i_set = 1'b0;
	end
endtask

task press_i_set;
	begin
		i_set = 1'b1;                           // Stop the watch
		repeat (20) @(negedge i_clk_dig);       // Press for more that 10ms
		i_set = 1'b0;
	end
endtask

task press_i_wake;
	begin
		i_wake        = 1'b1;                   // Light up the Display unit
		repeat (20) @(negedge i_clk_dig);       // Press for more that 10ms
		i_wake        = 1'b0;          
	end
endtask

task clk_mode;
	begin
		i_timer_mode = 2'b00;
		repeat (20) @(negedge i_clk_dig); // Press for more that 10ms
	end
endtask

task stp_watch_mode;
	begin
		i_timer_mode = 2'b01;
		repeat (20) @(negedge i_clk_dig); // Press for more that 10ms
	end
endtask

task cnt_down_mode;
	begin
		i_timer_mode = 2'b10;
		repeat (20) @(negedge i_clk_dig); // Press for more that 10ms
	end
endtask

task format_0;
	begin
		i_time_format = 1'b0; 			  // Change the format
		repeat (20) @(negedge i_clk_dig); // Press for more that 10ms
	end
endtask

task format_1;
	begin
		i_time_format = 1'b1; 			  // Change the format
		repeat (20) @(negedge i_clk_dig); // Press for more that 10ms
	end
endtask

task err_disp_chk;
	begin
		@(negedge i_clk_disp);
		i_err_disp = 1'b1;
		@(negedge i_clk_disp);
		i_err_disp = 1'b0;
	end
endtask

task initialize_DUT;
	begin
		// Initiate the inputs
		i_rst_n       = 1'b0;
		i_clk_dig     = 1'b0;
		i_clk_disp    = 1'b0;
		i_timer_mode  = 2'b00;
		i_time_format = 1'b0;
		i_set         = 1'b0;
		i_wake        = 1'b0;
		i_err_disp    = 1'b0;
		repeat (30) @(negedge i_clk_dig);
	end
endtask


endmodule