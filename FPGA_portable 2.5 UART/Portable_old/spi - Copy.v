module spi (
reset          ,
clock      		,

//internal interface
data_transmit	,
data_received	,
done			,	//done = 1 data received is valid and updated
start			, //START=1- starts data transmission, at least 2 clk cycles
mlb				, //0: LSB 1st; 1: MSB 1st
clock_div		, //cdiv 0=clk/4 1=/8   2=/16  3=/32

//SPI interface
din				,
dout				,
sclk				,
ss					,
debug_out		
);
//---------------Input Ports-----------------------------
input   				clock;
input					reset;

input 	[31:0]	data_transmit;
input 				start;
input					mlb;
input		[1:0]		clock_div;

input					din;
//---------------Output Ports----------------------------
output 	[31:0]	data_received;
output				done;
output				dout;
output 				sclk;
output				ss;
output				debug_out;
//---------------Input ports Data Type-------------------
wire   				clock;
wire					reset;
wire 		[31:0]	data_transmit;
wire 					start;
wire					mlb;
wire		[1:0]		clock_div;
wire					din;
//---------------Output Ports Data Type------------------
reg 		[31:0]	data_received;
reg 						done;
reg					dout;
reg 					sclk;
reg					ss;
wire					debug_out;
//-------------Internal Constants------------------------
parameter SIZE  	= 5           	;
parameter IDLE 		= 5'b00001 		;
parameter SEND 		= 5'b00010 		;
parameter FINISH 		= 5'b00011 		;
parameter WAIT			= 5'b00100		;
//-------------Internal Variables------------------------
reg   	[SIZE-1:0]        	state        ;// Seq part of the FSM
reg   	[SIZE-1:0]        	next_state   ;// combo part of FSM
reg		[7:0]				mid;
reg		[7:0]				cnt;
reg 						shift;
reg 						clr;

reg		[7:0]				nbit;
reg 	[31:0]				rreg;
reg 	[31:0]				treg;
reg						sclk_intern;
//--------------Code startes Here------------------------

//--------------internal counters------------------
//CLOCK GENERATOR BLOCK:
always@(negedge clock or posedge reset) begin
	if (reset==1)	begin 
		cnt=0; 
		sclk_intern=1; 
	end
	else begin
		//if (shift==1) begin
				cnt=cnt+1;
			if (cnt>=mid) begin
				sclk_intern=~sclk_intern;
				cnt=0;
			end //mid
		//end //shift
	end //rst
end

always @ (sclk_intern) begin
	if(state!=SEND)begin
		sclk = 0;
	end else begin
		sclk = sclk_intern;
	end
end

always @ (posedge sclk_intern )
begin : COUNTER_NBIT
	if ((state == SEND)) begin
		nbit <= nbit+1;
	end else begin
		nbit <= 8'b00000000;
	end
end


//initial begin
// next_state = 3'b000;
//end
//----------Seq Logic-----------------------------
always @ (negedge clock)
begin : FSM_SEQ
  if (reset == 1'b1) begin
    state =  IDLE;
  end else begin
    state =  next_state;
  end
end
//--------------state transition logic-------------------
always @ (state or start or nbit)
begin : FSM_COMBO
	if (reset == 1) begin
		next_state = state;
		clr = 0;
		shift = 0;
		ss = 1;
	end else begin
		case(state)
			IDLE : 		begin
								if (start==1) begin
										case(clock_div)
											2'b00: mid=2;
											2'b01: mid=4;
											2'b10: mid=8;
											2'b11: mid=16;
										endcase
										shift = 1;
										done = 0;
										next_state = SEND;
									end
								else begin
									next_state =IDLE;
								end
								clr = 0;
								ss = 1;
							end
			SEND	:		begin
								ss=0;
								clr = 0;
								if(nbit[7:0] < 32)begin
									shift = 1;
								end
								else begin
									data_received = rreg;
									next_state = FINISH;
								end
							end
			FINISH : 	begin
								shift = 0;
								ss = 0;
								clr = 1;
								next_state = WAIT;
								
							end
			WAIT	 :		begin
								next_state = IDLE;
								done = 1;
							end
			default : next_state = FINISH;
		endcase
	end
end
//----------TX block Logic------------------------
always@(negedge sclk_intern or posedge clr) begin
	if(clr==1) begin
		treg=32'hFFFFFFFF;  
		dout=1; 
	end 
	else begin
		if(state == SEND) begin
			if(nbit==0) begin //load data into TREG
				treg = data_transmit; 
				dout = mlb ? treg[31] : treg[0];
			end //nbit_if
			else begin
				if(mlb==0) begin//LSB first, shift right
					treg = {1'b1, treg[31:1]}; 
					dout = treg[0]; 
				end
				else begin//MSB first shift LEFT
					treg = {treg[30:0], 1'b1}; 
					dout = treg[31]; 
				end
			end
		end else begin
			dout = 1;
		end
		
	end //rst
end
//----------RX block Logic------------------------
always@(posedge sclk or posedge clr) begin // or negedge rstb
	if(clr==1) begin
		//nbit = 0;  
		rreg = 8'hFF;  
	end else begin
		if(mlb==0) begin//LSB first, din@msb -> right shift
			rreg = {din, rreg[31:1]};  
		end
		else begin //MSB first, din@lsb -> left shift
			rreg = {rreg[30:0], din};  
		end
		//nbit = nbit + 1;
	end //rst
end


assign debug_out = state[0];
endmodule // End of Module arbiter
