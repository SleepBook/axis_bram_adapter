`timescale 1 ns /1 ps

module axis_bram_adapter_v1_0_cntl #
(
    parameter integer BRAM_ADDR_LENGTH = 12,
    parameter integer TO_AXIS_MUX_CNTL_BITS = 6,
    parameter integer BRAM_WIDTH_IN_WORD = 36
)
(
    input wire clk,
    input wire rstn,
    input wire rw, 
    input wire addr_reload,
    input wire[BRAM_ADDR_LENGTH-1 : 0] bram_start_index,
    input wire[BRAM_ADDR_LENGTH-1 : 0] bram_bound_index,
    input wire stream_in_valid,
    input wire stream_out_accep,
    output wire stream_in_accep,
    output wire stream_out_valid,
    output reg[BRAM_WIDTH_IN_WORD*2-1:0] from_axis_mux_cntl,
    output reg[TO_AXIS_MUX_CNTL_BITS -1 : 0] to_axis_mux_cntl,
    output reg bram_wen,
    output reg bram_en,
    output reg [BRAM_ADDR_LENGTH-1:0] bram_index,
    output wire stream_out_tlast
);

reg [5:0] cnt;
reg ptr_start;
reg ptr_end;
reg ptr_end_by_one;
reg rw_pre;

reg bram_en_delay;

//correct the first read scarenio
wire read_bram_done;
assign read_bram_done = bram_en_delay && (!rw_pre);

//write to bram never stalls once the master is ready
assign stream_in_accep = rw;
//read from bram stalls the first time initiate the read, then never stalls
assign stream_out_valid = ((!rw) && (cnt!=12'd0)) || ((cnt==12'd0) && (!rw) && read_bram_done);


//the resetting logic may have some issue
always@(posedge clk)
begin
    if(!rstn)
    begin
        cnt <= 6'b0;
    end
    else
    begin
        casex({rw, rw_pre, stream_in_valid, stream_out_accep})
            4'b111x, 4'b00x1:begin
                cnt <= cnt + 1;
                if(cnt == BRAM_WIDTH_IN_WORD - 1)
                begin
                    cnt <= 6'b0;
                end
            end
            4'b10xx, 4'b01xx:begin
                cnt <= 6'd0;
            end
            default: cnt <= cnt;
        endcase
    end
end


always@(posedge clk)
begin
    if(!rstn)
    begin
        rw_pre <= 1'b0;
    end
    else
    begin
        rw_pre <= rw;
    end
end


always@(*)
begin
    if(cnt == 0)
    begin
        ptr_start = 1'b1;
    end
    else
    begin
        ptr_start = 1'b0;
    end

    if(cnt == BRAM_WIDTH_IN_WORD - 2)
    begin
        ptr_end_by_one = 1'b1;
    end
    else
    begin
        ptr_end_by_one = 1'b0;
    end

    if(cnt == BRAM_WIDTH_IN_WORD - 1)
    begin
        ptr_end = 1'b1;
    end
    else
    begin
        ptr_end = 1'b0;
    end
end


always@(posedge clk)
begin
    if(!rstn)
    begin
        bram_index <= 12'd0;
        bram_en <= 1'b0;
        bram_wen <= 1'b0;
    end
    else if(addr_reload)
    begin
        bram_index <= bram_start_index;
        bram_en <= 1'b0;
        bram_wen <= 1'b0;
    end
    else
    begin
        casex({rw, ptr_start, ptr_end, ptr_end_by_one, stream_in_valid, stream_out_accep, bram_en_delay, read_bram_done})
            8'b10101xxx: begin
                bram_en <= 1'b1;
                bram_wen <= 1'b1;
                bram_index <= bram_index;
            end
            8'b10001x1x: begin
                bram_en <= 1'b0;
                bram_wen <= 1'b0;
                bram_index <= bram_index + 1;
            end
            //modifiy here, shouldn't be sensitive to stream_out_accep, this also accomdiate 
            //the first read
            8'b0001xxxx: begin
                bram_en <= 1'b1;
                bram_wen <= 1'b0;
                bram_index <= bram_index;
            end
            8'b0010xxxx: begin
                bram_en <= 1'b0;
                bram_wen <= 1'b0;
                bram_index <= bram_index + 1;
            end
            8'b0100xxx0:begin
                bram_en <= 1'b1;
                bram_wen <= 1'b0;
                bram_index <= bram_index;
            end
            default:begin
                bram_en <= 1'b0;
                bram_wen <= 1'b0;
                bram_index <= bram_index;
            end
        endcase
    end
end


always@(posedge clk)
begin
    if(!rstn)
    begin
        bram_en_delay <= 1'b0;
    end
    else
    begin
        bram_en_delay <= bram_en;
    end
end


assign stream_out_tlast = ptr_end && (bram_index == bram_bound_index);

//stream in buf cntl
//for each mux, high bit: 0 keep, 1 change
//low bit: 0 bram, 1 axis
always@(*)
begin
    casex({cnt,rw,read_bram_done})
        {{6'd0},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b110000000000000000000000000000000000000000000000000000000000000000000000;
        {{6'd1},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b001100000000000000000000000000000000000000000000000000000000000000000000;
        {{6'd2},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000011000000000000000000000000000000000000000000000000000000000000000000;
        {{6'd3},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000110000000000000000000000000000000000000000000000000000000000000000;
        {{6'd4},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000001100000000000000000000000000000000000000000000000000000000000000;
        {{6'd5},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000011000000000000000000000000000000000000000000000000000000000000;
        {{6'd6},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000110000000000000000000000000000000000000000000000000000000000;
        {{6'd7},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000001100000000000000000000000000000000000000000000000000000000;
        {{6'd8},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000011000000000000000000000000000000000000000000000000000000;
        {{6'd9},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000110000000000000000000000000000000000000000000000000000;
        {{6'd10},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000001100000000000000000000000000000000000000000000000000;
        {{6'd11},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000011000000000000000000000000000000000000000000000000;
        {{6'd12},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000110000000000000000000000000000000000000000000000;
        {{6'd13},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000001100000000000000000000000000000000000000000000;
        {{6'd14},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000011000000000000000000000000000000000000000000;
        {{6'd15},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000110000000000000000000000000000000000000000;
        {{6'd16},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000001100000000000000000000000000000000000000;
        {{6'd17},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000011000000000000000000000000000000000000;
        {{6'd18},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000110000000000000000000000000000000000;
        {{6'd19},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000001100000000000000000000000000000000;
        {{6'd20},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000011000000000000000000000000000000;
        {{6'd21},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000110000000000000000000000000000;
        {{6'd22},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000001100000000000000000000000000;
        {{6'd23},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000011000000000000000000000000;
        {{6'd24},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000110000000000000000000000;
        {{6'd25},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000001100000000000000000000;
        {{6'd26},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000011000000000000000000;
        {{6'd27},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000110000000000000000;
        {{6'd28},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000001100000000000000;
        {{6'd29},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000011000000000000;
        {{6'd30},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000110000000000;
        {{6'd31},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000001100000000;
        {{6'd32},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000011000000;
        {{6'd33},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000110000;
        {{6'd34},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000001100;
        {{6'd35},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000000011;
        {{6'd35},{1'b0},{1'bx}}: from_axis_mux_cntl <= 72'b101010101010101010101010101010101010101010101010101010101010101010101010;
        {{6'd0},{1'b0},{1'b0}}: from_axis_mux_cntl <= 72'b101010101010101010101010101010101010101010101010101010101010101010101010;
        default: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000000000;
    endcase
end

//stream out buf cntl
always@(*)
begin
    if(!rw)
    begin
        to_axis_mux_cntl <= cnt;
    end
    else
    begin
        to_axis_mux_cntl <= 0;
    end
end

endmodule
