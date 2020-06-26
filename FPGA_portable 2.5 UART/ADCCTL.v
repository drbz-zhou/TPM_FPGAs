module ADCCTL(
reset          ,
clock      		,
//Internal pins
data_in			,
data_valid		,
//ADC pins
din				,
dout				,
sclk				,
cs					,
n_DRDY			,
START				,
n_RST				,
n_PWDN			,

debug_out		
);
//---------------Input Ports-----------------------------
input				reset;
input				clock;
input				din; //MISO
input				n_DRDY;

//---------------Output Ports----------------------------
output			dout; //MOSI
output			sclk;
output			cs;
output			n_RST;
output			n_PWDN;
output			START;
output			data_valid;
output	[31:0]	data_in;
output			debug_out;
//---------------Input ports Data Type-------------------
wire				reset;
wire				clock;
wire				din;
wire				n_DRDY;
wire	[31:0]	data_in;
//---------------Output Ports Data Type------------------
wire				dout;
wire				sclk;
wire				cs;
wire				data_valid;
reg				START;
reg				n_RST;
reg				n_PWDN;
wire				debug_out;
//-------------Internal Constants------------------------
parameter SIZE  		= 5           	;
parameter RESET 		= 5'b00000		; 
parameter CF_LOAD		= 5'b00001		;
parameter CF_SEND		= 5'b00010		;
parameter CF_WAIT		= 5'b00011		;
parameter IDLE 		= 5'b00100 		;
parameter SEND 		= 5'b00101 		;
parameter WAIT 		= 5'b00110 		;
parameter ConfigRegisters = 8'h02	;
//-------------Internal Variables------------------------
reg   [SIZE-1:0]        state        ;// Seq part of the FSM
reg   [SIZE-1:0]        next_state   ;// combo part of FSM
reg	[31:0]				data_out;
reg							spi_start;
wire							mlb;
wire	[1:0]					clock_div;
reg	[7:0]					count_rst;
reg	[7:0]					count_start;
reg	[7:0]					count_WAIT;
reg	[7:0]					count_config;
reg	[15:0]				count_cfload;
wire	[31:0]				config_commands[3];

assign config_commands[0] = 32'h70028300;
assign config_commands[1] = 32'h7300ffff;
assign config_commands[2] = 32'h7600fe01;

//-------------Internal Modules  ------------------------
//SPI control interface
spi spi1(
.reset          (reset),
.clock      	 (clock),

//internal interface
.data_transmit	 (data_out[31:0]),
.data_received	 (data_in[31:0]),
.start			 (spi_start), //START=1- starts data transmission
.mlb				 (mlb), //0: LSB 1st; 1: MSB 1st
.clock_div		 (clock_div[1:0]), //cdiv 0=clk/4 1=/8   2=/16  3=/32
.done				(data_valid),
//SPI interface
.din				(din),
.dout				(dout),
.sclk				(sclk),
.ss				(cs)
//.debug_out		(debug_out)
);
//--------------Internal Counters-----------------------
always @ (posedge clock)
begin : COUNTER_RST
	if ((state == RESET)) begin
		count_rst <= count_rst+1;
	end else begin
		count_rst <= 8'b00000000;
	end
end

always @ (posedge clock)
begin : COUNTER_START
	if (state == SEND || state ==CF_SEND) begin
		count_start <= count_start+1;
	end else begin
		count_start <= 8'b00000000;
	end
end

always @ (posedge clock)
begin : COUNTER_WAIT
	if ((state == WAIT) || (state == CF_WAIT)) begin
		count_WAIT <= count_WAIT+1;
	end else begin
		count_WAIT <= 8'b00000000;
	end
end

always @ (posedge clock)
begin : COUNTER_CFLOAD
	if ((state == CF_LOAD)) begin
		count_cfload <= count_cfload+1;
	end else begin
		count_cfload <= 16'h0000;
	end
end

always @ (posedge clock or posedge reset)
begin : COUNTER_CONFIG
	if (reset) begin
		count_config <= 8'b00000000;
	end else begin
		if ((state == CF_LOAD)&& (count_config < ConfigRegisters)) begin
			count_config <= count_config+1;
		end else begin
			count_config <= count_config;
		end
	end
end
//--------------assignments------------------------------
assign mlb = 1;
assign clock_div = 2'b00;
//assign debug_out = clock;

//-----------------Seq Logic-----------------------------
always @ (posedge clock)
begin : FSM_SEQ
	if (reset == 1'b1) begin
		state <=  RESET;
	end else begin
		state <=  next_state;
	end
end

//--------------Combinational Logic----------------------
always @ (state or count_rst or count_start or n_DRDY or count_WAIT or count_cfload or count_config) //negedge clock)//
begin : FSM_COMBO
	if (reset == 1'b1) begin
		next_state = RESET;
	end
	case(state)
		RESET :	begin
						if(count_rst == 3) begin
							next_state = CF_LOAD;
						end else begin
							next_state = RESET;
						end
					end
		CF_LOAD: begin
						if(count_cfload == 16'h0fff)begin
							next_state = CF_SEND;
						end else begin
							next_state = CF_LOAD;
						end
					end
		CF_SEND: begin
						if(count_start == 32) begin
							next_state = CF_WAIT;
						end else begin
							next_state = CF_SEND;
						end
					end
		CF_WAIT: begin
						if(count_WAIT == 32)begin
							if(count_config < ConfigRegisters)begin
								next_state = CF_LOAD;
							end else begin
								next_state = IDLE;
							end
						end else begin
							next_state = CF_WAIT;
						end
					end
		IDLE : 	begin
						if(n_DRDY == 0) begin
							next_state = SEND;
						end else begin
							next_state = IDLE;
						end
					end
		SEND : 	begin
						if(count_start == 32) begin
							next_state = WAIT;
						end else begin
							next_state = SEND;
						end
					end
		WAIT :  	begin
						if(count_WAIT == 32)begin
							next_state = IDLE;
						end else begin
							next_state = WAIT;
						end
					end
   default : next_state = WAIT;
  endcase
end
//----------Output Logic-----------------------------
always @ (posedge clock)
begin : OUTPUT_LOGIC
if (reset == 1'b1) begin
		START = 0;
		n_RST	= 0;
		n_PWDN =0;
		data_out = 32'h00000000;
		spi_start = 0;
	end
else begin
	case(state)
		RESET : 	begin
						START = 0;
						n_RST = 0;
						n_PWDN = 1;
						spi_start = 0;
					end
		CF_LOAD: begin
						START = 0;
						n_RST = 1;
						n_PWDN = 1;
						spi_start = 0;
						data_out = config_commands[count_config];//32'h77fe0100;
					end
		CF_SEND: begin
						spi_start = 1;
					end
		CF_WAIT: begin
						spi_start = 0;
					end
		IDLE : 	begin
						n_RST = 1;
						n_PWDN = 1;
						spi_start = 0;
						START = 1;
						data_out = 32'h00000000;//32'h77fe0100;
               end
		SEND : 	begin
						//START = 1;
						n_RST = 1;
						n_PWDN = 1;
						spi_start = 1;
					end
		WAIT:	begin
						//START = 1;
						n_RST = 1;
						n_PWDN = 1;
						spi_start = 0;
					end
	default : 	begin
						//START = 1;
						n_RST = 1;
						n_PWDN = 1;
					end
	endcase
end
end // End Of Block OUTPUT_LOGIC

//assign debug_out = data_valid;
endmodule
