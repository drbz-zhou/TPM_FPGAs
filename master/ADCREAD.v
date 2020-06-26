module ADCREAD (
reset          ,
SCO				,
SDO				, 
FSO				,
result_data		,
result_valid	,
ADCSTATUS1		, //(ready, read done, fail)
ADCSTATUS2		
//ADCSTATUS3
);
//-------------Input Ports-----------------------------
input				reset;
input 			FSO;
input 			SDO;
input 			SCO;
input				ADCSTATUS1;
//input				tx_empty_ctr;
 //-------------Output Ports----------------------------
output	[31:0]result_data;
output 			result_valid;
output			ADCSTATUS2;
//-------------Input ports Data Type-------------------
wire				reset;
wire 				FSO;
wire 				SDO;
wire 				SCO;
//reg				tx_empty_ctr;
//-------------Output Ports Data Type------------------
reg		[31:0]result_data;
reg 				result_valid;
reg				ADCSTATUS2;
reg				lastFSO;
//-------------Internal Constants--------------------------
parameter SIZE  	= 3           	;
parameter IDLE = 3'b001 		;
parameter READ_DONE 	= 3'b011			;
//-------------Internal Variables---------------------------
reg   [SIZE-1:0]          	state        	;// Seq part of the FSM
reg   [SIZE-1:0]          	next_state   	;// combo part of FSM
reg	[31:0]					result_buff;



//----------Code startes Here------------------------
always @ (state)
begin : FSM_COMBO
 case(state)
   
	IDLE : 	
					
					if (!lastFSO && FSO) begin
                next_state = READ_DONE;
					end else begin
                next_state = IDLE;
					end
   READ_DONE : 	
					
                next_state = IDLE;
		
	
   default : next_state = IDLE;
  endcase
end


always @ (negedge SCO)
begin : SAVEFSO
	if (reset == 1'b1) begin
		lastFSO <= 1;
		end else begin
		lastFSO <= FSO;
		end
end

always @ (negedge SCO)
begin : SHIFT
	if (reset == 1'b1) begin
		result_buff <= 32'h00000000;
		end else if (!FSO) begin
		result_buff[31:1] <= result_buff[30:0];
		result_buff[0]	<= SDO;
		end
end



//----------Seq Logic-----------------------------
always @ (negedge SCO)
begin : FSM_SEQ
  if (reset == 1'b1) begin
    state <=  IDLE;
  end else begin
    state <=  next_state;
  end
end
//----------Output Logic-----------------------------
always @ (posedge SCO)
begin : OUTPUT_LOGIC
if (reset == 1'b1) begin
					result_data = 32'b00000000000000000000000000000000;
					result_valid = 0;
					ADCSTATUS2 = 0;
               end
					else begin
  case(state)
   IDLE : begin
					result_valid = 0;
					ADCSTATUS2 = 0;
               end
   READ_DONE : begin

					result_data = result_buff;
					result_valid = 1;
					ADCSTATUS2 = 1;
					end
   default : begin
					result_data = 32'b00000000000000000000000000000000;
					result_valid = 0;
					ADCSTATUS2 = 0;
					end
	endcase
end
end
endmodule
	