module SIGNEXPAND (
reset				,
clock				,
signal_in		,
signal_out		
);
parameter 	MULTIFAC	= 20;
parameter	DIM	=  6;
input 		reset, clock, signal_in;
output 		signal_out;
reg			signal_out;

reg	[DIM:0]	counter;
parameter IDLE = 1'b0;
parameter HOLD	= 1'b1;

//----------------- internal variables-----------
reg			state;
reg			next_state;
//----------------- code starts here ------------
always @ (state or counter)
begin: FSM_COMBO
	case (state)
		IDLE: if	(signal_in) begin
					next_state = HOLD;
				end
		HOLD:	if (counter < MULTIFAC) begin
					next_state = HOLD;
				end else begin
					next_state = IDLE;
				end
		default: next_state = IDLE;
	endcase
end

always @ (posedge clock)
begin : TIMER
	if (state == HOLD) begin
		counter <= counter + 1;
	end else begin
		counter <= 0;
	end
end

always @ (posedge clock)
begin : FSM_SEQ
	if (reset == 1) begin
		state <= IDLE;
	end else begin
		state <= next_state;
	end
end
//----------------output logic-------------------
always @ (posedge clock)
begin : OUTPUT_LOGIC
if (reset == 1)
	begin
		signal_out = 0;
	end
else 
	begin
		case(state)
			IDLE: begin
					signal_out = 0;
					end
			HOLD: begin
					signal_out = 1;
					end
		default:	begin
					signal_out = 0;
					end
		endcase
	end
end
endmodule
