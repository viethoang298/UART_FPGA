module FIFO#( parameter B = 8, W = 4)
(
	input wire clk, rst,
	input wr, rd,
	input [B-1:0] w_data,
	output wire empty, full,
	output wire [B-1:0] r_data
	);

//signal declaration
reg [B-1:0] array_reg[2**W-1:0];
reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
reg full_reg, empty_reg, full_next, empty_next;
wire wr_en;
// next state logic for register file
always@(posedge clk)
   if(wr_en)
		array_reg[w_ptr_reg] <= w_data;
assign r_data = array_reg[r_ptr_reg];
assign wr_en = wr & (!full_reg);

//next state logic for pointer
always@(posedge clk, posedge rst)
if(rst)
	begin
   w_ptr_reg <= 0;
	r_ptr_reg <= 0;
	full_reg <= 1'b0;
	empty_reg <= 1'b0;
	end
else 
  begin
   w_ptr_reg <= w_ptr_next;
	r_ptr_reg <= r_ptr_next;
	full_reg <= full_next;
	empty_reg <= empty_next;
  end
// next_state logic
always@*
// default
begin
    w_ptr_succ = w_ptr_reg+1;
	 r_ptr_succ = r_ptr_reg+1;
	 w_ptr_next = w_ptr_reg+1;
	 r_ptr_next = r_ptr_reg+1;
	 case({wr, rd})
	 /*2'b00: w_ptr_next = w_ptr_reg;
			  r_ptr_next = r_ptr_reg;*/
	 2'b01:begin if(~empty_reg)
			  r_ptr_next = r_ptr_succ;
			  full_next = 1'b0;
			  if(r_ptr_succ == w_ptr_reg)
					empty_next = 1'b1;
			 end 
	 2'b10:begin if(~full_reg)
			  w_ptr_next = r_ptr_succ;  // check full -> write-> not empty -> check full
			  empty_next = 1'b0;
			  if(w_ptr_succ == r_ptr_reg)
					full_next = 1'b1;
			 end
	 2'b11:begin w_ptr_next = w_ptr_succ;  // not need to ckeck full or empty
			  r_ptr_next = r_ptr_succ;
	       end
	 endcase
end
assign full = full_reg;
assign empty = empty_reg;

 
 
endmodule