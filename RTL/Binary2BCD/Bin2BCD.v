module Bin2BCD (
   input  wire       CLK,
   input  wire       rst_n,
   input  wire [7:0] Sec_bin,
   input  wire [7:0] Min_bin,
   input  wire [7:0] Hr_bin,

   output reg  [3:0] Sec_Least,
   output reg  [3:0] Sec_Most,
   output reg  [3:0] Min_Least,
   output reg  [3:0] Min_Most,
   output reg  [3:0] Hr_Least,
   output reg  [3:0] Hr_Most
);
   

wire [3:0] comp_Sec_Least;
wire [3:0] comp_Sec_Most;
wire [3:0] comp_Min_Least;
wire [3:0] comp_Min_Most;
wire [3:0] comp_Hr_Least;
wire [3:0] comp_Hr_Most;

Bin2BCD_8bits Seconds (
   .Bin(Sec_bin),
   .Least(comp_Sec_Least),
   .Most(comp_Sec_Most)
);

Bin2BCD_8bits Mins (
   .Bin(Min_bin),
   .Least(comp_Min_Least),
   .Most(comp_Min_Most)
);

Bin2BCD_8bits Hrs (
   .Bin(Hr_bin),
   .Least(comp_Hr_Least),
   .Most(comp_Hr_Most)
);

// Register the output
always @(posedge CLK,negedge rst_n) begin
    if (!rst_n) begin
        Sec_Least <= 4'b0;
        Sec_Most  <= 4'b0;
        Min_Least <= 4'b0;
        Min_Most  <= 4'b0;
        Hr_Least  <= 4'b0;
        Hr_Most   <= 4'b0;
    end
    else begin
        Sec_Least <= comp_Sec_Least;
        Sec_Most  <= comp_Sec_Most;
        Min_Least <= comp_Min_Least;
        Min_Most  <= comp_Min_Most;
        Hr_Least  <= comp_Hr_Least;
        Hr_Most   <= comp_Hr_Most;
    end
end

endmodule