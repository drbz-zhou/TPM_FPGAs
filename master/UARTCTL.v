module UARTCTL (
reset          ,
clock      		,
ld_tx_data_ctr , // Request 0
tx_data_ctr		, // Request 1
tx_enable_ctr	,
ADCDATA			,
send_done		,
SYNC_UART		,
HEAD_UART		,
TAIL_UART		,
debug_deMUX_X	,
debug_deMUX_Y	
);
//-------------Input Ports-----------------------------
input   			clock;
input				reset;
input 	[31:0]ADCDATA;
input				SYNC_UART;
input				HEAD_UART;
input				TAIL_UART;
input		[4:0] debug_deMUX_X;
input		[8:0]	debug_deMUX_Y;
//input				tx_empty_ctr;
 //-------------Output Ports----------------------------
output  			ld_tx_data_ctr;
output	[7:0] tx_data_ctr;
output			tx_enable_ctr;
output			send_done;
//-------------Input ports Data Type-------------------
wire   			clock;
wire				reset;
wire		[31:0]ADCDATA;
//reg				tx_empty_ctr;
//-------------Output Ports Data Type------------------
reg  				ld_tx_data_ctr;
reg		[7:0] tx_data_ctr;
reg				tx_enable_ctr;
reg 				send_done;
//-------------Internal Constants--------------------------
parameter SIZE  	= 5           	;
parameter INITIAL = 5'b00001 		;
parameter READ		= 5'b00010			;
parameter LOAD		= 5'b00011			;
parameter LD_TX	= 5'b00100			;
parameter ENABLE 	= 5'b00101			;
parameter DONE		= 5'b00110			;

//-------------Internal Variables---------------------------
reg   [SIZE-1:0]          state        ;// Seq part of the FSM
reg   [SIZE-1:0]          next_state   ;// combo part of FSM
reg   [3:0]					  count_1	  	;
reg   [7:0]					  count_2		;
reg	[31:0]				  ADCDATABUFF		;
reg   [4:0]					  nZeros;
reg	[23:0]					count_3;
//----------Code startes Here------------------------
always @ (state or count_1 or HEAD_UART)
begin : FSM_COMBO
 case(state)
   INITIAL : 	
					if (SYNC_UART) begin
							next_state = READ;
						end
					else begin
						next_state =INITIAL;
					end
	READ	:		
						next_state = LOAD;

   LOAD : 
                next_state = LD_TX;
	LD_TX :	
					next_state = ENABLE;
					 
   ENABLE : 	if (count_1 < 8) begin //9 note: 8 works
                next_state = ENABLE;
              end else begin
                next_state = DONE;
              end
	DONE : 	  begin
						if(count_2 < 2) begin
							next_state = LOAD;
						end else begin
							next_state = INITIAL;
						end
              end
   default : next_state = INITIAL;
  endcase
end

always @ (posedge clock)
begin : COUNTER_1
	if ((state == ENABLE)) begin
		count_1 <= count_1+1;
		end else begin
		count_1 <= 4'b0000;
		end
end

always @ (posedge clock)
begin : COUNTER_2
	if ((state == DONE )) begin
		count_2 <= count_2+1;
		end else if ((state==READ) || (state==INITIAL)) begin
		count_2 <= 4'b0000;
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
					send_done = 0;
					count_3=0;
               end
					else 
begin
  case(state)
   INITIAL : begin
            	ld_tx_data_ctr = 0;
					tx_data_ctr = 8'b00000000;
					tx_enable_ctr = 0;
					nZeros[2:0]=3'b000;
               end
	READ :	 begin
					ld_tx_data_ctr = 0;
					tx_data_ctr = 8'b00000000;
					tx_enable_ctr = 0;
					ADCDATABUFF = ADCDATA;
				 end
   LOAD : 	begin
            	ld_tx_data_ctr = 0;
					tx_enable_ctr = 0;
					if (HEAD_UART==0)begin
						if (count_2==0) begin 
							if(ADCDATABUFF[31:8]==24'b000000000000000000000000)	
								tx_data_ctr = 8'b11111111;
							else
								tx_data_ctr = ADCDATABUFF[31:24];
								//tx_data_ctr[7:5] = 3'b000;
								//tx_data_ctr[4:0] = debug_deMUX_X[4:0];
						end else if (count_2==1) begin 
							if(ADCDATABUFF[31:8]==24'b000000000000000000000000)	
								tx_data_ctr = 8'b11111111;
							else
								tx_data_ctr = ADCDATABUFF[23:16];
								//tx_data_ctr = debug_deMUX_Y[7:0];
						end else if (count_2==2) begin
							if(ADCDATABUFF[31:8]==24'b000000000000000000000000)	
								tx_data_ctr = 8'b11111111;
							else if (ADCDATABUFF[27:8] == 20'b00000000000000000000)
								tx_data_ctr = 8'b00000001;
							else
								tx_data_ctr = ADCDATABUFF[15:8];
								//tx_data_ctr = 8'b10000001;
						end else begin
							tx_data_ctr = 8'b00000000;
						end
					end else begin
						tx_data_ctr = 8'b00000000;
					end
            end   
   LD_TX : begin
            	ld_tx_data_ctr = 1;
					tx_enable_ctr = 0; //0
           end
	ENABLE : begin
            	ld_tx_data_ctr = 0;
					tx_data_ctr = 8'b00000000;
					tx_enable_ctr = 1;
            end
	DONE : begin
            	ld_tx_data_ctr = 0;
					tx_data_ctr = 8'b00000000;
					tx_enable_ctr = 1;
					send_done =1;
          end
   default : begin
            	ld_tx_data_ctr = 0;
					tx_data_ctr = 8'b00000000;
					tx_enable_ctr = 0;
					send_done = 0; // to scan control 
               end
  endcase
end
end // End Of Block OUTPUT_LOGIC

endmodule // End of Module arbiter

