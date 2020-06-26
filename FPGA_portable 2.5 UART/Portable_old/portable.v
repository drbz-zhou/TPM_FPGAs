module portable (
clock_in,
out_1,
out_2,
out_3,
out_4,
out_5,
tx1,
rx1,
);
input clock_in, rx1;
output out_1, out_2, out_3, out_4, out_5, tx1;
wire clock_in, out_1, out_2, out_3, out_4, out_5;
reg reset;

wire pll_uart, ld_tx_data_intern1, tx_enable_intern1, tx1;
wire [7:0] tx_data_intern1;
initial
begin
reset <= 1;
end

always @ (posedge clock_in)
begin
	if (reset) begin
		reset <= 0;
		end 
end


    pll u0 (
        .clk_in_clk    (clock_in),    //  clk_in.clk
		  .clk_uart_clk      (pll_uart),      
        .c0_clk        (out_1),        //      c0.clk
        .reset_1_reset_n (reset)  // reset_1.reset
    );
	 
	 
uart u1(	
			.reset 						(reset),
			.txclk 						(pll_uart),
			.ld_tx_data 				(ld_tx_data_intern1),
			.tx_data 					(tx_data_intern1),
			.tx_enable 					(tx_enable_intern1),
			.tx_out 						(tx1),
			.tx_empty 					() ,
			.rxclk  						(pll_uart),
			.uld_rx_data 				(),
			.rx_data 					(),
			.rx_enable 					(),
			.rx_in	 					(rx1),
			.rx_empty 					()
			);
			
UARTCTL uc1 (
.reset          	(reset),
.clock      		(pll_uart),
.ld_tx_data_ctr 	(ld_tx_data_intern1), 
.tx_data_ctr		(tx_data_intern1), 
.tx_enable_ctr		(tx_enable_intern1),
//.ADCDATA				(RESULTDATA1[31:0]),
.SYNC_UART			(out_1), 
//.HEAD_UART			(HEAD_UART),
//.TAIL_UART			(TAIL_UART),
//.debug_deMUX_X		(A_scan[4:0]),
//.debug_deMUX_Y    (MUX_O[7:0]),
);
	 
assign out_2 = clock_in;
assign out_3 = 0;
assign out_4 = ~out_1;
assign out_5 = out_1;
endmodule
