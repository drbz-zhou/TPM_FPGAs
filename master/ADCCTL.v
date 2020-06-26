module ADCCTL (
reset          ,
clock      		,
ADCSTATUS1		,
ADCRESET			
		
);
//-------------Input Ports-----------------------------
input   			clock;
input				reset;
//input				tx_empty_ctr;
 //-------------Output Ports----------------------------
output 			ADCSTATUS1;
output 			ADCRESET;

//-------------Input ports Data Type-------------------
wire   			clock;
wire				reset;
//reg				tx_empty_ctr;
//-------------Output Ports Data Type------------------
reg 				ADCRESET;
reg 				ADCSTATUS1;

//-------------Internal Constants--------------------------
parameter SIZE  	= 3           	;
parameter RESET 	= 3'b001 		;
parameter WAIT		= 3'b010			;
parameter READY	= 3'b011			;
//-------------Internal Variables---------------------------
reg   [SIZE-1:0]          	state        	;// Seq part of the FSM
reg   [SIZE-1:0]          	next_state   	;// combo part of FSM
reg   [3:0]					  	count_1	  		;
reg	[3:0]						count_2			;
//reg	[15:0]						count_3			;
//----------Code startes Here------------------------


always @ (state or count_1 or count_2 )
begin : FSM_COMBO
 case(state)
   RESET : 	
					if (count_1 < 5) begin
                next_state = RESET;
					end else begin
					 next_state = WAIT;
					end
   WAIT : 
               if (count_2 < 2) begin
                next_state = WAIT;
					end else begin
					 next_state = READY;
					end
 READY : 		//if (count_3 < 8'b0111111111111111) begin
                next_state = READY;
					/*end else begin*
					 next_state = RESET;
					end*/
	default : next_state = RESET;
  endcase
end

always @ (posedge clock)
begin : COUNTER_1
	if (state == RESET) begin
		count_1 <= count_1+1;
		end else begin
		count_1 <= 4'b0000;
		end
end


always @ (posedge clock)
begin : COUNTER_2
	if (state == WAIT) begin
		count_2 <= count_2+1;
		end else begin
		count_2 <= 4'b0000;
		end
end

//always @ (posedge clock)
//begin : COUNTER_3
//	if (state == READY) begin
//		count_3 <= count_3+1;
//		end else begin
//		count_3 <= 16'b0000000000000000;
//		end
//end


//initial begin
// next_state = 3'b000;
//end

//----------Seq Logic-----------------------------
always @ (posedge clock)
begin : FSM_SEQ
  if (reset == 1'b1) begin
    state <=  RESET;
  end else begin
    state <=  next_state;
  end
end
//----------Output Logic-----------------------------
always @ (posedge clock)
begin : OUTPUT_LOGIC
if (reset == 1'b1) begin
					ADCRESET = 0;
					ADCSTATUS1 = 0;
               end
					else begin
  case(state)
   RESET : begin
					ADCRESET = 0;
					ADCSTATUS1 = 0;
               end
   WAIT : begin
					ADCRESET = 1;
					ADCSTATUS1 = 0;
					end
   READY : begin
					ADCRESET = 1;
					ADCSTATUS1 = 1;
					end
   default : begin
					ADCRESET = 1;
					ADCSTATUS1 = 0;
				end
	endcase
end
end
endmodule
	