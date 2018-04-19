`timescale 1 ns / 1 ps

module M00_module_test;

reg clk, rst_n;
always #5 clk = ~clk;

reg [31:0] din_from_buf;
reg din_valid;
reg last;
wire din_accep;

wire axis_valid;
wire axis_data;
wire axis_tstrb;
wire axis_tlast;
reg axis_ready;



axis_bram_adapter_v1_0_M00_AXIS test(
    .DIN_FROM_BUF(din_from_buf),
    .DIN_VALID(din_valid),
    .last(last),
    .DIN_ACCEP(din_accep),
    .M_AXIS_ACLK(clk),
    .M_AXIS_ARESETN(rst_n),
    .M_AXIS_TVALID(axis_valid),
    .M_AXIS_TDATA(axis_data),
    .M_AXIS_TSTRB(axis_tstrb),
    .M_AXIS_TLAST(axis_tlast),
    .M_AXIS_TREADY(axis_ready));


initial 
begin
    clk = 0;
    rst_n = 0;
    #10 rst_n = 1;

    last = 0;
    din_from_buf = 32'd0;
    din_valid = 1'b0;
    axis_ready = 1'b0;
end
endmodule
