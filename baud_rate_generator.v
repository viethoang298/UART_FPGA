module baud_rate_generator
	#( 
   parameter N = 8, M = 163 // mod m
   )
	(
	input wire clk, reset,
	output wire tick
	);
	
// signal
reg [N-1:0] r_reg;
wire [N-1:0] r_next;
 always@(posedge clk, posedge reset)
 if(reset)
	r_reg <= 0;
 else 
	r_reg <= r_next;

 // next state
 assign r_next = (r_reg == M-1)? 0 : r_reg+1;
 // output logic
 assign tick = (r_reg == M-1)? 1'b1 : 1'b0;
 
 endmodule