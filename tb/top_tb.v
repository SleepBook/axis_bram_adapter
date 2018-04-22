`timescale 1 ns / 100 ps

module top_module_test;


reg clk, rst_n;
always #5 clk = ~clk;

wire bram_en;
wire bram_wen;
wire bram_addr;
wire to_bram;
wire ready;
wire out_valid;
wire [31:0] out_data;
wire [3:0] out_strb;
wire out_last;



reg[31:0] from_bram;
reg[31:0] in_data;
reg[3:0] in_tstrb;
reg in_tlast;
reg in_tvalid;
reg out_ready;

axis_bram_adapter_v1_0 test(
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
	.s02_axi_aclk(clk),
	.s02_axi_aresetn(rst_n),
		input wire [C_S02_AXI_ADDR_WIDTH-1 : 0] s02_axi_awaddr,
		input wire [2 : 0] s02_axi_awprot,
		input wire  s02_axi_awvalidear

		output wire  s02_axi_awready,
		input wire [C_S02_AXI_DATA_WIDTH-1 : 0] s02_axi_wdata,
		input wire [(C_S02_AXI_DATA_WIDTH/8)-1 : 0] s02_axi_wstrb,
		input wire  s02_axi_wvalid,
		output wire  s02_axi_wready,
		output wire [1 : 0] s02_axi_bresp,
		output wire  s02_axi_bvalid,
		input wire  s02_axi_bready,
		input wire [C_S02_AXI_ADDR_WIDTH-1 : 0] s02_axi_araddr,
		input wire [2 : 0] s02_axi_arprot,
		input wire  s02_axi_arvalid,
		output wire  s02_axi_arready,
		output wire [C_S02_AXI_DATA_WIDTH-1 : 0] s02_axi_rdata,
		output wire [1 : 0] s02_axi_rresp,
		output wire  s02_axi_rvalid,
		input wire  s02_axi_rready
	

initial 
begin
    clk = 0;
    rst_n = 0;
    axis_tlast = 0;
    #10 rst_n = 1;

    axis_valid = 1;
    dout_accep = 1;
    #2 axis_data = 32'd0;
    #10 axis_data = 32'd1;
     #10 axis_data = 32'd2;
     #5 dout_accep = 0;
     #20 dout_accep = 1;
    
      #10 axis_data = 32'd3;
       #10 axis_data = 32'd4;
        #10 axis_data = 32'd5; 
        axis_tlast = 1;
            
         #10 axis_data = 32'd6; axis_valid = 0;
          #10 axis_data = 32'd7;
    
   
    $finish;
end
endmodule
