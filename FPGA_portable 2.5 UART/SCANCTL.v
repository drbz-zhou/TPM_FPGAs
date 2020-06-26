module SCANCTL (
reset				,
clock				, //200MHz
config_done		,
deMUX_X			,
deMUX_Y			,
n_DRDY1			,
n_DRDY2			,
HEAD_UART		,
TAIL_UART			
);
//------------input ports------------
input				reset, clock;
input				config_done, n_DRDY1, n_DRDY2;
//------------output ports-----------
output 	reg[4:0]	deMUX_X;
output 	reg[4:0]	deMUX_Y;
output 	reg		HEAD_UART;
output 	reg		TAIL_UART;
//------------internal variables--------
reg		[4:0] counter_x;
reg		[4:0] counter_y;
reg				counter_head;
wire				FSO;
wire 				clock_x;
wire				clock_y;
reg				lastFSO;
wire				halt;
reg		[2:0] state;
reg		[2:0] next_state;
//------------internal constants--------
parameter DIMX		= 14;
parameter DIMY		= 31;

parameter IDLE		= 3'b000;
parameter HEAD		= 3'b001;
parameter COUNTX	= 3'b010;
parameter COUNTY 	= 3'b011;

assign FSO = !(n_DRDY1 & n_DRDY2);// & FSO2 & FSO3 & FSO4;

//------------code starts here--------------
always @ (state or counter_x or counter_y)
begin : FSM_COMBO
	case(state)
		IDLE:
				next_state = HEAD;
		HEAD :
					next_state = COUNTX;
		COUNTX:
				if(counter_x < DIMX)
					next_state = COUNTX;
				else if (counter_y == DIMY)
					next_state = HEAD;
				else
					next_state = COUNTY;
		COUNTY:
					next_state = COUNTX;
		default:
				next_state = IDLE;
	endcase
end

always @ (negedge FSO)
begin : FSM_SEQ
	if (reset)
		state <= IDLE;
	else
		state <= next_state;
end

always @ (negedge FSO)
begin : head
	if(state==HEAD)
		counter_head <= counter_head + 1;
	else
		counter_head <= 0;
end

always @ (negedge FSO)
begin : countx
	if(state==COUNTX)
		counter_x <= counter_x + 1;
	else
		counter_x <= 0;
end

always @ (negedge FSO)
begin : county
	if(state==COUNTY)
		counter_y <= counter_y + 1;
	else if (state==HEAD)
		counter_y <= 0;
	else
		counter_y <= counter_y;
end

//---------------output logic------------
always @ ( counter_x[4:0] or counter_y[4:0] ) //count_x or count_y or state)
begin : OUTPUT_LOGIC
	deMUX_X = counter_x;
	deMUX_Y = counter_y;
	/*case (state)
		IDLE: 	HEAD_UART = 1;
		HEAD:		HEAD_UART = 1;
		COUNTX:	
	//				if(counter_x == 0 && counter_y==0)
	//					HEAD_UART = 1;
	//				else
						HEAD_UART = 0;
		COUNTY:	HEAD_UART = 0;
		default:	HEAD_UART = 0;
	endcase*/
	if(counter_x == 5'b01111 && counter_y == 5'b11111)
		HEAD_UART = 1;
	else
		HEAD_UART = 0;
	
	if(counter_x == 5'b01110 && counter_y == 5'b11111)
		TAIL_UART = 1;
	else 
		TAIL_UART = 0;
	/*
	if (count_x == 28 && count_y == 0) begin //1 0  28 0
		HEAD_UART =  1;
		TAIL_UART =  0;
	end else if (count_x == 27 && count_y == 0) begin // 0 0 27 0
		HEAD_UART =  0;
		TAIL_UART =  1;
	end else begin
		HEAD_UART =  0;
		TAIL_UART =  0;
	end*/
			
end

endmodule
			