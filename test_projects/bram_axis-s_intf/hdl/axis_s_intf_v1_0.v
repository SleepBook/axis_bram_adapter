`timescale 1 ns / 1 ps
	module axis_s_intf_v1_0 #
	(
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,
		parameter integer BRAM_DEPTH = 12
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
        input wire shifter,
        output reg [31:0] bram_data,
        output reg[BRAM_DEPTH -1:0] bram_addr, 
        output wire bram_clk,
        output reg bram_en,
        output reg bram_wen,
        output wire[7:0] sample_out
	);

    wire from_axis_valid;
    wire [31:0] from_axis_data;
    wire from_axis_accep;
    assign from_axis_accep = 1'b1;

    wire en;
    
    reg [31:0] buffer [15:0];
    assign sample_out = buffer[15][7:0];
    
    reg shifter_delay;
    wire flip;
    assign flip = shifter ^ shifter_delay;

    always@(posedge s00_axis_aclk)
    begin
        shifter_delay <= shifter;
    end
        
    always@(posedge s00_axis_aclk)
    begin
        if(flip || en)
        begin
            buffer[15] <= buffer[14];
            buffer[14] <= buffer[13];
            buffer[13] <= buffer[12];
            buffer[12] <= buffer[11];
            buffer[11] <= buffer[10];
            buffer[10] <= buffer[9];
            buffer[9] <= buffer[8];
            buffer[8] <= buffer[7];
            buffer[7] <= buffer[6];
            buffer[6] <= buffer[5];
            buffer[5] <= buffer[4];
            buffer[4] <= buffer[3];
            buffer[3] <= buffer[2];
            buffer[2] <= buffer[1];
            buffer[1] <= buffer[0];
            buffer[0] <= from_axis_data;
        end
        else
        begin
            buffer[15] = buffer[15];
            buffer[14] = buffer[14];
            buffer[13] = buffer[13];
            buffer[12] = buffer[12];
            buffer[11] = buffer[11];
            buffer[10] = buffer[10];
            buffer[9] = buffer[9];
            buffer[8] = buffer[8];
            buffer[7] = buffer[7];
            buffer[6] = buffer[6];
            buffer[5] = buffer[5];
            buffer[4] = buffer[4];
            buffer[3] = buffer[3];
            buffer[2] = buffer[2];
            buffer[1] = buffer[1];
            buffer[0] = buffer[0];
        end
    end

    assign en = s00_axis_tvalid && from_axis_accep;

    always@(posedge s00_axis_aclk)
    begin
        if(en)
        begin
        bram_data <= from_axis_data;
        end
        else
        begin
            bram_data <= bram_data;
        end
    end

    assign bram_clk = s00_axis_aclk;

    always@(posedge s00_axis_aclk)
    begin
        if(!s00_axis_aresetn)
        begin
            bram_addr <= 12'd0;
        end
        else if(bram_restart)
        begin
            bram_addr <= 12'd0;
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
                bram_wen <= 1'b1;
            end
            else
            begin
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
