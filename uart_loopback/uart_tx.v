module uart_tx(
	input	wire		clk,
	input	wire		rst_n,
	input	wire		tx_triger_flag,
	input	wire[7:0]	tx_data,
	
	output	wire		serial_txd		// 串行输出，一根线
);

	parameter	CLOCK_FREQ	= 32'd50000000;
	parameter	BAUDRATE	= 32'd115200;
//	parameter	COUNTER_MAX	= CLOCK_FREQ / BAUDRATE;
	parameter	COUNTER_MAX = 32'd435;	// CLOCK_FREQ / BAUDRATE;
	parameter	UART_BIT 	= 4'd9;
	parameter	COUNTER_RST	= 32'h00000000;
	parameter	BYTE_RST	= 8'h00;
	
	reg[3:0]	tx_bit_cnt_reg;
	reg[31:0]	baudrate_counter;
	
	reg			serial_txd_reg;
	reg			tx_start_flag;
	
	// Transmit signal generate
	always@(posedge clk or negedge rst_n) begin
		if(rst_n == 1'b0)	tx_start_flag <= 1'b0;
		else begin
			// tx_bit_cnt_reg	发送数据位数计数器 操作见下方always中
			//if((tx_triger_flag == 1'b1) && tx_bit_cnt_reg <= UART_BIT)	tx_start_flag <= 1'b1;
			//else	tx_start_flag <= 1'b0;
			if(tx_triger_flag) begin
				tx_start_flag <= 1'b1;
			end
			else if(tx_bit_cnt_reg == UART_BIT)	tx_start_flag <= 1'b0;
			else	tx_start_flag <= tx_start_flag;
		end
	end
	
	// Baud Rate Generator
	always@(posedge clk or negedge rst_n) begin
		if(rst_n == 1'b0)	baudrate_counter <= COUNTER_RST;
		else begin
			if(tx_start_flag == 1'b1) begin
				if(baudrate_counter < COUNTER_MAX)	baudrate_counter <= baudrate_counter + 1'b1;
				else	baudrate_counter <= COUNTER_RST;
			end
			else	baudrate_counter <= COUNTER_RST;
		end
	end
	
	// Bit Counting For transmited data...
	always@(posedge clk or negedge rst_n) begin
		if(rst_n == 1'b0)	tx_bit_cnt_reg <= 8'h00;
		else begin
			//if((baudrate_counter == COUNTER_MAX) || (tx_bit_cnt_reg <= UART_BIT))	tx_bit_cnt_reg <= tx_bit_cnt_reg + 1'b1;
			//else	tx_bit_cnt_reg <= 1'b0;
			if(baudrate_counter == COUNTER_MAX)
				if(tx_bit_cnt_reg < UART_BIT)	tx_bit_cnt_reg <= tx_bit_cnt_reg + 1'b1;
				else	tx_bit_cnt_reg <= tx_bit_cnt_reg;
			else if(tx_bit_cnt_reg == UART_BIT)
				tx_bit_cnt_reg <= 4'h0;
		end
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(rst_n == 1'b0)	serial_txd_reg <= 1'b1;
		else begin
			if(tx_start_flag) begin
				case(tx_bit_cnt_reg)
					0:serial_txd_reg <= 1'b0;			// Serial start Bit is 0
					1:serial_txd_reg <= tx_data[0];
					2:serial_txd_reg <= tx_data[1];
					3:serial_txd_reg <= tx_data[2];
					4:serial_txd_reg <= tx_data[3];
					5:serial_txd_reg <= tx_data[4];
					6:serial_txd_reg <= tx_data[5];
					7:serial_txd_reg <= tx_data[6];
					8:serial_txd_reg <= tx_data[7];
					9:serial_txd_reg <= 1'b1;
					default:	serial_txd_reg <= 1'b1;					
				endcase
			end
			else	serial_txd_reg <= 1'b1;
		end
	end

	assign serial_txd = serial_txd_reg;
	
endmodule
