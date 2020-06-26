//sending increasing number for debugging

module master (
clock		,
sign_o   ,
sign_gnd	,
pll_c0	,
pll_c1	,
///////////////////////////
FSI1		,
SDI1	 	,
SDO1		,
FSO1		,
SCO1		,
CS1		,
//A3			,

tx1			,
rx1			,
///////////////////////////
FSI2		,
SDI2	 	,
SDO2		,
FSO2		,
SCO2		,
CS2		,
//A3			,

tx2			,
rx2			,
///////////////////////////
FSI3		,
SDI3	 	,
SDO3		,
FSO3		,
SCO3		,
CS3		,
//A3			,

tx3			,
rx3			,
///////////////////////////
FSI4		,
SDI4	 	,
SDO4		,
FSO4		,
SCO4		,
ADCRESET,
CS4		,

tx4			,
rx4			,

A			,
MUX_O    ,
clk_out	,
SYNC		,
pll_locked
);

input	clock;
input rx1, FSO1, SDO1, SCO1;
input rx2, FSO2, SDO2, SCO2;
input rx3, FSO3, SDO3, SCO3;
input rx4, FSO4, SDO4, SCO4;

output sign_o, sign_gnd,  pll_c0,  pll_c1;
output ADCRESET,	SYNC, A , pll_locked;

output tx1, FSI1, SDI1, CS1;
output tx2, FSI2, SDI2, CS2;
output tx3, FSI3, SDI3, CS3;
output tx4, FSI4, SDI4, CS4;

output [7:0]MUX_O;
output clk_out;

wire clock, sign_gnd, sign_vdd, sign_o, ADCRESET;

wire rx1, FSO1, SDO1, SCO1, FSI1, SDI1, ADCRESET1;
wire rx2, FSO2, SDO2, SCO2, FSI2, SDI2, ADCRESET2;
wire rx3, FSO3, SDO3, SCO3, FSI3, SDI3, ADCRESET3;
wire rx4, FSO4, SDO4, SCO4, FSI4, SDI4, ADCRESET4;

wire pll_c0;
wire pll_c1;
wire pll_c2;

wire [7:0] tx_data_intern1;
wire ld_tx_data_intern1;
wire tx_enable_intern1;
wire ADCSTATUS1_1;
wire [31:0] RESULTDATA1;
wire  CS1;
wire VALID_1, SYNCUART_1;

wire [7:0] tx_data_intern2;
wire ld_tx_data_intern2;
wire tx_enable_intern2;
wire ADCSTATUS2_1;
wire [31:0] RESULTDATA2;
wire  CS2;
wire VALID_2, SYNCUART_2;

wire [7:0] tx_data_intern3;
wire ld_tx_data_intern3;
wire tx_enable_intern3;
wire ADCSTATUS3_1;
wire [31:0] RESULTDATA3;
wire  CS3;
wire VALID_3, SYNCUART_3;

wire [7:0] tx_data_intern4;
wire ld_tx_data_intern4;
wire tx_enable_intern4;
wire pll_locked;
wire ADCSTATUS4_1;
wire [31:0] RESULTDATA4;
wire  CS4;
wire VALID_4, SYNCUART_4;

wire config_done;
wire HEAD_UART, TAIL_UART, First_SCAN, Last_SCAN;

reg reset;
wire	SYNC;
wire [4:0]	A;
wire [4:0]	A_scan;

wire [7:0] MUX_O;

initial
begin
reset <= 1;
end

always @ (posedge clock)
begin
	if (reset) begin
		reset <= 0;
		end 
end





pll pll (
        .clk_1_clk                           (clock),                           //                        clk.clk
        .reset_1_reset                     (reset),                     //                      reset.reset_n
        .pll_c0_clk                        (pll_c0),                        //                     pll_c0.clk
		  .pll_c1_clk                        (pll_c1), 
		  .pll_c2_clk                        (pll_c2),
        .altpll_0_areset_conduit_export    (),    //    altpll_0_areset_conduit.export
        .altpll_0_locked_conduit_export    (pll_locked),    //    altpll_0_locked_conduit.export
        .altpll_0_phasedone_conduit_export ()  // altpll_0_phasedone_conduit.export
    );

/*
pllneo pll(
	.inclk0    	(clock),
	.c0        	(pll_c0),
	.c1			(pll_c1),
	.c2			(pll_c2),
	.locked		(pll_locked)
	);	*/
//////////////////////////////////////////////////////////////////////////
uart u1(	
			.reset 						(reset),
			.txclk 						(pll_c0),
			.ld_tx_data 				(ld_tx_data_intern1),
			.tx_data 					(tx_data_intern1),
			.tx_enable 					(tx_enable_intern1),
			.tx_out 						(tx1),
			.tx_empty 					() ,
			.rxclk  						(pll_c0),
			.uld_rx_data 				(),
			.rx_data 					(),
			.rx_enable 					(),
			.rx_in	 					(rx1),
			.rx_empty 					()
			);
			
UARTCTL uc1 (
.reset          	(reset),
.clock      		(pll_c0),
.ld_tx_data_ctr 	(ld_tx_data_intern1), 
.tx_data_ctr		(tx_data_intern1), 
.tx_enable_ctr		(tx_enable_intern1),
.ADCDATA				(RESULTDATA1[31:0]),
.SYNC_UART			(SYNCUART_1), 
.HEAD_UART			(HEAD_UART),
.TAIL_UART			(TAIL_UART),
.debug_deMUX_X		(A_scan[4:0]),
.debug_deMUX_Y    (MUX_O[7:0]),
);

ADCCTL	adcctl1 (
.reset         (reset) ,
.clock      	(pll_c1)	,
.ADCSTATUS1		(ADCSTATUS1_1),
.ADCRESET		(ADCRESET1)
			);

ADCREAD  adcread1 (
.reset          (reset),
.SCO				(SCO1),
.SDO				(SDO1), 
.FSO				(FSO1),
.result_data	(RESULTDATA1[31:0])	,
.result_valid	(VALID_1),
.ADCSTATUS1		(ADCSTATUS1_1), //(ready, read done, fail)
//.ADCSTATUS2		

);	 

SIGNEXPAND #(.MULTIFAC(50),
.DIM(6)
) signex1 (
.reset			(reset),
.clock			(pll_c2),
.signal_in		(VALID_1),
.signal_out		(SYNCUART_1),
);
//////////////////////////////////////////////////////////////////////////
uart u2(	
			.reset 						(reset),
			.txclk 						(pll_c0),
			.ld_tx_data 				(ld_tx_data_intern2),
			.tx_data 					(tx_data_intern2),
			.tx_enable 					(tx_enable_intern2),
			.tx_out 						(tx2),
			.tx_empty 					() ,
			.rxclk  						(pll_c0),
			.uld_rx_data 				(),
			.rx_data 					(),
			.rx_enable 					(),
			.rx_in	 					(rx2),
			.rx_empty 					()
			);
			
UARTCTL uc2 (
.reset          	(reset),
.clock      		(pll_c0),
.ld_tx_data_ctr 	(ld_tx_data_intern2), 
.tx_data_ctr		(tx_data_intern2), 
.tx_enable_ctr		(tx_enable_intern2),
.ADCDATA				(RESULTDATA2[31:0]),
.SYNC_UART			(SYNCUART_2), 
.HEAD_UART			(HEAD_UART),
.TAIL_UART			(TAIL_UART),
);

ADCCTL	adcctl2 (
.reset         (reset) ,
.clock      	(pll_c1)	,
.ADCSTATUS1		(ADCSTATUS2_1),
.ADCRESET		(ADCRESET2)
			);

ADCREAD  adcread2 (
.reset          (reset),
.SCO				(SCO2),
.SDO				(SDO2), 
.FSO				(FSO2),
.result_data	(RESULTDATA2[31:0])	,
.result_valid	(VALID_2),
.ADCSTATUS1		(ADCSTATUS2_1), //(ready, read done, fail)
//.ADCSTATUS2		

);

SIGNEXPAND #(.MULTIFAC(25),
.DIM(6)
) signex2 (
.reset			(reset),
.clock			(pll_c2),
.signal_in		(VALID_2),
.signal_out		(SYNCUART_2),
);
//////////////////////////////////

	 
uart u3(	
			.reset 						(reset),
			.txclk 						(pll_c0),
			.ld_tx_data 				(ld_tx_data_intern3),
			.tx_data 					(tx_data_intern3),
			.tx_enable 					(tx_enable_intern3),
			.tx_out 						(tx3),
			.tx_empty 					() ,
			.rxclk  						(pll_c0),
			.uld_rx_data 				(),
			.rx_data 					(),
			.rx_enable 					(),
			.rx_in	 					(rx3),
			.rx_empty 					()
			);
			
UARTCTL uc3 (
.reset          	(reset),
.clock      		(pll_c0),
.ld_tx_data_ctr 	(ld_tx_data_intern3), 
.tx_data_ctr		(tx_data_intern3), 
.tx_enable_ctr		(tx_enable_intern3),
.ADCDATA				(RESULTDATA3[31:0]),
.SYNC_UART			(SYNCUART_3), 
.HEAD_UART			(HEAD_UART),
.TAIL_UART			(TAIL_UART),
);

ADCCTL	adcctl3 (
.reset         (reset) ,
.clock      	(pll_c1)	,
.ADCSTATUS1		(ADCSTATUS3_1),
.ADCRESET		(ADCRESET3)
			);

ADCREAD  adcread3 (
.reset          (reset),
.SCO				(SCO3),
.SDO				(SDO3), 
.FSO				(FSO3),
.result_data	(RESULTDATA3[31:0])	,
.result_valid	(VALID_3),
.ADCSTATUS1		(ADCSTATUS3_1), //(ready, read done, fail)
//.ADCSTATUS2		

);

SIGNEXPAND #(.MULTIFAC(25),
.DIM(6)
) signex3 (
.reset			(reset),
.clock			(pll_c2),
.signal_in		(VALID_3),
.signal_out		(SYNCUART_3),
);
	 
//////////////////////////////////
uart u4(	
			.reset 						(reset),
			.txclk 						(pll_c0),
			.ld_tx_data 				(ld_tx_data_intern4),
			.tx_data 					(tx_data_intern4),
			.tx_enable 					(tx_enable_intern4),
			.tx_out 						(tx4),
			.tx_empty 					() ,
			.rxclk  						(pll_c0),
			.uld_rx_data 				(),
			.rx_data 					(),
			.rx_enable 					(),
			.rx_in	 					(rx4),
			.rx_empty 					()
			);

UARTCTL uc4 (
.reset          	(reset),
.clock      		(pll_c0),
.ld_tx_data_ctr 	(ld_tx_data_intern4), 
.tx_data_ctr		(tx_data_intern4), 
.tx_enable_ctr		(tx_enable_intern4),
.ADCDATA				(RESULTDATA4[31:0]),
.SYNC_UART			(SYNCUART_4), 
.HEAD_UART			(HEAD_UART),
.TAIL_UART			(TAIL_UART),
.debug_deMUX_X		(A_scan[4:0]),
.debug_deMUX_Y    (MUX_O[7:0]),
);

ADCCTL	adcctl4 (
.reset         (reset) ,
.clock      	(pll_c1)	,
.ADCSTATUS1		(ADCSTATUS4_1),
.ADCRESET		(ADCRESET4)
			);

ADCREAD  adcread4 (
.reset          (reset),
.SCO				(SCO4),
.SDO				(SDO4), 
.FSO				(FSO4),
.result_data	(RESULTDATA4[31:0])	,
.result_valid	(VALID_4),
.ADCSTATUS1		(ADCSTATUS4_1), //(ready, read done, fail)
//.ADCSTATUS2		

);

SIGNEXPAND #(.MULTIFAC(25),
.DIM(6)
) signex4 (
.reset			(reset),
.clock			(pll_c2),
.signal_in		(VALID_4),
.signal_out		(SYNCUART_4),
);

////////////////////////////////////////

MUX32 m4(
.reset          (reset),
.clock      		(clock),
.CS2					(CS2),
.CS3					(CS3),
.CS4					(CS4),
.A_in					(A_scan[4:0]),
.A					(A[4:0]),
);

SCANCTL2 scan1(
.reset				(reset),
.clock				(pll_c2),
.config_done		(config_done),
.deMUX_X			(A_scan[4:0]),
.deMUX_Y			(MUX_O[7:0]),
.FSO1				(FSO1),
.FSO2				(FSO2),
.FSO3				(FSO3),
.FSO4				(FSO4),
.HEAD_UART		(HEAD_UART),
.TAIL_UART		(TAIL_UART),	
);
/*
SIGNEXPAND #(.MULTIFAC(25),
.DIM(6)
) signex_first (
.reset			(reset),
.clock			(pll_c2),
.signal_in		(First_SCAN),
.signal_out		(HEAD_UART),
);

SIGNEXPAND #(.MULTIFAC(25),
.DIM(6)
) signex_last (
.reset			(reset),
.clock			(pll_c2),
.signal_in		(Last_SCAN),
.signal_out		(TAIL_UART),
);
*/

assign 	SYNC= 1'b1;
assign	FSI1 = 1'b1;
assign	FSI2 = 1'b1;
assign	FSI3 = 1'b1;
assign	FSI4 = 1'b1;
assign   sign_gnd = 1'b0;
assign	sign_vdd = 1'b1;
assign	ADCRESET = ADCRESET1 || ADCRESET2 || ADCRESET3 || ADCRESET4;
assign 	config_done = ADCSTATUS1_1 && ADCSTATUS2_1 && ADCSTATUS3_1 && ADCSTATUS4_1;
assign clk_out=pll_c0;
endmodule
