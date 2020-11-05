module uart_loopback(
	input	wire	sys_clk,
	input	wire	sys_rst_n,
	
	input	wire	rxd,
	output	wire	txd
);

	wire[7:0]	uart_data;
	wire		rx_flag;
	
	// 有先后关系???
	uart_rx rx_u(
		.clk				(sys_clk),
		.rst_n				(sys_rst_n),
		.rxd				(rxd),
		
		.rx_data			(uart_data),
		.rx_done			(rx_flag)
	);
	
	uart_tx	tx_u(
		.clk				(sys_clk),
		.rst_n				(sys_rst_n),
		.tx_triger_flag		(rx_flag),
		.tx_data			(uart_data),
		
		.serial_txd			(txd)		// 串行输出，一根线
	);

endmodule
