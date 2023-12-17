module UART
        #(
		  parameter D_BIT = 8, SB_TICK = 16, 
		            DVBR = 163, DVSV_BIT = 8,
						FIFO_W = 2)
		  (
		  input wire clk, rst,
		  input rd_uart, wr_uart, rx,
		  input wire [D_BIT-1:0] w_data,
		  output rx_empty, tx_full, tx,
		  output [D_BIT-1:0] r_data
		  );
		  
wire tick, rx_done_tick, tx_done_tick;
wire tx_empty, tx_fifo_not_empty;
wire [7:0] tx_fifo_out, rx_data_out;

baud_rate_generator #(.M(DVBR),.N(DVSV_BIT))  baud_gen_unit
                    (.clk(clk), .rst(rst), .tick(tick));
UART_receiver #(.D_BIT(D_BIT),  .SB_TICK(SB_TICK)) rx_unit
                     (.clk(clk), 
							.rst(rst), 
							.rx(rx), 
							.s_tick(tick), 
							.d_out(rx_data_out),
							.rx_done_tick(rx_done_tick));
UART_transmitter #(.D_BIT(D_BIT) ,.SB_TICK(SB_TICK)) tx_unit(
                     .clk(clk), 
							.rst(rst),
							.tx_start(tx_fifo_not_empty), 
							.tx(tx), 
							.s_tick(tick), 
							.d_in(tx_fifo_out),
							.tx_done_tick(tx_done_tick)
							);	  
FIFO  #(.B(D_BIT), .W(FIFO_W)) fifo_tx_unit 
                    (.clk(clk),  
						   .rst(rst), 
							.rd(tx_done_tick), 
							.wr(wr_uart), 
							.w_data(w_data), 
							.empty(tx_empty), 
							.full(tx_full), 
							.r_data(tx_fifo_out)); 
FIFO  #(.B(D_BIT), .W(FIFO_W)) fifo_rx_unit (
                     .clk(clk), 
							.rst(rst), 
							.rd(rd_uart), 
							.wr(rx_done_tick), 
							.w_data(rx_data_out), 
							.empty(rx_empty), 
							.full(), 
							.r_data(r_data)); 
assign tx_fifo_not_empty = ~tx_empty;

endmodule


