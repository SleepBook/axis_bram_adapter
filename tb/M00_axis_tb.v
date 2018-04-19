`timescale 1 ns / 100 ps

module M00_module_test;

reg clk, rst_n;
always #5 clk = ~clk;

reg [31:0] din_from_buf;
reg din_valid;
reg last;
wire din_accep;

wire axis_valid;
wire [31 :0] axis_data;
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

    # 400 last = 0;
    axis_ready = 1;
    din_valid = 1;
    #2 din_from_buf = 32'd0;
    #10 din_from_buf = 32'd1;
     #10 din_from_buf = 32'd2;
    
      #10 din_from_buf = 32'd3;
       #10 din_from_buf = 32'd4;
        #10 din_from_buf = 32'd5; din_valid = 0;
            #5 din_valid = 1;
         #10 din_from_buf = 32'd6;
          #10 din_from_buf = 32'd7;
    
   
    $finish;
end
endmodule
