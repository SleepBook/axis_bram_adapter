`timescale 1 ns / 100 ps

module S00_module_test;


reg clk, rst_n;
always #5 clk = ~clk;

wire [31:0] dout_to_buf;
wire dout_valid;
reg dout_accep;

reg axis_valid;
reg [31 :0] axis_data;
reg axis_tstrb;
reg axis_tlast;
wire  axis_ready;



axis_bram_adapter_v1_0_S00_AXIS test(
    .DOUT_TO_BRAM(dout_to_buf),
    .DOUT_VALID(dout_valid),
    .DOUT_ACCEP(dout_accep),
    .S_AXIS_ACLK(clk),
    .S_AXIS_ARESETN(rst_n),
    .S_AXIS_TVALID(axis_valid),
    .S_AXIS_TDATA(axis_data),
    .S_AXIS_TSTRB(axis_tstrb),
    .S_AXIS_TLAST(axis_tlast),
    .S_AXIS_TREADY(axis_ready));


initial 
begin
    clk = 0;
    rst_n = 0;
    #10 rst_n = 1;

    axis_valid = 1;
    dout_accep = 1;
    #2 axis_data = 32'd0;
    #10 axis_data = 32'd1;
     #10 axis_data = 32'd2;
    
      #10 axis_data = 32'd3;
       #10 axis_data = 32'd4;
        #10 axis_data = 32'd5; 
            
         #10 axis_data = 32'd6;
          #10 axis_data = 32'd7;
    
   
    $finish;
end
endmodule
