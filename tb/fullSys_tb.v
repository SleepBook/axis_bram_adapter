//full system simulation of this IP
//with bram and interface signals
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


wire[1151:0] bram_out_data;
reg[31:0] axis_in_data;
reg[3:0] in_tstrb;
reg axis_in_tlast;
reg axis_in_valid;
reg axis_out_ready;

//lite signals
wire axi_awready;
wire axi_wready;
wire [1:0] axi_bresp;
wire axi_bvalid;
wire axi_arready;
wire [31:0] axi_rdata;
wire axi_rresp;
wire axi_rvalid;

reg[4:0] axi_araddr;
reg axi_arvalid;
reg axi_rready;

reg [4:0] axi_awaddr = 0;
reg axi_awvalid = 0;
reg [31:0] axi_wdata = 0;
reg axi_wvalid = 0;
reg axi_bready = 0;


//remember in order to modeling, these 3 signals 
//need to be set at clk rising edge
reg rw;
reg reload;
reg[11:0] bram_start_addr;
reg[11:0]  bram_end_addr;

bram4test bram(
  .clka(clk),
  .ena(bram_en),
  .wea(bram_wen),
  .addra(bram_addr),
  .dina(to_bram_data),
  .douta(bram_out_data),
  .clkb(clk),
  .enb(0),
  .web(0),
  .addrb(0),
  .dinb(0)
);

task axi_lite_write;
  input [4:0] addr;
  input [31:0] data;
  begin
      @ (posedge clk)
      axi_awaddr = addr;
      axi_awvalid = 1;
      axi_wdata = data;
      axi_wvalid = 1;
      axi_bready = 1;
      wait(axi_awready & axi_wready);
      wait(axi_bvalid);
      // slave should latch the data
      // bvalid should be set
      axi_awaddr = 0;
      axi_awvalid = 0;
      axi_wdata = 0;
      @ (posedge clk)
      axi_bready = 0;
  end
endtask


axis_bram_adapter_v1_0 top(
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
    .s02_axi_aclk(clk),
    .s02_axi_aresetn(rst_n),
    .s02_axi_awaddr(axi_awaddr),
	.s02_axi_awprot(2'b00),
    .s02_axi_awvalid(axi_awvalid),
	.s02_axi_awready(axi_awready),
	.s02_axi_wdata(axi_wdata),
	.s02_axi_wstrb(4'b1111),
    .s02_axi_wvalid(axi_wvalid),
	.s02_axi_wready(axi_wready),
	.s02_axi_bresp(axi_bresp),
	.s02_axi_bvalid(axi_bvalid),
	.s02_axi_bready(axi_bready),
	.s02_axi_araddr(axi_araddr),
    .s02_axi_arprot(2'b00),
	.s02_axi_arvalid(axi_arvalid),
	.s02_axi_arready(axi_arready),
	.s02_axi_rdata(axi_rdata),
	.s02_axi_rresp(axi_rresp),
	.s02_axi_rvalid(axi_rvalid),
    .s02_axi_rready(axi_rready)
);


initial 
begin
    clk = 1;
    rst_n = 0;
    rw = 1;
    reload = 0;

    #20 rst_n = 1;

    //setting the cntl reg
    axi_lite_write(4, 32'd0);
    axi_lite_write(8, 32'd8);

    //rw = 0;
    axi_lite_write(0, 32'h00000000);

    #15
    //rw = 1;
    //reload = 1;
    axi_lite_write(0, 32'h00000003);
    #15 
    //rw = 1;
    //reload = 0;
    axi_lite_write(0, 32'h00000001);


    axis_in_tlast = 1'b0;
    #5 axis_in_data = 32'd0;

    axis_in_valid = 1'b1;

    //batch of 26 sigs
    axis_in_data = 32'b11111111111111111111111111111111;
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
    #10 axis_in_data = 32'b00000000000000000000000000000000;

    

    //another batch of 36
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
    
    //couple of extra signals
    #10 axis_in_data = 32'hcccccccc;
    axis_in_tlast = 1'b1;

    #5 axis_in_valid = 1'b0;
    axis_in_data = 32'd0;
    axis_in_tlast = 1'b0;
    

    //write test done
    //start read test
    axis_out_ready = 1'b0;

    axi_lite_write(4, 32'd0);
    axi_lite_write(8, 32'd1);

    //rw = 0;
    axi_lite_write(0, 32'h00000000);

    #15
    //rw = 0;
    //reload = 1;
    axi_lite_write(0, 32'h00000002);
    #15 
    //rw = 0;
    //reload = 0;
    axi_lite_write(0, 32'h00000000);

    axis_out_ready = 1'b1;
    
    $finish;
end
endmodule
