module SCANCTL (
reset				,
clock				, //200MHz
config_done		,
deMUX_X			,
deMUX_Y			,
FSO1				,
FSO2				,
FSO3				,
FSO4				,
HEAD_UART		,
TAIL_UART			
);
//------------input ports------------
input				reset, clock;
input				config_done, FSO1, FSO2, FSO3, FSO4;
//------------output ports-----------
output 	reg[4:0]	deMUX_X;
output 	reg[8:0]	deMUX_Y;
output 	reg		HEAD_UART;
output 	reg		TAIL_UART;
//------------internal variables--------
wire		[4:0] count_x;
wire		[8:0] count_y;
wire				FSO;
wire 				clock_x;
wire				clock_y;
reg				lastFSO;
wire				halt;

//------------internal constants--------
parameter XDIM		= 127;
parameter YDIM		= 31;

assign FSO = FSO4;// & FSO2 & FSO3 & FSO4;

//-------------submodules----------------
// x channels from 0 to 31
SCANCOUNT #(.BITS(4),
.DIM(30)
) cnt_x (
.reset 			(reset),
.clock_in 		(FSO),
.counter 		(count_x),
.clock_out		(clock_x),
.halt				(halt),
);
SCANCOUNT #(.BITS(8),
.DIM(126)
) cnt_y (
.reset 			(reset),
.clock_in 		(clock_x),
.counter 		(count_y),
.clock_out		(clock_y),
.halt				(),
);
SIGNEXPAND_DUO #(.MULTIFAC1(2),//2*(200000000/156250)-1
.MULTIFAC2(10),
.DIM(2)
) signex_ctl (
.reset			(reset),
.clock			(FSO),
.signal_in		(HEAD_UART),
.signal_out		(halt),
);
//------------Code Starts---------------

//---------------output logic------------
always @ ( count_x[4:0] or count_y[8:0] ) //count_x or count_y or state)
begin : OUTPUT_LOGIC
	deMUX_X = count_x;
	deMUX_Y = count_y;
	
	if (count_x == 28 && count_y == 0) begin //1 0  28 0
		HEAD_UART =  1;
		TAIL_UART =  0;
	end else if (count_x == 27 && count_y == 0) begin // 0 0 27 0
		HEAD_UART =  0;
		TAIL_UART =  1;
	end else begin
		HEAD_UART =  0;
		TAIL_UART =  0;
	end
			
end

endmodule
			