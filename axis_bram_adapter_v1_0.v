//Top Level block for AXI-S to BRAM adapter
//
// this module has an axis-slave adn axis-master interfaces
// to read and write axis stream
// the lite interface is used to switch R/W mode
// Internally this adapter has a buffer which matches the width
// of the bram, both streams read from or write to this buffer
`timescale 1 ns / 1 ps

	module axis_bram_adapter_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT	= 32,

		// Parameters of Axi Slave Bus Interface S02_AXI
		parameter integer C_S02_AXI_DATA_WIDTH	= 32,
		parameter integer C_S02_AXI_ADDR_WIDTH	= 5,

        //customer parameters
        parameter integer BRAM_DEPTH = 9,
        parameter integer BRAM_WIDTH_IN_WORD = 36,
        parameter integer BRAM_WIDTH = C_S00_AXIS_TDATA_WIDTH*BRAM_WIDTH_IN_WORD
        //which is 1152
	)
	(
		// Users to add ports here
        output wire BRAM_CLK,
        output wire BRAM_EN,
        output wire BRAM_WEN,
        output wire [BRAM_DEPTH - 1 : 0] BRAM_ADDR,
        output wire [BRAM_WIDTH - 1: 0] BRAM_IN,
        input wire  [BRAM_WIDTH - 1: 0] BRAM_OUT,

		// User ports ends

		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,

		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready,

		// Ports of Axi Slave Bus Interface S02_AXI
		input wire  s02_axi_aclk,
		input wire  s02_axi_aresetn,
		input wire [C_S02_AXI_ADDR_WIDTH-1 : 0] s02_axi_awaddr,
		input wire [2 : 0] s02_axi_awprot,
		input wire  s02_axi_awvalid,
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
	);

	function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction

    //how many bit the buf_ptr need
    //assume the read and write channel has same width
	localparam ptr_width  = clogb2(BRAM_WIDTH/C_S00_AXIS_TDATA_WIDTH -1);

    //User Resources
    
    //associate with from_axis
    wire [BRAM_WIDTH_IN_WORD*2 -1 : 0] from_axis_mux_cntl;
    wire from_axis_valid;
    wire from_axis_accep;
    wire [C_S00_AXIS_TDATA_WIDTH - 1: 0] axis_out;

    //associate with to axis
    wire [ptr_width-1 : 0] to_axis_mux_cntl;
    wire to_axis_valid;
    wire to_axis_accep;
    reg [C_M00_AXIS_TDATA_WIDTH - 1: 0] axis_in; //is actually wire

    //associate with axi-lite
    wire mode_rw;
    wire [BRAM_DEPTH - 1 : 0] rd_back_addr;
    wire [BRAM_DEPTH - 1 : 0] rd_back_sz;

    //datapath wires
    //suppose to be wire, but I need to describe them in behavior
    reg [BRAM_WIDTH -1 :0] buf_in;
    reg [BRAM_WIDTH -1 :0] buf_out;

    //datapath description
    genvar index;
    generate 
    for(index = 0;index <BRAM_WIDTH_IN_WORD;index = index +1)
    begin    
    always@(*)   
        begin
            case(from_axis_mux_cntl[index*2 + 1:index*2])
                2'b00, 2'b01: buf_in[index*32+31 : index*32] <= buf_in[index*32+31 : index*32];
                2'b10: buf_in[index*32+31 : index*32] <= BRAM_OUT[index*32+31 : index*32];
                2'b11: buf_in[index*32+31 : index*32] <= axis_out;
            endcase
        end
    end
    endgenerate

    assign BRAM_IN = buf_out;

    always@(*)
    begin
        case(to_axis_mux_cntl)
            6'd0: axis_in <= buf_out[0*32 +31 : 0*32];
        6'd1: axis_in <= buf_out[1*32 +31 : 1*32];
        6'd2: axis_in <= buf_out[2*32 +31 : 2*32];
        6'd3: axis_in <= buf_out[3*32 +31 : 3*32];
        6'd4: axis_in <= buf_out[4*32 +31 : 4*32];
        6'd5: axis_in <= buf_out[5*32 +31 : 5*32];
        6'd6: axis_in <= buf_out[6*32 +31 : 6*32];
        6'd7: axis_in <= buf_out[7*32 +31 : 7*32];
        6'd8: axis_in <= buf_out[8*32 +31 : 8*32];
        6'd9: axis_in <= buf_out[9*32 +31 : 9*32];
        6'd10: axis_in <= buf_out[10*32 +31 : 10*32];
        6'd11: axis_in <= buf_out[11*32 +31 : 11*32];
        6'd12: axis_in <= buf_out[12*32 +31 : 12*32];
        6'd13: axis_in <= buf_out[13*32 +31 : 13*32];
        6'd14: axis_in <= buf_out[14*32 +31 : 14*32];
        6'd15: axis_in <= buf_out[15*32 +31 : 15*32];
        6'd16: axis_in <= buf_out[16*32 +31 : 16*32];
        6'd17: axis_in <= buf_out[17*32 +31 : 17*32];
        6'd18: axis_in <= buf_out[18*32 +31 : 18*32];
        6'd19: axis_in <= buf_out[19*32 +31 : 19*32];
        6'd20: axis_in <= buf_out[20*32 +31 : 20*32];
        6'd21: axis_in <= buf_out[21*32 +31 : 21*32];
        6'd22: axis_in <= buf_out[22*32 +31 : 22*32];
        6'd23: axis_in <= buf_out[23*32 +31 : 23*32];
        6'd24: axis_in <= buf_out[24*32 +31 : 24*32];
        6'd25: axis_in <= buf_out[25*32 +31 : 25*32];
        6'd26: axis_in <= buf_out[26*32 +31 : 26*32];
        6'd27: axis_in <= buf_out[27*32 +31 : 27*32];
        6'd28: axis_in <= buf_out[28*32 +31 : 28*32];
        6'd29: axis_in <= buf_out[29*32 +31 : 29*32];
        6'd30: axis_in <= buf_out[30*32 +31 : 30*32];
        6'd31: axis_in <= buf_out[31*32 +31 : 31*32];
        6'd32: axis_in <= buf_out[32*32 +31 : 32*32];
        6'd33: axis_in <= buf_out[33*32 +31 : 33*32];
        6'd34: axis_in <= buf_out[34*32 +31 : 34*32];
        6'd35: axis_in <= buf_out[35*32 +31 : 35*32];
        endcase
     end

    //cntl logics
    
    axis_bram_adapter_v1_0_cntl controller(
        .clk(s00_axis_aclk),
        .rstn(s00_axis_arestn),
        .rw(mode_rw),
        .index_cntl(rd_back_addr),
        .size_cntl(rd_back_sz),
        .stream_in_valid(from_stream_valid),
        .stream_out_accep(to_stream_accep),
        .from_axis_mux_cntl(from_axis_mux_cntl),
        .to_axis_mux_cntl(to_axis_mux_cntl),
        .bram_wen(BRAM_WEN),
        .bram_en(BRAM_EN),
        .bram_index(BRAM_ADDR),
        .stream_out_tlast(m00_axis_tlast)
    );
    
    // User logic ends


// Instantiation of Axi Bus Interface S00_AXIS
	axis_bram_adapter_v1_0_S00_AXIS # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
	) axis_bram_adapter_v1_0_S00_AXIS_inst (
        .DOUT_TO_BRAM(axis_out),
        .DOUT_VALID(from_axis_valid),
        .DOUT_ACCEP(from_axis_accep),
		.S_AXIS_ACLK(s00_axis_aclk),
		.S_AXIS_ARESETN(s00_axis_aresetn),
		.S_AXIS_TREADY(s00_axis_tready),
		.S_AXIS_TDATA(s00_axis_tdata),
		.S_AXIS_TSTRB(s00_axis_tstrb),
		.S_AXIS_TLAST(s00_axis_tlast),
		.S_AXIS_TVALID(s00_axis_tvalid)
	);

// Instantiation of Axi Bus Interface M00_AXIS
	axis_bram_adapter_v1_0_M00_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
		.C_M_START_COUNT(C_M00_AXIS_START_COUNT)
	) axis_bram_adapter_v1_0_M00_AXIS_inst (
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN(m00_axis_aresetn),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TSTRB(m00_axis_tstrb),
		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TREADY(m00_axis_tready), 
        .DIN_FROM_BRAM(axis_in),
        .DIN_ACCEP(to_axis_accep),
        .DIN_VALID(to_axis_valid)
	);

// Instantiation of Axi Bus Interface S02_AXI
	axis_bram_adapter_v1_0_S02_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S02_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S02_AXI_ADDR_WIDTH)
	) axis_bram_adapter_v1_0_S02_AXI_inst (
		.S_AXI_ACLK(s02_axi_aclk),
		.S_AXI_ARESETN(s02_axi_aresetn),
		.S_AXI_AWADDR(s02_axi_awaddr),
		.S_AXI_AWPROT(s02_axi_awprot),
		.S_AXI_AWVALID(s02_axi_awvalid),
		.S_AXI_AWREADY(s02_axi_awready),
		.S_AXI_WDATA(s02_axi_wdata),
		.S_AXI_WSTRB(s02_axi_wstrb),
		.S_AXI_WVALID(s02_axi_wvalid),
		.S_AXI_WREADY(s02_axi_wready),
		.S_AXI_BRESP(s02_axi_bresp),
		.S_AXI_BVALID(s02_axi_bvalid),
		.S_AXI_BREADY(s02_axi_bready),
		.S_AXI_ARADDR(s02_axi_araddr),
		.S_AXI_ARPROT(s02_axi_arprot),
		.S_AXI_ARVALID(s02_axi_arvalid),
		.S_AXI_ARREADY(s02_axi_arready),
		.S_AXI_RDATA(s02_axi_rdata),
		.S_AXI_RRESP(s02_axi_rresp),
		.S_AXI_RVALID(s02_axi_rvalid),
		.S_AXI_RREADY(s02_axi_rready),
        .RW_MODE(mode_rw), 
        .RD_BACK_SIZE(rd_back_size),
        .RD_BACK_ADDR(rd_back_addr)
	);
	endmodule
