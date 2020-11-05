module FIFO_IP(
	input		sys_clk,
	input		sys_rst_n,
	
	output[4:0] rd_data_count,
	output[4:0] wr_data_count,
	//output[7:0]	dout,
	output[7:0]	rd_data,
	output		full,
	output		empty
);

	wire		fifo_almost_empty;
	wire		fifo_almost_full;
	wire		fifo_wr_en;
	wire		fifo_rd_en;
	wire[7:0]	fifo_wr_data;
	wire[7:0]	fifo_rd_data;
	
	fifo_generator_0 your_instance_name (
		.wr_clk			(sys_clk			),			// input wire wr_clk
		.rd_clk			(sys_clk			),			// input wire rd_clk
		.din			(fifo_wr_data		),			// input wire [7 : 0] din
		.wr_en			(fifo_wr_en			),			// input wire wr_en
		.rd_en			(fifo_rd_en			),			// input wire rd_en
		.dout			(fifo_rd_data		),			// output wire [7 : 0] dout
		.full			(full				),			// output wire full
		.almost_full	(fifo_almost_full	),			// output wire almost_full
		.empty			(empty				),			// output wire empty
		.almost_empty	(fifo_almost_empty	),			// output wire almost_empty
		.rd_data_count	(rd_data_count		),			// output wire [4 : 0] rd_data_count
		.wr_data_count	(wr_data_count		)			// output wire [4 : 0] wr_data_count
	);

/*
	FIFO_WR	FIFO_WR_U(
		.clk				(sys_clk			),
		.rst_n				(sys_rst_n			),
		.fifo_almost_empty	(fifo_almost_empty	),
		.fifo_almost_full	(fifo_almost_full	),

		.fifo_wr_en			(fifo_wr_en			),
		.fifo_wr_data		(fifo_wr_data		)
	);
*/

	FIFO_RD FIFO_RD_U(
		.clk				(sys_clk			),
		.rst_n				(sys_rst_n			),
		.fifo_almost_empty	(fifo_almost_empty	),
		.fifo_almost_full	(fifo_almost_full	),
		.fifo_rd_data		(fifo_rd_data		),

		.fifo_rd_en			(fifo_rd_en			),
		.data				(rd_data)
	);

	//assign	rd_data = fifo_rd_data;

endmodule
