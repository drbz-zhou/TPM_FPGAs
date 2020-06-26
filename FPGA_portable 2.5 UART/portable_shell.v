/*
		the shell module includes the clocks, LEDs 
		and the functional top level module
		it is arranged so for simulation easiness
*/

module portable_shell (
/*  input  */
//CLOCKS
clock_in,
clcck_adc,
FTDCLK,     //clock for paralle fifo
//COM
rx1,
//TXE,
//ADC1
adc1_din,
adc1_ndrdy,
//ADC2
adc2_din,
adc2_ndrdy,
/*  output  */
//LEDs
out_1,
out_2,
out_3,
out_4,
out_5,
//COM
tx1,
LED_1,

//ADC1
adc1_dout,
adc1_sclk,
adc1_n_cs,
adc1_start,
adc1_reset,
adc1_pwdn,
//ADC2
adc2_dout,
adc2_sclk,
adc2_n_cs,
adc2_start,
adc2_reset,
adc2_pwdn,
//demUX
deMUX_Y,
);
/*----------Input Ports --------------*/
input clock_in, clcck_adc, FTDCLK;
input rx1;
input adc1_din, adc1_ndrdy;
input adc2_din, adc2_ndrdy;
/*----------Output Ports--------------*/
output out_1, out_2, out_3, out_4, out_5;
output tx1;
output LED_1;  //new WR, SIWU
output adc1_dout, adc1_sclk, adc1_n_cs, adc1_start, adc1_reset, adc1_pwdn;
output adc2_dout, adc2_sclk, adc2_n_cs, adc2_start, adc2_reset, adc2_pwdn;
output wire[31:0]	deMUX_Y;
/*----------Input Ports Type----------*/
wire clock_in, FTDCLK;
wire rx1;
wire adc1_din, adc1_ndrdy;
wire adc2_din, adc2_ndrdy;
/*----------Output Ports Type---------*/
wire out_1, out_2, out_3, out_4, out_5;
wire tx1;
wire LED_1, LED_2;  //new WR, SIWU
wire adc1_dout, adc1_sclk, adc1_n_cs, adc1_start, adc1_reset, adc1_pwdn;
wire adc2_dout, adc2_sclk, adc2_n_cs, adc2_start, adc2_reset, adc2_pwdn;
/*----------Internal Variable---------*/
reg reset;
wire clk_uart_intern, clk_1_intern, clk_16_intern, clk_100_intern;
reg [7:0] counter_rst;
wire debug_out;
wire head_led;
reg frame_indicator;
/*----------Internal Modules----------*/
pll u0 (
	.clk_in_clk    				(clock_in),
	.clk_uart_clk      			(clk_uart_intern),
	.c0_clk        				(clk_1_intern),
	.clk_16mhz_intern_clk 		(clk_16_intern),
	.reset_1_reset_n 				(reset),
	.clk_100mhz_intern_clk		(clk_100_intern)
);
	 
portable p0 (
	.clock_uart						(clk_uart_intern),			//clock for uart baudrate
	.clock_16MHz					(clcck_adc),		//clock for driving ADCs, either from ADC or XO
	.clk_1_intern					(clk_1_intern),		//very slow clock for debug triggering
	.clk_core						(clk_100_intern),
	.FTDCLK                    (FTDCLK),
	.reset							(reset),				//accord with slower clk (uart)
	//COM
	.rx1								(rx1),
	//ADC1
	.adc1_din						(adc1_din),
	.adc1_ndrdy						(adc1_ndrdy),
	//ADC2
	.adc2_din						(adc2_din),
	.adc2_ndrdy						(adc2_ndrdy),
	/*  output  */
	//COM
	.tx1								(tx1),
	.LED_1                     (LED_1),
	.LED_2							(LED_2),
	
	//ADC1
	.adc1_dout						(adc1_dout),
	.adc1_sclk						(adc1_sclk),
	.adc1_n_cs						(adc1_n_cs),
	.adc1_start						(adc1_start),
	.adc1_reset						(adc1_reset),
	.adc1_pwdn						(adc1_pwdn),
	//ADC2
	.adc2_dout						(adc2_dout),
	.adc2_sclk						(adc2_sclk),
	.adc2_n_cs						(adc2_n_cs),
	.adc2_start						(adc2_start),
	.adc2_reset						(adc2_reset),
	.adc2_pwdn						(adc2_pwdn),	
	.deMUX_Y							(deMUX_Y[31:0]),
	.debug_out						(debug_out),
	.HEAD_LED						(head_led),
);
	 
/*----------Initials------------------*/
initial
begin
	reset <= 1;
	counter_rst <= 8'h00;
end

always @ (posedge clock_in)
begin
	if (counter_rst[7:0] == 8'hff && reset == 1) begin
		reset <= 0;
	end else begin
		counter_rst <= counter_rst + 1;
	end
end
always @ (posedge head_led or posedge reset)
begin
	if (reset) begin
		frame_indicator = 0;
	end else begin
		frame_indicator = !frame_indicator;
	end
end
//assign clk_uart_intern = clock_in;
//assign clk_16_intern = clock_in;

//assign deMUX_Y[4:0] = 5'b00001;

assign out_1 = clk_1_intern; //LED 1
assign out_2 = LED_2; //LED 2
assign out_3 = LED_1;  //LED 3
assign out_4 = 1;		
assign out_5 = 1;//frame_indicator;//clk_1_intern;

endmodule
