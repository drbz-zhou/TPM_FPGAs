module MUX_DECODER (
deMUX_Y_in          ,
deMUX_Y_out          
);
// Port declarations
input  		[4:0]      deMUX_Y_in		;
output reg  [31:0]      deMUX_Y_out   ;
reg [7:0] i;

// UART RX Logic
always @ (deMUX_Y_in[4:0])
begin: demux
	for (i = 0; i < 32; i = i + 1)
		begin
		if(deMUX_Y_in[4:0]==i) 
			deMUX_Y_out [i]= 1;
		else 
			deMUX_Y_out[i]=0;
		end
	end
endmodule
