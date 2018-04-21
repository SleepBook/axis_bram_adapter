`timescale 1 ns / 100 ps

module adapter_cntl_test;

reg clk, rst_n;
always #5 clk = ~clk;

wire bram_en;
wire bram_wen;
wire [8:0] bram_addr;
wire [31:0] bram_in;

reg [31:0] bram_out;
reg rw;
reg [8:0] bram_start_addr;
reg [8:0] bram_end_addr;
reg input_valid;
reg output_accep;

wire [71:0] in_mux_cntl;
wire [5:0]  out_mux_cntl;
wire last;

//debug ports output
wire[5:0] count;
wire endw;
wire startw;
wire endb1w;

axis_bram_adapter_v1_0_cntl test(
    .clk(clk),
    .rstn(rst_n),
    .rw(rw),
    .index_cntl(bram_start_addr),
    .size_cntl(bram_end_addr),
    .stream_in_valid(input_valid),
    .stream_out_accep(output_accep),
    .from_axis_mux_cntl(in_mux_cntl),
    .to_axis_mux_cntl(out_mux_cntl),
    .bram_wen(bram_wen),
    .bram_en(bram_en),
    .bram_index(bram_addr),
    .stream_out_tlast(last),
    .cnt(count),
    .ptr_end(endw),
    .ptr_start(startw),
    .ptr_end_by_one(endb1w)
);



initial 
begin
    clk = 0;
    bram_start_addr = 0;
    bram_end_addr = 15;


    rst_n = 0;
    #15 rst_n = 1;

    //test write to controller 
     rw  = 1;
    input_valid = 0;
#15 input_valid = 1;
//#300 rw = 0;
 // output_accep = 1;

//    
//    axis_valid = 1;
//    dout_accep = 1;
//    #2 axis_data = 32'd0;
//    #10 axis_data = 32'd1;
//     #10 axis_data = 32'd2;
//     #5 dout_accep = 0;
//     #20 dout_accep = 1;
//    
//      #10 axis_data = 32'd3;
//       #10 axis_data = 32'd4;
//        #10 axis_data = 32'd5; 
//        axis_tlast = 1;
//            
//         #10 axis_data = 32'd6; axis_valid = 0;
//          #10 axis_data = 32'd7;
//    
   
//    $finish;
end
endmodule
