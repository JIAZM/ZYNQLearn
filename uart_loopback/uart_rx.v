module uart_rx(
	input	wire		clk,
	input	wire		rst_n,
	input	wire		rxd,
	
	output	wire[7:0]	rx_data,
	output	wire		rx_done
);

	parameter	CLOCK_FREQ	= 32'd50000000;	// clock source 50MHz
	parameter	BAUDRATE	= 32'd115200;
//parameter	COUNTER_MAX	= CLOCK_FREQ / BAUDRATE;
//parameter	COUNTER_MAX_HALF = COUNTER_MAX / 2'd2;
	parameter	COUNTER_MAX	= 32'd434;
	parameter	COUNTER_MAX_HALF = 32'd217;
	parameter	UART_BIT	= 4'd9;
	parameter	COUNTER_RST	= 32'h00000000;
	
	//Rx Start Flag
	reg			rx_start_flag;
	reg[31:0]	baudrate_counter;
	reg[7:0]	rx_byte;
	reg[3:0]	rx_bit_cnt_reg;

	// 使用两个寄存器锁存检测低电平
	reg 		rxd_reg_1;
	reg			rxd_reg_2;
	wire		rx_start_cap;
	// Rx Finish Flag
	reg			rx_done_flag;
	//wire		rx_done_flag;
	
	assign	rx_done = rx_done_flag;
	//assign	rx_done_flag = (rx_bit_cnt_reg == UART_BIT) ? 1'b1 : 1'b0;
	
	assign	rx_start_cap = (~rxd_reg_1) & rxd_reg_2;
	
	assign	rx_data = rx_byte;

	// Cap uart start bit
	always@(posedge clk or negedge rst_n) begin
		if(rst_n == 1'b0) begin
			rxd_reg_1 <= 1'b0;
			rxd_reg_2 <= 1'b0;
		end
		else begin
			rxd_reg_1 <= rxd;
			rxd_reg_2 <= rxd_reg_1;
		end
	end
	
	// Set Receive start flag
	always@(posedge clk or negedge rst_n) begin
		if(rst_n == 1'b0)	rx_start_flag <= 1'b0;
		else begin
			if(rx_start_cap)	rx_start_flag <= 1'b1;
			else if(rx_bit_cnt_reg == UART_BIT) begin
				rx_start_flag <= 1'b0;
			end
			else	rx_start_flag <= rx_start_flag;
		end
	end
	
	// Baud Rate Generate
	always@(posedge clk or negedge rst_n) begin
		if(rst_n == 1'b0)	baudrate_counter <= COUNTER_RST;
		else begin
			if(rx_start_flag)
				//baudrate_counter <= (baudrate_counter < COUNTER_MAX) ? (baudrate_counter + 1'b1) : 32'd0;
				if(baudrate_counter < COUNTER_MAX)	baudrate_counter <= baudrate_counter + 1'b1;
				else	baudrate_counter <= COUNTER_RST;
			else	baudrate_counter <= 32'd0;
		end
	end

	// Receive Data counter
	always@(posedge clk or negedge rst_n) begin
		if(rst_n == 1'b0) begin
			rx_bit_cnt_reg <= 4'h0;
			rx_done_flag <= 1'b0;
		end
		else begin
			if(baudrate_counter == COUNTER_MAX)	rx_bit_cnt_reg <= rx_bit_cnt_reg + 1'b1;
			else if(rx_bit_cnt_reg == UART_BIT)	begin
				rx_bit_cnt_reg <= 4'h0;
				rx_done_flag <= 1'b1;
			end	
			else begin
				rx_bit_cnt_reg <= rx_bit_cnt_reg;
				rx_done_flag <= 1'b0;
			end
		end
	end
	
	// Receive Data
	always@(posedge clk or negedge rst_n) begin
		if(rst_n == 1'b0)	rx_byte <= 8'h00;	/* {H---->L} */
		else begin
			if(baudrate_counter == COUNTER_MAX_HALF) begin
				// Serial Teansmit is LSB First
				if((rx_bit_cnt_reg >= 1) && (rx_bit_cnt_reg < UART_BIT))
					rx_byte <= {rxd, rx_byte[7:1]};
				else	rx_byte <= 8'h00;
			end
			else
				rx_byte <= rx_byte;
		end
	end

endmodule
