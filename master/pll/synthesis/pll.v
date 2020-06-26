// pll.v

// Generated using ACDS version 13.0sp1 232 at 2014.06.30.15:48:38

`timescale 1 ps / 1 ps
module pll (
		input  wire  altpll_0_areset_conduit_export,    //    altpll_0_areset_conduit.export
		output wire  altpll_0_locked_conduit_export,    //    altpll_0_locked_conduit.export
		output wire  altpll_0_phasedone_conduit_export, // altpll_0_phasedone_conduit.export
		output wire  pll_c1_clk,                        //                     pll_c1.clk
		output wire  pll_c2_clk,                        //                     pll_c2.clk
		output wire  pll_c0_clk,                        //                     pll_c0.clk
		input  wire  clk_1_clk,                         //                      clk_1.clk
		input  wire  reset_1_reset                      //                    reset_1.reset
	);

	pll_altpll_0 altpll_0 (
		.clk       (clk_1_clk),                         //       inclk_interface.clk
		.reset     (reset_1_reset),                     // inclk_interface_reset.reset
		.read      (),                                  //             pll_slave.read
		.write     (),                                  //                      .write
		.address   (),                                  //                      .address
		.readdata  (),                                  //                      .readdata
		.writedata (),                                  //                      .writedata
		.c0        (pll_c0_clk),                        //                    c0.clk
		.c1        (pll_c1_clk),                        //                    c1.clk
		.c2        (pll_c2_clk),                        //                    c2.clk
		.areset    (altpll_0_areset_conduit_export),    //        areset_conduit.export
		.locked    (altpll_0_locked_conduit_export),    //        locked_conduit.export
		.phasedone (altpll_0_phasedone_conduit_export)  //     phasedone_conduit.export
	);

endmodule
