
`timescale 1 ns / 1 ps

	module axis_s_intf_v1_0 #
	(
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,
		parameter integer BRAM_DEPTH = 13
	)
	(
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,
        //testing port
        input wire bram_restart,
        output reg [7:0] cnt,
        output wire [31:0] bram_data,
        output reg[BRAM_DEPTH -1:0] bram_addr, 
        output wire bram_clk,
        output reg bram_en,
        output reg bram_wen
	);

    wire from_axis_valid;
    wire [31:0] from_axis_data;
    wire from_axis_accep;
    assign from_axis_accep = 1'b1;

    wire en;
    assign en = s00_axis_tvalid && from_axis_accep;

    reg [31:0] internal_from_axis;
   
    always@(negedge s00_axis_aclk)
    begin
        if(!s00_axis_aresetn)
        begin
            internal_from_axis <= 32'd0;
        end
        else if(en)
        begin
            internal_from_axis <= from_axis_data;
            //internal_from_axis <= bram_addr;
        end
        else
        begin
            internal_from_axis <= internal_from_axis;
        end
    end

    assign bram_data = internal_from_axis;
    assign bram_clk = s00_axis_aclk;

    always@(posedge s00_axis_aclk)
    begin
        if(!s00_axis_aresetn || bram_restart)
        begin
            bram_addr <= 0;
        end
        else if(en)
        begin
            bram_addr <= bram_addr + 1;
        end
        else 
        begin
            bram_addr <= bram_addr;
        end
    end

    always@(posedge s00_axis_aclk)
    begin
        if(!s00_axis_aresetn || bram_restart)
        begin
            cnt <= 8'd0;
        end
        else if(en)
        begin
            cnt <= cnt + 1;
        end
        else
        begin
            cnt <= cnt;
        end
    end

    always@(posedge s00_axis_aclk)
    begin
        if(!s00_axis_aresetn)
        begin
            bram_en <= 1'b0;
            bram_wen <= 1'b0;
        end
        else
        begin
            bram_en <= 1'b1;
            if(en)
            begin
                //bram_en <= 1'b1;
                bram_wen <= 1'b1;
            end
            else
            begin
                //bram_en <= bram_en;
                //bram_wen <= bram_wen;
                //bram_en <= 1'b0;
                bram_wen <= 1'b0;
            end
        end
    end

   
// Instantiation of Axi Bus Interface S00_AXIS
	axis_bram_adapter_v1_0_S00_AXIS # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
	) axis_s_intf_v1_0_S00_AXIS_inst (
        .DOUT_TO_BUF(from_axis_data),
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

endmodule
