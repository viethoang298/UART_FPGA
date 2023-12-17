module UART_receiver
      #(parameter D_BIT = 8, 
		            SB_TICK = 16
		)
		(
		input clk, rst,
		input rx, s_tick,
		output [D_BIT-1:0] d_out,
		output reg rx_done_tick
		);
		
localparam [1:0] 
         idle = 2'b00, 
			start = 2'b01, 
			data = 2'b10, 
			stop = 2'b11;	
reg[1:0] state_reg, state_next;	
reg [3:0] s_reg, s_next;
reg [2:0] n_reg, n_next;
reg [D_BIT-1:0] b_reg, b_next;

always@(posedge clk, posedge rst)
begin
     if(rst)
	  begin
	     state_reg <= idle;
		  s_reg <= 0;
		  n_reg <= 0;
		  b_reg <= 0;
	  end
	  else
	  begin 
	     state_reg <= state_next;
		  s_reg <= s_next;
		  n_reg <= n_next;
		  b_reg <= b_next;
	  end  
end
always@*
begin
     state_next <= state_reg;
	  s_next <= s_reg;
	  n_next <= n_reg;
	  b_next <= b_reg;
	  rx_done_tick <= 1'b0;
     case(state_reg)
	       idle:  begin
			        if(rx == 0)
					    begin
					     state_next = start;
						  s_next = 0;
						 end
					  end
		    start: begin
			 		  if(s_tick == 1'b1)
			           if(s_reg == 4'd7)
						     begin
						     s_next = 0;
							  n_next = 0;
							  state_next = data;
							  end
						  else 
					        s_next = s_reg + 1;
					  end
			 data: begin
			       if(s_tick == 1'b1)
					     if(s_reg == 4'd15)
						  begin
						     s_next = 0;
							  b_next = {rx, b_reg[7:1]};
							  if(n_reg == D_BIT - 1)
							    state_next = stop;
							  else 
							    n_next = n_reg + 1;
						  end
						  else 
						      s_next = s_reg + 1;
				 	end
	       stop: begin
			       if(s_tick == 1'b1)
					    if(s_reg == (SB_TICK - 1))
						     begin
							  rx_done_tick = 1'b1;
							  state_next = idle;
							  end
						 else 
							  s_next = s_reg + 1;		 					 
                end    
	  endcase
end
assign dout = b_reg;

endmodule 
				
	   
