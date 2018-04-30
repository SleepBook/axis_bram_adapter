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
reg reload;
reg[11:0] bram_start_addr;
reg[11:0]  bram_end_addr;

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
    .addr_reload(reload),
    .bram_start_addr(bram_start_addr),
    .bram_bound_addr(bram_end_addr)
);

initial 
begin
    clk = 0;
    rst_n = 0;
    rw = 1;
    reload = 0;

    #20 rst_n = 1;
   //testing for write to bram
    bram_start_addr = 12'd3;
    bram_end_addr = 12'd4;

    rw = 0;
    #15 rw = 1;
    reload = 1;
    #15 rw = 1;
    reload = 0;

    axis_in_tlast = 1'b0;
    #5 axis_in_data = 32'd0;
    axis_in_valid = 1'b1;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;
    #10 axis_in_data = 32'b00000000000000000000000000000000;
    #10 axis_in_data = 32'b11111111111111111111111111111111;

    #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
     #10 axis_in_data = 32'haaaaaaaa;
    #10 axis_in_data = 32'hcccccccc;
    axis_in_tlast = 1'b1;

    #5 axis_in_valid = 1'b0;
    axis_in_data = 32'd0;
    axis_in_tlast = 1'b0;
    

    //write test done
    //start read test

    /*
    bram_start_addr = 12'd6;
    bram_end_addr = 12'd7;
    axis_out_ready = 1'b0;
    rw = 0;
    reload = 1;

    #15 rw = 0;
    reload = 0;


    bram_out_data = {18{{8{4'hc}},{8{4'ha}}}};
    axis_out_ready = 1'b1;
    
    #800 bram_out_data = {18{{8{4'hb}},{8{4'hd}}}};

    */
   
    $finish;
end
endmodule
