`timescale 1 ns / 100 ps

module top_module_test;

reg clk, rst_n;
always #5 clk = ~clk;

wire bram_en;
wire bram_wen;
wire [11:0] bram_addr;
wire [1151:0] to_bram;
wire ready;
wire out_valid;
wire [31:0] out_data;
wire [3:0] out_strb;
wire out_last;


reg[1151:0] from_bram;
reg[31:0] in_data;
reg[3:0] in_tstrb;
reg in_tlast;
reg in_tvalid;
reg out_ready;

//remember in order to modeling, these 3 signals 
//need to be set at clk rising edge
reg rw;
reg bram_start_addr;
reg bram_end_addr;

axis_bram_adapter_v1_0_for_test test(
    .BRAM_CLK(clk),
    .BRAM_EN(bram_en),
    .BRAM_WEN(bram_wen),
    .BRAM_ADDR(bram_addr),
    .BRAM_IN(to_bram),
    .BRAM_OUT(from_bram),
    .s00_axis_aclk(clk),
	.s00_axis_aresetn(rst_n),
	.s00_axis_tready(ready),
	.s00_axis_tdata(in_data),
	.s00_axis_tstrb(in_strb),
	.s00_axis_tlast(in_tlast),
	.s00_axis_tvalid(in_tvalid),
    .m00_axis_aclk(clk),
    .m00_axis_aresetn(rst_n),
	.m00_axis_tvalid(out_valid),
	.m00_axis_tdata(out_data),
	.m00_axis_tstrb(out_strb),
    .m00_axis_tlast(out_last),
	.m00_axis_tready(out_ready),
    .rw(rw),
    .bram_start_addr(bram_start_addr),
    .bram_bound_addr(bram_end_addr)
);

initial 
begin
    clk = 0;
    rst_n = 0;

    bram_start_addr = 0;
    bram_end_addr = 7;


#20 rst_n = 1;
//testing for write to bram

    #5 in_data = 32'd1;
    in_tvalid = 1'b1;
    #10 in_data = 32'd2;
    #10 in_data = 32'd3;
    #10 in_data = 32'd4;
    #10 in_data = 32'd5;
    #10 in_data = 32'd6;
    #10 in_data = 32'd7;
    #10 in_data = 32'd8;
    #10 in_data = 32'd9;
    #10 in_data = 32'd10;
    #10 in_data = 32'd11;
    #10 in_data = 32'd12;
    #10 in_data = 32'd13;
    #10 in_data = 32'd14;
    #10 in_data = 32'd15;
    #10 in_data = 32'd16;
    #10 in_data = 32'd17;
    #10 in_data = 32'd18;
    #10 in_data = 32'd19;
    #10 in_data = 32'd20;
    #10 in_data = 32'd21;
    #10 in_data = 32'd22;
    #10 in_data = 32'd23;
    #10 in_data = 32'd24;
    #10 in_data = 32'd25;
    #10 in_data = 32'd26;
    #10 in_data = 32'd27;
    #10 in_data = 32'd28;
    #10 in_data = 32'd29;
    #10 in_data = 32'd30;
    #10 in_data = 32'd31;
    #10 in_data = 32'd32;
    #10 in_data = 32'd33;
    #10 in_data = 32'd34;
    #10 in_data = 32'd35;
    #10 in_data = 32'd36;
    #10 in_data = 32'd37;
    #10 in_data = 32'd38;
    #10 in_data = 32'd39;
    #10 in_data = 32'd40;
    #10 in_data = 32'd41;
    #10 in_data = 32'd42;
    in_tlast = 1'b1;
    #10 in_tvalid = 1'b0;
    in_tlast = 1'b0;
   
    $finish;
end
endmodule
