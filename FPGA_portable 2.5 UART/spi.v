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
input   					clock;
input						reset;

input 	[31:0]		data_transmit;
input 					start;
input						mlb;
input		[1:0]			clock_div;

input						din;
//---------------Output Ports----------------------------
output reg	[31:0]	data_received;
output reg				done;
output reg				dout;
output reg 				sclk;
output reg				ss;
output reg				debug_out;

//-------------Internal Constants------------------------
parameter SIZE  		= 5           	;
parameter IDLE 		= 5'b00001 		;
parameter CHIPS 		= 5'b00010 		;
parameter TRANS 		= 5'b00011 		;
parameter FINISH		= 5'b00100		;
parameter HALT			= 5'b00101		;
parameter mid			= 2				;
//-------------Internal Variables------------------------
reg   	[SIZE-1:0]        	state        ;// Seq part of the FSM
reg   	[SIZE-1:0]        	next_state   ;// combo part of FSM
reg		[7:0]						cnt;
reg 									shift;
reg 									clr;

reg		[7:0]						nbit;
reg 		[31:0]					rreg;
reg 		[31:0]					treg;
reg									sclk_intern;
reg		[7:0]						tx_cnt;
//--------------Code startes Here------------------------

//--------------internal counters------------------
//CLOCK GENERATOR BLOCK:
always@(negedge clock or posedge reset) begin
	if (reset==1)	begin 
		cnt=0; 
		sclk_intern=1; 
	end
	else begin
				cnt=cnt+1;
			if (cnt>=mid) begin
				sclk_intern=~sclk_intern;
				cnt=0;
			end //mid
	end //rst
end

always @ (sclk_intern or reset) begin
	if (reset) begin
		sclk = 0;
	end else if(state == TRANS)begin
		sclk <= sclk_intern;
	end else begin
		sclk <= 0;
	end
end

always @ (posedge sclk_intern )
begin : COUNTER_NBIT
	if ((state == TRANS)) begin
		nbit <= nbit+1;
	end else begin
		nbit <= 8'b00000000;
	end
end

//----------Seq Logic-----------------------------
always @ (negedge sclk_intern)
begin : FSM_SEQ
  if (reset == 1) begin
    state =  IDLE;
  end else begin
    state =  next_state;
  end
end
//--------------state transition logic-------------------
always @ (posedge sclk_intern)
begin : FSM_COMBO
	if (reset == 1) begin
		next_state = IDLE;
		clr = 0;
		shift = 0;
		ss = 1;
	end else begin
		case(state)
			IDLE : 		begin
								if (start==1) begin
										shift = 1;
										
										next_state = CHIPS;
									end
								else begin
									next_state =IDLE;
								end
								clr = 0;
								ss = 1;
								debug_out = 0;
								done = 0;
							end
			CHIPS :		begin
								next_state = TRANS;
								ss = 0;
								clr = 0;
								debug_out = 0;
							end
			TRANS	:		begin
								ss=0;
								clr = 0;
								debug_out = 1;
								if(nbit[7:0] < 31)begin
									shift = 1;
								end
								else begin
									
									next_state = FINISH;
								end
							end
			FINISH : 	begin
								shift = 0;
								ss = 0;
								
								data_received = rreg;
								next_state = HALT;	
								debug_out = 0;
							end
			HALT	 :		begin
								next_state = IDLE;
								done = 1;
								clr = 1;
								debug_out = 0;
							end
			default : next_state = FINISH;
		endcase
	end
end
//----------TX block Logic------------------------

always @ (negedge sclk_intern or posedge reset) begin : TX
	if (reset) begin
		treg = 32'h00000000;
		dout = 1;
		tx_cnt = 0;
	end else begin
		if(next_state == IDLE)begin
			treg = 32'h77010100;
			dout = 1;
			tx_cnt = 0;
		end else if (next_state == CHIPS) begin
			treg = data_transmit;//32'h49000000;
			dout = 1;
			tx_cnt = 0;
		end else if (next_state == TRANS) begin
			dout = treg[31-tx_cnt];
			tx_cnt = tx_cnt + 1;
		end else begin
			dout = 1;
			tx_cnt = 0;
		end
	end
end

/*always@(negedge sclk_intern or posedge clr) begin
	if(clr==1) begin
		treg = 32'h77010100;  
		dout=1; 
	end 
	else begin
		if(state == IDLE) begin
		end
		if(state == TRANS) begin
			if(nbit==0) begin //load data into TREG
				treg = 32'h77010100; 
				dout = 0;// mlb ? treg[31] : treg[0];
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
end*/
//----------RX block Logic------------------------
always@(posedge sclk or posedge clr) begin // or negedge rstb
	if(clr==1) begin
		//nbit = 0;  
		rreg = 32'hFFFFFFFF;  
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


//assign debug_out = start;
endmodule // End of Module arbiter
