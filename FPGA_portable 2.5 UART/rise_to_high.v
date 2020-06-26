module rise_to_high(
/*  input   */
clk_core,
clk_target,
reset,
trigger_in,
/*  output  */
trigger_out,
debug_out,
);
/*----------Input Ports --------------*/
input		clk_core, clk_target, reset;
input 		trigger_in;
/*----------Output Ports--------------*/
output		trigger_out;
output		debug_out;
/*----------Input Ports Type----------*/
wire		clk_core, clk_target, reset;
wire 		trigger_in;
wire		debug_out;
/*----------Output Ports Type---------*/
reg			trigger_out;
/*----------Internal Constant---------*/
parameter	SIZE 		= 8;
parameter	COUNTERHIGH	= 4'h03;
parameter	IDLE		= 8'h00;
parameter	LOW			= 8'h01;
parameter	HIGH		= 8'h02;
/*----------Internal Variable---------*/
reg		[SIZE-1:0]		state;
reg		[SIZE-1:0]		next_state;
reg		[3:0]			count_clk;
reg						idle_pulse;
/*----------Internal Counters---------*/
always @ (posedge clk_target )//or posedge idle_pulse)
begin : COUNTER
	if (state == HIGH) begin
		count_clk <= count_clk+1;
	end else begin
		count_clk <= 4'h0;
	end
end
/*----------Assignments---------------*/
/*----------Initials------------------*/

/*----------Sequential Logic----------*/
always @ (posedge clk_core)
begin : FSM_SEQ
	if (reset == 1'b1) begin
		state <=  IDLE;
	end else begin
		state <=  next_state;
	end
end
/*----------Combinational Logic-------*/
always @ (negedge clk_core)
begin : FSM_COMBO
	if (reset == 1'b1) begin
		next_state = IDLE;
	end else begin
		case(state)
			IDLE :	begin
						if(trigger_in == 0)begin
							next_state = LOW;
						end else begin
							next_state = IDLE;
						end
					end
			LOW : 	begin
						if(trigger_in == 1)begin
							next_state = HIGH;
						end else begin
							next_state = LOW;
						end
					end
			HIGH :	begin
						if(count_clk == COUNTERHIGH)begin
							next_state = IDLE;
						end else begin
							next_state = HIGH;
						end
					end
		endcase
	end
end
/*----------Output Logic--------------*/
always	@ (state)
begin : OUTPUT_LOGIC
	if (reset == 1'b1) begin
		trigger_out = 0;
		idle_pulse  = 0;
	end else begin
		case(state)
			IDLE :	begin
						trigger_out = 0;
						idle_pulse  = 1;
					end
			LOW :	begin
						trigger_out = 0;
						idle_pulse  = 0;
					end
			HIGH :	begin
						trigger_out = 1;
						idle_pulse  = 0;
					end
		endcase
	end
end

assign debug_out = trigger_in;
endmodule