module SIGNEXPAND_DUO (
reset				,
clock				,
signal_in		,
signal_out		
);
parameter 	MULTIFAC1	= 20;
parameter 	MULTIFAC2	= 20;
parameter	DIM	=  6;
input 		reset, clock, signal_in;
output 		signal_out;
reg			signal_out;

reg	[DIM:0]	counter_1;
reg	[DIM:0]	counter_2;
parameter IDLE = 2'b00;
parameter HOLD	= 2'b01;
parameter LOW = 2'b10;

//----------------- internal variables-----------
reg			state;
reg			next_state;
//----------------- code starts here ------------
always @ (state or counter_1 or counter_2)
begin: FSM_COMBO
	case (state)
		IDLE: if	(signal_in) begin
					next_state = HOLD;
				end
		HOLD:	if (counter_1 < MULTIFAC1) begin
					next_state = HOLD;
				end else begin
					next_state = LOW;
				end
		LOW:	if (counter_2 < MULTIFAC2) begin
					next_state = LOW;
					end else begin
					next_state = IDLE;
				end
		default: next_state = IDLE;
	endcase
end

always @ (posedge clock)
begin : TIMER_1
	if (state == HOLD) begin
		counter_1 <= counter_1 + 1;
	end else begin
		counter_1 <= 0;
	end
end

always @ (posedge clock)
begin : TIMER_2
	if (state == LOW) begin
		counter_2 <= counter_2 + 1;
	end else begin
		counter_2 <= 0;
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
			LOW: begin
					signal_out = 0;
					end
		default:	begin
					signal_out = 0;
					end
		endcase
	end
end
endmodule
