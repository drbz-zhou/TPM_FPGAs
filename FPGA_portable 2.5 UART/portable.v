/*
		top level module
		all clocks and reset are driven from outside
*/

module portable (
/*  input  */
//CLOCKS
clock_uart,			//clock for uart baudrate
clock_16MHz,		//clock for driving ADCs, either from ADC or XO
clk_1_intern,		//very slow clock for debug triggering
clk_core,			//very fast clock for core
FTDCLK,          //clock for manage parallel fifo
reset,				//accord with slower clk (uart)
//COM
rx1,
//ADC1
adc1_din,
adc1_ndrdy,
//ADC2
adc2_din,
adc2_ndrdy,
/*  output  */
//COM
tx1,
LED_1,
LED_2,
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
//DEMUX
deMUX_Y,
debug_out,
HEAD_LED,
);
/*----------Input Ports --------------*/
input clock_uart, clock_16MHz, clk_1_intern, clk_core, FTDCLK, reset;
input rx1;
input adc1_din, adc1_ndrdy;
input adc2_din, adc2_ndrdy;
/*----------Output Ports--------------*/
output wire  tx1;
output LED_1, LED_2;
output adc1_dout, adc1_sclk, adc1_n_cs, adc1_start, adc1_reset, adc1_pwdn;
output adc2_dout, adc2_sclk, adc2_n_cs, adc2_start, adc2_reset, adc2_pwdn;
output wire[31:0]	deMUX_Y;
output debug_out;
output wire HEAD_LED;
/*----------Input Ports Type----------*/
wire clock_uart, clock_16MHz, clk_1_intern, clk_core, FTDCLK, reset;
wire rx1;
wire adc1_din, adc1_ndrdy;
wire adc2_din, adc2_ndrdy;
/*----------Output Ports Type---------*/
//wire tx1;
wire LED_1;
wire LED_2;
wire adc1_dout, adc1_sclk, adc1_n_cs, adc1_start, adc1_reset, adc1_pwdn;
wire adc2_dout, adc2_sclk, adc2_n_cs, adc2_start, adc2_reset, adc2_pwdn;
wire debug_out;
/*----------Internal Variable---------*/
wire ld_tx_data_intern1, tx_enable_intern1;
wire [7:0] tx_data_intern1;
wire [31:0] RESULTDATA1;
wire	adc1_valid, data1_valid, adc1_config_done;

wire [31:0] RESULTDATA2;
wire	adc2_valid, data2_valid, adc2_config_done;
wire [4:0] deMUX_Y_intern;
wire HEAD_UART, TAIL_UART;

wire sync_UART;

/*----------Internal Modules----------*/
	 
uart u1(	
			.reset 						(reset),
			.txclk 						(clock_uart),
			.ld_tx_data 				(ld_tx_data_intern1),
			.tx_data 					(tx_data_intern1),
			.tx_enable 					(tx_enable_intern1),
			.tx_out 						(tx1),
		//	.tx_wr                   (WR),//new
		//	.tx_siwu                 (SIWU),//new
			.tx_empty 					() ,
			.rxclk  						(clock_uart),
			.uld_rx_data 				(),
			.rx_data 					(),
			.rx_enable 					(),
			.rx_in	 					(rx1),
			//.tx_e                   (TXE),
			.rx_empty 					()
			);
			
UARTCTL uc1 (
.reset          	(reset),
.clock      		(clock_uart),
//.ftdiclk                (FTDCLK),
.ld_tx_data_ctr 	(ld_tx_data_intern1), 
.tx_data_ctr		(tx_data_intern1), 
.tx_enable_ctr		(tx_enable_intern1),
//.tx_out 				(tx1[7:0]),
.ADCDATA			(RESULTDATA1[31:0]),
//.ADCDATA2			(RESULTDATA2[31:0]),
.SYNC_UART			(sync_UART),// && data2_valid),
.HEAD_UART			(HEAD_UART),
.TAIL_UART			(TAIL_UART),
//.tx_e              (TXE),
//.tx_wr             (WR),
//.tx_siwu           (SIWU),
//.led1              (LED_1),
//.debug_deMUX_X		(A_scan[4:0]),
//.debug_deMUX_Y    (MUX_O[7:0]),
);

ADCCTL adcctl1(
.reset          	(reset),
.clock      		(clock_16MHz),
.data_in				(RESULTDATA1[31:0]),
.data_valid			(data1_valid),
//ADC pins
.din					(adc1_din),
.dout					(adc1_dout),
.sclk					(adc1_sclk),
.cs					(adc1_n_cs),
.n_DRDY				(adc1_ndrdy),
.START				(adc1_start),
.n_RST				(adc1_reset),
.n_PWDN				(adc1_pwdn),
.debug_out			(debug_out),
);

ADCCTL adcctl2(
.reset          	(reset),
.clock      		(clock_16MHz),
.data_in				(RESULTDATA2[31:0]),
.data_valid			(data2_valid),
//ADC pins
.din					(adc2_din),
.dout					(adc2_dout),
.sclk					(adc2_sclk),
.cs					(adc2_n_cs),
.n_DRDY				(adc2_ndrdy),
.START				(adc2_start),
.n_RST				(adc2_reset),
.n_PWDN				(adc2_pwdn),
//.debug_out			(debug_out),
);

rise_to_high h1(
	.clk_core			(clk_core),
.clk_target			(clock_uart),
.reset				(reset),
.trigger_in			(data1_valid),
/*  output  */
.trigger_out		(sync_UART),
.debug_out			(),
);

SCANCTL scan1(
.reset				(reset),
.clock				(clk_core), //200MHz
.config_done		(adc_config_done),
//.deMUX_X				(),
.deMUX_Y				(deMUX_Y_intern[4:0]),
.n_DRDY1				(adc1_ndrdy),
.n_DRDY2				(adc2_ndrdy),
.HEAD_UART			(HEAD_UART),
.TAIL_UART			(TAIL_UART),
);

MUX_DECODER mux_decoder(
.deMUX_Y_in         (deMUX_Y_intern[4:0]) ,
.deMUX_Y_out         (deMUX_Y[31:0]),
);

assign HEAD_LED = HEAD_UART || TAIL_UART;
//initial LED_1 = 0;
//always @ (posedge HEAD_UART)
//begin
//	LED_1 = !LED_1;
//end
assign LED_1=sync_UART;
assign LED_2=!tx1;
//
//initial LED_2 = 0;
//always @ (posedge tx1)
//	LED_2 = !LED_2;

endmodule
