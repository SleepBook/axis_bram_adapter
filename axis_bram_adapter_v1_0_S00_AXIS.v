//Customed AXIS Slave Interface
//
//futher abstract the axis-s interface to user
//interface to user:
//   DOUT_VALID, DOUT_DATA
//
//User to Interface:
//   DOUT_ACCEP
//
//the cycle user negate accep, the next cycle the valid signal is
//unset as well
`timescale 1 ns / 1 ps
	module axis_bram_adapter_v1_0_S00_AXIS #
	(
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32
	)
	(
		input wire  S_AXIS_ACLK,
		input wire  S_AXIS_ARESETN,
		output wire  S_AXIS_TREADY,
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
		// Byte qualifier
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
		input wire  S_AXIS_TLAST,
		input wire  S_AXIS_TVALID,

        //customer IO
        output wire [C_S_AXIS_TDATA_WIDTH-1: 0] DOUT_TO_BUF,
        output wire DOUT_VALID,
        input wire DOUT_ACCEP
	);
	// Define the states of state machine
	// The control state machine oversees the writing of input streaming data to the FIFO,
	// and outputs the streaming data from the FIFO
	parameter [1:0] IDLE = 1'b0,        // This is the initial/idle state 

	                WRITE_FIFO  = 1'b1; // In this state FIFO is written with the
	                                    // input stream data S_AXIS_TDATA 
	wire axis_tready;
	// State variable
	reg mst_exec_state;  

	//reg write_done;

    reg [C_S_AXIS_TDATA_WIDTH-1: 0] dout;
    wire w_en;
    reg w_en_delay;

    assign DOUT_TO_BUF = dout;
    assign DOUT_VALID = w_en_delay;
    
	assign S_AXIS_TREADY = axis_tready;

	// Control state machine implementation
	always@(posedge S_AXIS_ACLK) 
	begin  
	  if (!S_AXIS_ARESETN) 
	    begin
	      mst_exec_state <= IDLE;
	    end  
	  else
	    case (mst_exec_state)
	      IDLE: 
	        // The sink starts accepting tdata when 
	        // there tvalid is asserted to mark the
	        // presence of valid streaming data 
	          if (S_AXIS_TVALID)
	            begin
	              mst_exec_state <= WRITE_FIFO;
	            end
	          else
	            begin
	              mst_exec_state <= IDLE;
	            end
	      WRITE_FIFO: 
	        // When the sink has accepted all the streaming input data,
	        // the interface swiches functionality to a streaming master
	        if (w_en && S_AXIS_TLAST)
	          begin
	            mst_exec_state <= IDLE;
	          end
	        else
	          begin
	            // The sink accepts and stores tdata 
	            // into FIFO
	            mst_exec_state <= WRITE_FIFO;
	          end

	    endcase
	end

	// AXI Streaming Sink 
	assign axis_tready = ((mst_exec_state == WRITE_FIFO) && DOUT_ACCEP);
	assign w_en = S_AXIS_TVALID && axis_tready;

    always@(posedge S_AXIS_ACLK)
    begin
        w_en_delay <= w_en;
    end

	always@(posedge S_AXIS_ACLK)
	begin
	  if(!S_AXIS_ARESETN)
	    begin
	      //write_done <= 1'b0;
          dout <= 0;
	    end  
	  else
        begin
           // case(w_en)
           //     1'b0:begin
           //         dout <= 0;
           //         write_done <= 1'b0;
           //     end
           //     1'b1:begin
           //         dout <= S_AXIS_TDATA;
           //         write_done <= 1'b0;
           //     end
           // endcase
            case({w_en, S_AXIS_TLAST})
                2'b10:begin
                    dout <= S_AXIS_TDATA;
                   // write_done <= 1'b0;
                end
                2'b11:begin
                    dout <= S_AXIS_TDATA;
                    //write_done <= 1'b1;
                end
                default:begin
                    dout <= 0;
                    //write_done <= 1'b0;
                end
            endcase
        end
    end

endmodule
