module UARTCTL (
reset          ,
clock      		,
ld_tx_data_ctr , // Request 0
tx_data_ctr		, // Request 1
tx_enable_ctr	,
ADCDATA
);
//-------------Input Ports-----------------------------
input   			clock;
input				reset;
input 	[31:0]ADCDATA;
//input				tx_empty_ctr;
 //-------------Output Ports----------------------------
output  			ld_tx_data_ctr;
output	[7:0] tx_data_ctr;
output			tx_enable_ctr;
//-------------Input ports Data Type-------------------
wire   			clock;
wire				reset;
wire		[31:0]ADCDATA;
//reg				tx_empty_ctr;
//-------------Output Ports Data Type------------------
reg  				ld_tx_data_ctr;
reg		[7:0] tx_data_ctr;
reg				tx_enable_ctr;
//-------------Internal Constants--------------------------
parameter SIZE  	= 3           	;
parameter INITIAL = 3'b001 		;
parameter LOAD		= 3'b010			;
parameter LD_TX	= 3'b011			;
parameter ENABLE 	= 3'b100			;
parameter DONE		= 3'b101			;
//-------------Internal Variables---------------------------
reg   [SIZE-1:0]          state        ;// Seq part of the FSM
reg   [SIZE-1:0]          next_state   ;// combo part of FSM
reg   [3:0]					  count_1	  	;
reg	[31:0]				  ADCDATABUFF	;
//----------Code startes Here------------------------
always @ (state or count_1)
begin : FSM_COMBO
 case(state)
   INITIAL : 	
                next_state = LOAD;
   LOAD : 
                next_state = LD_TX;
	LD_TX :
					next_state = ENABLE;
					 
   ENABLE : 	if (count_1 < 9) begin
                next_state = ENABLE;
              end else begin
                next_state = DONE;
              end
	DONE : next_state = LOAD;
   default : next_state = INITIAL;
  endcase
end

always @ (posedge clock)
begin : COUNTER_1
	if (state == ENABLE) begin
		count_1 <= count_1+1;
		end else begin
		count_1 <= 4'b0000;
		end
end

//initial begin
// next_state = 3'b000;
//end

//----------Seq Logic-----------------------------
always @ (posedge clock)
begin : FSM_SEQ
  if (reset == 1'b1) begin
    state <=  INITIAL;
  end else begin
    state <=  next_state;
  end
end
//----------Output Logic-----------------------------
always @ (posedge clock)
begin : OUTPUT_LOGIC
if (reset == 1'b1) begin
					ld_tx_data_ctr = 0;
					tx_data_ctr = 8'b00000000;
					tx_enable_ctr = 0;
               end
					else begin
  case(state)
   INITIAL : begin
            	ld_tx_data_ctr = 0;
					tx_data_ctr = 8'b00000000;
					tx_enable_ctr = 0;
               end
   LOAD : begin
            	ld_tx_data_ctr = 0;
					tx_data_ctr = 8'b00101100;
					tx_enable_ctr = 0;
               end   
   LD_TX : begin
            	ld_tx_data_ctr = 1;
					tx_data_ctr = 8'b00101100;
					tx_enable_ctr = 0;
               end
	ENABLE : begin
            	ld_tx_data_ctr = 0;
					tx_data_ctr = 8'b00101100;
					tx_enable_ctr = 1;
               end
	DONE : begin
            	ld_tx_data_ctr = 0;
					tx_data_ctr = 8'b00101100;
					tx_enable_ctr = 0;
               end
   default : begin
            	ld_tx_data_ctr = 0;
					tx_data_ctr = 8'b00000000;
					tx_enable_ctr = 0;
               end
  endcase
end
end // End Of Block OUTPUT_LOGIC

endmodule // End of Module arbiter

