module UARTCTL (
reset          ,
clock      		,

//internal interface
data_transmit	,
data_received	,
start				, //START=1- starts data transmission
mlb				, //0: LSB 1st; 1: MSB 1st
clock_div		, //cdiv 0=clk/4 1=/8   2=/16  3=/32

//SPI interface
din				,
dout				,
sclk				,
ss					
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

output				dout;
output 				sclk;
output				ss;
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

wire					dout;
wire 					sclk;
wire					ss;
//-------------Internal Constants------------------------
parameter SIZE  	= 5           	;
parameter IDLE = 5'b00001 		;
parameter SEND 	= 5'b00010 		;
parameter FINISH 	= 5'b00011 		;
//-------------Internal Variables------------------------
reg   [SIZE-1:0]        state        ;// Seq part of the FSM
reg   [SIZE-1:0]        next_state   ;// combo part of FSM
reg	[7:0]					mid;
reg	[7:0]					cnt;
reg 							shift;
reg 							clr;
reg 							done;
reg	[7:0]					nbit;
reg 	[31:0]				rreg;
//--------------Code startes Here------------------------

//--------------state transition logic-------------------
always @ (state or start or nbit)
begin : FSM_COMBO
	if (reset == 1) begin
		next_state = state;
		clr = 0;
		shift = 0;
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
							end
			SEND	:		begin
								ss=0;
								if(nbit != 32)begin
									shift = 1;
								end
								else begin
									data_received = rreg;
									done = 1;
									next_state = FINISH;
								end
							end
			FINISH : 	begin
								shift = 0;
								ss = 1;
								clr = 1;
								next_state = IDLE;
							end
			default : next_state = FINISH;
		endcase
	end
end
//--------------internal counters------------------
//CLOCK GENERATOR BLOCK:
always@(negedge clock or posedge clr) begin
	if (clr==1)	begin 
		cnt=0; 
		sclk=1; 
	end
	else begin
		if (shift==1) begin
				cnt=cnt+1;
			if (cnt==mid) begin
				sclk=~sck;
				cnt=0;
			end //mid
		end //shift
	end //rst
end

//initial begin
// next_state = 3'b000;
//end
//----------Seq Logic-----------------------------
always @ (negedge clock)
begin : FSM_SEQ
  if (reset == 1'b1) begin
    state <=  INITIAL;
  end else begin
    state <=  next_state;
  end
end
//----------TX block Logic------------------------
always@(negedge sclk or posedge clr) begin
 if(clr==1) begin
            treg=8’hFF;  dout=1; 
  end 
 else begin
                   if(nbit==0) begin //load data into TREG
                             treg=tdat; dout=mlb?treg[7]:treg[0];
                   end //nbit_if
                   else begin
                             if(mlb==0) //LSB first, shift right
                                      begin treg={1’b1,treg[7:1]}; dout=treg[0]; end
                             else//MSB first shift LEFT
                                      begin treg={treg[6:0],1’b1}; dout=treg[7]; end
                   end
 end //rst
end
//----------RX block Logic------------------------
always@(posedge sclk or posedge clr ) begin // or negedge rstb
 if(clr==1)  begin
                             nbit=0;  rreg=8’hFF;  end
    else begin
                     if(mlb==0) //LSB first, din@msb -> right shift
                             begin  rreg={din,rreg[7:1]};  end
                     else  //MSB first, din@lsb -> left shift
                             begin  rreg={rreg[6:0],din};  end
                     nbit=nbit+1;
 end //rst
end

endmodule // End of Module arbiter
