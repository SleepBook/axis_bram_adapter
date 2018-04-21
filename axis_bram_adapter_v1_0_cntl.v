`timescale 1 ns /1 ps

module axis_bram_adapter_v1_0_cntl
(
    parameter integer BRAM_ADDR_LENGTH = 9,
    parameter integer TO_AXIS_MUX_CNTL_BITS = 6,
    parameter integer BRAM_WIDTH_IN_WORD = 36
)
(
    input wire clk,
    input wire rstn,
    input wire rw, 
    input wire[BRAM_ADDR_LENGTH-1:0] index_cntl,
    input wire[BRAM_ADDR_LENGTH-1:0] size_cntl,
    input wire stream_in_valid,
    input wire stream_out_accep,
    output wire[BRAM_WIDTH_IN_WORD*2-1:0] from_axis_mux_cntl,
    output wire[TO_AXIS_MUX_CNTL_BITS - 1:0]  to_axis_mux_cntl,
    output reg bram_wen,
    output reg bram_en,
    output reg [BRAM_ADDR_LENGTH-1:0] bram_index,
    output reg stream_out_tlast
);

reg [5:0] cnt;
reg ptr_end;
reg ptr_start;
reg ptr_end_by_one;

always@(posedge clk)
begin
    if(!rstn)
    begin
        cnt <= 6'b0;
    end
    else
        if((rw&&stream_in_valid) || (!rw && stream_out_accep))
        begin
            cnt <= cnt + 1;
            if(cnt == BRAM_WIDTH_IN_WORD)
            begin
                cnt <= 6'b0;
            end
        end
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

    if(cnt == BRAM_WIDTH_IN_WORD - 1)
    begin
        ptr_end_by_one = 1'b1;
    end
    else
    begin
        ptr_end_by_one = 1'b0;
    end

    if(cnt == BRAM_WIDTH_IN_WORD)
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
        bram_index <= index_cntl;
        bram_en <= 1'b0;
        bram_wen <= 1'b0;
    end
    else
    begin
        case({rw, ptr_start, ptr_end, stream_in_valid, stream_out_accep})
            5'b11011, 5'b11010: begin
                bram_en <= 1'b1;
                bram_wen <= 1'b1;
                bram_index <= bram_index + 1;
            end
            5'b00101,5'b00111: begin
                bram_en <= 1'b1;
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

always@(posedge clk)
begin
    if(!rstn)
    begin
        stream_out_tlast <= 1'b0;
    end
    else 
    begin
        if(bram_index == size_cntl && ptr_end_by_one)
        begin
            stream_out_tlast <= 1'b1;
        end
        else
        begin
            stream_out_tlast <= 1'b0;
        end
    end
end

//stream in buf cntl
//for each mux, high bit: 0 keep, 1 change
//low bit: 0 bram, 1 axis
always@(*)
begin
    genver index;
    generate
    for(index = 0;index<BRAM_WIDTH_IN_WORD;index = index + 1)
    begin
        if(ptr_end)
        begin
            from_axis_mux_cntl[index*2+1:index*2] = 2'b10;
        end
        else if(index == cnt && rw && from_axis_valid)
        begin
            from_axis_mux_cntl[index*2+1:index*2] = 2'b11;
        end
        else
        begin
            from_axis_mux_cntl[index*2+1:index*2] = 2'b00;
        end
    end
    endgenerate
end


//stream out buf cntl
always@(*)
begin
    if(!rw)
    begin
        to_axis_mux_cntl = cnt;
    end
end

endmodule

