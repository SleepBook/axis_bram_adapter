`timescale 1 ns / 100 ps

module top_module_test;

reg clk, rst_n;
always #5 clk = ~clk;

wire bram_en;
wire bram_wen;
wire [11:0] bram_addr;
wire [1151:0] to_bram_data;
wire axis_in_ready;
wire axis_out_valid;
wire [31:0] axis_out_data;
wire [3:0] out_strb;
wire axis_out_tlast;
wire bram_clk;


reg[1151:0] bram_out_data;
reg[31:0] axis_in_data;
reg[3:0] in_tstrb;
reg axis_in_tlast;
reg axis_in_valid;
reg axis_out_ready;

//remember in order to modeling, these 3 signals 
//need to be set at clk rising edge
reg rw;
reg bram_start_addr;
reg bram_end_addr;

axis_bram_adapter_v1_0_for_test test(
    .BRAM_CLK(bram_clk),
    .BRAM_EN(bram_en),
    .BRAM_WEN(bram_wen),
    .BRAM_ADDR(bram_addr),
    .BRAM_IN(to_bram_data),
    .BRAM_OUT(bram_out_data),
    .s00_axis_aclk(clk),
	.s00_axis_aresetn(rst_n),
	.s00_axis_tready(axis_in_ready),
	.s00_axis_tdata(axis_in_data),
	.s00_axis_tstrb(in_strb),
	.s00_axis_tlast(axis_in_tlast),
	.s00_axis_tvalid(axis_in_valid),
    .m00_axis_aclk(clk),
    .m00_axis_aresetn(rst_n),
	.m00_axis_tvalid(axis_out_valid),
	.m00_axis_tdata(axis_out_data),
	.m00_axis_tstrb(out_strb),
    .m00_axis_tlast(axis_out_tlast),
	.m00_axis_tready(axis_out_ready),
    .rw(rw),
    .bram_start_addr(bram_start_addr),
    .bram_bound_addr(bram_end_addr)
);

initial 
begin
    clk = 0;
    rst_n = 0;

    bram_start_addr = 3;
    bram_end_addr = 7;
    rw = 1;


#20 rst_n = 1;
//testing for write to bram

 rw = 0;
#15 rw = 1;

    #5 axis_in_data = 32'd0;
    axis_in_valid = 1'b1;
    #10 axis_in_data = 32'd1;
    #10 axis_in_data = 32'd2;
    #10 axis_in_data = 32'd3;
    #10 axis_in_data = 32'd4;
    #10 axis_in_data = 32'd5;
    #10 axis_in_data = 32'd6;
    #10 axis_in_data = 32'd7;
    #10 axis_in_data = 32'd8;
    #10 axis_in_data = 32'd9;
    #10 axis_in_data = 32'd10;
    #10 axis_in_data = 32'd11;
    #10 axis_in_data = 32'd12;
    #10 axis_in_data = 32'd13;
    #10 axis_in_data = 32'd14;
    #10 axis_in_data = 32'd15;
    #10 axis_in_data = 32'd16;
    #10 axis_in_data = 32'd17;
    #10 axis_in_data = 32'd18;
    #10 axis_in_data = 32'd19;
    #10 axis_in_data = 32'd20;
    #10 axis_in_data = 32'd21;
    #10 axis_in_data = 32'd22;
    #10 axis_in_data = 32'd23;
    #10 axis_in_data = 32'd24;
    #10 axis_in_data = 32'd25;
    #10 axis_in_data = 32'd26;
    #10 axis_in_data = 32'd27;
    #10 axis_in_data = 32'd28;
    #10 axis_in_data = 32'd29;
    #10 axis_in_data = 32'd30;
    #10 axis_in_data = 32'd31;
    #10 axis_in_data = 32'd32;
    #10 axis_in_data = 32'd33;
    #10 axis_in_data = 32'd34;
    #10 axis_in_data = 32'd35;
    #10 axis_in_data = 32'd36;
    #10 axis_in_data = 32'd37;
    #10 axis_in_data = 32'd38;
    #10 axis_in_data = 32'd39;
    #10 axis_in_data = 32'd40;
    #10 axis_in_data = 32'd41;
    #10 axis_in_data = 32'd42;
    axis_in_tlast = 1'b1;
    #10 axis_in_valid = 1'b0;
    axis_in_data = 32'd0;
    axis_in_tlast = 1'b0;
   
    $finish;
end
endmodule
