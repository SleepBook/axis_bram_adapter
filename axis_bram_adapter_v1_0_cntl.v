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
    output wire stream_out_tlast,
    //ports for debugging 
    output reg[5:0] cnt
);

//reg [5:0] cnt;
reg ptr_start;
reg ptr_end;
reg ptr_end_by_one;
reg rw_pre;

//current design the buffer never stalls
assign stream_in_accep = rw;
assign stream_out_valid = !rw;

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
        casex({rw, ptr_start, ptr_end, ptr_end_by_one, stream_in_valid, stream_out_accep})
            6'b10101x: begin
                bram_en <= 1'b1;
                bram_wen <= 1'b1;
                bram_index <= bram_index;
            end
            6'b11001x: begin
                bram_en <= 1'b0;
                bram_wen <= 1'b0;
                bram_index <= bram_index + 1;
            end

            6'b0001x1: begin
                bram_en <= 1'b1;
                bram_wen <= 1'b0;
                bram_index <= bram_index;
            end
            6'b0010x1: begin
                bram_en <= 1'b0;
                bram_wen <= 1'b0;
                bram_index <= bram_index + 1;
            end

            default:begin
                bram_en <= 1'b0;
                bram_wen <= 1'b0;
                bram_index <= bram_index;
            end
        endcase
    end
end

assign stream_out_tlast = ptr_end && (bram_index == bram_bound_index);

//stream in buf cntl
//for each mux, high bit: 0 keep, 1 change
//low bit: 0 bram, 1 axis
always@(*)
begin
    case({cnt,rw})
        7'd1: from_axis_mux_cntl <= 72'b110000000000000000000000000000000000000000000000000000000000000000000000;
        7'd3: from_axis_mux_cntl <= 72'b001100000000000000000000000000000000000000000000000000000000000000000000;
        7'd5: from_axis_mux_cntl <= 72'b000011000000000000000000000000000000000000000000000000000000000000000000;
        7'd7: from_axis_mux_cntl <= 72'b000000110000000000000000000000000000000000000000000000000000000000000000;
        7'd9: from_axis_mux_cntl <= 72'b000000001100000000000000000000000000000000000000000000000000000000000000;
        7'd11: from_axis_mux_cntl <= 72'b000000000011000000000000000000000000000000000000000000000000000000000000;
        7'd13: from_axis_mux_cntl <= 72'b000000000000110000000000000000000000000000000000000000000000000000000000;
        7'd15: from_axis_mux_cntl <= 72'b000000000000001100000000000000000000000000000000000000000000000000000000;
        7'd17: from_axis_mux_cntl <= 72'b000000000000000011000000000000000000000000000000000000000000000000000000;
        7'd19: from_axis_mux_cntl <= 72'b000000000000000000110000000000000000000000000000000000000000000000000000;
        7'd21: from_axis_mux_cntl <= 72'b000000000000000000001100000000000000000000000000000000000000000000000000;
        7'd23: from_axis_mux_cntl <= 72'b000000000000000000000011000000000000000000000000000000000000000000000000;
        7'd25: from_axis_mux_cntl <= 72'b000000000000000000000000110000000000000000000000000000000000000000000000;
        7'd27: from_axis_mux_cntl <= 72'b000000000000000000000000001100000000000000000000000000000000000000000000;
        7'd29: from_axis_mux_cntl <= 72'b000000000000000000000000000011000000000000000000000000000000000000000000;
        7'd31: from_axis_mux_cntl <= 72'b000000000000000000000000000000110000000000000000000000000000000000000000;
        7'd33: from_axis_mux_cntl <= 72'b000000000000000000000000000000001100000000000000000000000000000000000000;
        7'd35: from_axis_mux_cntl <= 72'b000000000000000000000000000000000011000000000000000000000000000000000000;
        7'd37: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000110000000000000000000000000000000000;
        7'd39: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000001100000000000000000000000000000000;
        7'd41: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000011000000000000000000000000000000;
        7'd43: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000110000000000000000000000000000;
        7'd45: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000001100000000000000000000000000;
        7'd47: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000011000000000000000000000000;
        7'd49: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000110000000000000000000000;
        7'd51: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000001100000000000000000000;
        7'd53: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000011000000000000000000;
        7'd55: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000110000000000000000;
        7'd57: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000001100000000000000;
        7'd59: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000011000000000000;
        7'd61: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000110000000000;
        7'd63: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000001100000000;
        7'd65: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000011000000;
        7'd67: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000110000;
        7'd69: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000001100;
        7'd71: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000000011;
        7'd70: from_axis_mux_cntl <= 72'b101010101010101010101010101010101010101010101010101010101010101010101010;
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
