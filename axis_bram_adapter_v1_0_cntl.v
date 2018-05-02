`timescale 1 ns /1 ps

module axis_bram_adapter_v1_0_cntl #
(
    parameter integer BRAM_DEPTH = 12,
    parameter integer TO_AXIS_MUX_CNTL_BITS = 6,
    parameter integer BRAM_WIDTH_IN_WORD = 36
)
(
    input wire clk,
    input wire rstn,
    input wire rw, 
    input wire addr_reload,
    input wire[BRAM_DEPTH-1 : 0] bram_start_index,
    input wire[BRAM_DEPTH-1 : 0] bram_bound_index,
    input wire stream_in_valid,
    input wire stream_out_accep,
    output wire stream_in_accep,
    output wire stream_out_valid,
    output reg[BRAM_WIDTH_IN_WORD*2-1:0] from_axis_mux_cntl,
    output reg[TO_AXIS_MUX_CNTL_BITS -1 : 0] to_axis_mux_cntl,
    output reg bram_wen,
    output reg bram_en,
    output reg [BRAM_DEPTH-1:0] bram_index,
    output wire stream_out_tlast
);

reg [5:0] cnt;

//all wires
reg ptr_start;
reg ptr_end;
reg ptr_end_by_one;
reg ptr_end_by_two;

//real latched
reg bram_en_delay;
reg bram_en_2_delay;

always@(posedge clk)
begin
    if(!rstn)
    begin
        bram_en_delay <= 1'b0;
        bram_en_2_delay <= 1'b0;
    end
    else
    begin
        bram_en_delay <= bram_en;
        bram_en_2_delay <= bram_en_delay;
    end
end

assign stream_in_accep = rw;
assign stream_out_valid = (!rw) && ((!ptr_start) || (ptr_start && bram_en_2_delay));

wire stream_in_shk;
wire stream_out_shk;
assign stream_in_shk = stream_in_accep && stream_in_valid;
assign stream_out_shk = stream_out_accep;

always@(posedge clk)
begin
    if(!rstn)
    begin
        cnt <= {BRAM_DEPTH{1'b0}};
    end
    else
    begin
        casex({rw, stream_in_valid, stream_out_accep, bram_en_2_delay, ptr_start})
            5'b11xxx, 5'b0x1x0, 5'b0x111:begin
                cnt <= cnt + 1;
                if(cnt == BRAM_WIDTH_IN_WORD - 1)
                begin
                    cnt <= {BRAM_DEPTH{1'b0}};
                end
            end
            default: cnt <= cnt;
        endcase
    end
end


always@(posedge clk)
begin
    if(!rstn)
    begin
        bram_en <= 1'b0;
        bram_wen <= 1'b0;
    end
    else 
    //add handshake sig in sensitive list to make sure en is only set for one cycle
    begin
        casex({rw, ptr_start, ptr_end_by_two, ptr_end, bram_en_2_delay, bram_en_delay, bram_en, stream_in_shk, stream_out_shk})
            9'b1001xxx1x:begin
                bram_en <= 1'b1;
                bram_wen <= 1'b1;
            end
            9'b0010xxxx1:begin
                bram_en <= 1'b1;
                bram_wen <= 1'b0;
            end
            9'b0100000xx:begin
                bram_en <= 1'b1;
                bram_wen <= 1'b0;
            end
            default:begin
                bram_en <= 1'b0;
                bram_wen <= 1'b0;
            end
        endcase
    end
end

always@(posedge clk)
begin
    if(!rstn)
    begin
        bram_index <= {BRAM_DEPTH{1'b0}};
    end
    else if(addr_reload)
    begin
        bram_index <= {BRAM_DEPTH{1'b0}};
    end
    else if(bram_en_delay)
    begin
        bram_index <= bram_index + 1;
    end
    else
    begin
        bram_index <= bram_index;
    end
end

assign stream_out_tlast = ptr_end && (bram_index == bram_bound_index);

always@(*)
begin
    if(cnt == 0)
    begin
        ptr_start <= 1'b1;
    end
    else
    begin
        ptr_start <= 1'b0;
    end

    if(cnt == BRAM_WIDTH_IN_WORD - 2)
    begin
        ptr_end_by_one <= 1'b1;
    end
    else
    begin
        ptr_end_by_one <= 1'b0;
    end

    if(cnt == BRAM_WIDTH_IN_WORD - 1)
    begin
        ptr_end <= 1'b1;
    end
    else
    begin
        ptr_end <= 1'b0;
    end

    if(cnt == BRAM_WIDTH_IN_WORD - 3)
    begin
        ptr_end_by_two <= 1'b1;
    end
    else
    begin
        ptr_end_by_two <= 1'b0;
    end
end


//stream in buf cntl
//for each mux, high bit: 0 keep, 1 change
//low bit: 0 bram, 1 axis
/*
always@(*)
begin
    casex({cnt,rw,read_bram_done})
        {{6'd35},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b110000000000000000000000000000000000000000000000000000000000000000000000;
        {{6'd34},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b001100000000000000000000000000000000000000000000000000000000000000000000;
        {{6'd33},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000011000000000000000000000000000000000000000000000000000000000000000000;
        {{6'd32},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000110000000000000000000000000000000000000000000000000000000000000000;
        {{6'd31},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000001100000000000000000000000000000000000000000000000000000000000000;
        {{6'd30},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000011000000000000000000000000000000000000000000000000000000000000;
        {{6'd29},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000110000000000000000000000000000000000000000000000000000000000;
        {{6'd28},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000001100000000000000000000000000000000000000000000000000000000;
        {{6'd27},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000011000000000000000000000000000000000000000000000000000000;
        {{6'd26},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000110000000000000000000000000000000000000000000000000000;
        {{6'd25},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000001100000000000000000000000000000000000000000000000000;
        {{6'd24},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000011000000000000000000000000000000000000000000000000;
        {{6'd23},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000110000000000000000000000000000000000000000000000;
        {{6'd22},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000001100000000000000000000000000000000000000000000;
        {{6'd21},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000011000000000000000000000000000000000000000000;
        {{6'd20},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000110000000000000000000000000000000000000000;
        {{6'd19},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000001100000000000000000000000000000000000000;
        {{6'd18},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000011000000000000000000000000000000000000;
        {{6'd17},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000110000000000000000000000000000000000;
        {{6'd16},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000001100000000000000000000000000000000;
        {{6'd15},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000011000000000000000000000000000000;
        {{6'd14},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000110000000000000000000000000000;
        {{6'd13},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000001100000000000000000000000000;
        {{6'd12},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000011000000000000000000000000;
        {{6'd11},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000110000000000000000000000;
        {{6'd10},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000001100000000000000000000;
        {{6'd9},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000011000000000000000000;
        {{6'd8},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000110000000000000000;
        {{6'd7},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000001100000000000000;
        {{6'd6},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000011000000000000;
        {{6'd5},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000110000000000;
        {{6'd4},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000001100000000;
        {{6'd3},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000011000000;
        {{6'd2},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000110000;
        {{6'd1},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000001100;
        {{6'd0},{1'b1},{1'bx}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000000011;
        {{6'd35},{1'b0},{1'bx}}: from_axis_mux_cntl <= 72'b101010101010101010101010101010101010101010101010101010101010101010101010;
        {{6'd0},{1'b0},{1'b0}}: from_axis_mux_cntl <= 72'b101010101010101010101010101010101010101010101010101010101010101010101010;
        default: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000000000;
    endcase
end
*/

always@(*)
begin
    casex({cnt,rw})
        {{6'd35},{1'b1}}: from_axis_mux_cntl <= 72'b110000000000000000000000000000000000000000000000000000000000000000000000;
        {{6'd34},{1'b1}}: from_axis_mux_cntl <= 72'b001100000000000000000000000000000000000000000000000000000000000000000000;
        {{6'd33},{1'b1}}: from_axis_mux_cntl <= 72'b000011000000000000000000000000000000000000000000000000000000000000000000;
        {{6'd32},{1'b1}}: from_axis_mux_cntl <= 72'b000000110000000000000000000000000000000000000000000000000000000000000000;
        {{6'd31},{1'b1}}: from_axis_mux_cntl <= 72'b000000001100000000000000000000000000000000000000000000000000000000000000;
        {{6'd30},{1'b1}}: from_axis_mux_cntl <= 72'b000000000011000000000000000000000000000000000000000000000000000000000000;
        {{6'd29},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000110000000000000000000000000000000000000000000000000000000000;
        {{6'd28},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000001100000000000000000000000000000000000000000000000000000000;
        {{6'd27},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000011000000000000000000000000000000000000000000000000000000;
        {{6'd26},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000110000000000000000000000000000000000000000000000000000;
        {{6'd25},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000001100000000000000000000000000000000000000000000000000;
        {{6'd24},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000011000000000000000000000000000000000000000000000000;
        {{6'd23},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000110000000000000000000000000000000000000000000000;
        {{6'd22},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000001100000000000000000000000000000000000000000000;
        {{6'd21},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000011000000000000000000000000000000000000000000;
        {{6'd20},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000110000000000000000000000000000000000000000;
        {{6'd19},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000001100000000000000000000000000000000000000;
        {{6'd18},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000011000000000000000000000000000000000000;
        {{6'd17},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000110000000000000000000000000000000000;
        {{6'd16},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000001100000000000000000000000000000000;
        {{6'd15},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000011000000000000000000000000000000;
        {{6'd14},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000110000000000000000000000000000;
        {{6'd13},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000001100000000000000000000000000;
        {{6'd12},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000011000000000000000000000000;
        {{6'd11},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000110000000000000000000000;
        {{6'd10},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000001100000000000000000000;
        {{6'd9},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000011000000000000000000;
        {{6'd8},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000110000000000000000;
        {{6'd7},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000001100000000000000;
        {{6'd6},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000011000000000000;
        {{6'd5},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000110000000000;
        {{6'd4},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000001100000000;
        {{6'd3},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000011000000;
        {{6'd2},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000110000;
        {{6'd1},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000001100;
        {{6'd0},{1'b1}}: from_axis_mux_cntl <= 72'b000000000000000000000000000000000000000000000000000000000000000000000011;
        {{6'd35},{1'b0}}: from_axis_mux_cntl <= 72'b101010101010101010101010101010101010101010101010101010101010101010101010;
        {{6'd0},{1'b0}}: from_axis_mux_cntl <= 72'b101010101010101010101010101010101010101010101010101010101010101010101010;
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
