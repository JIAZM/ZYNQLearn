module FIFO_WR(
	input		clk,
	input		rst_n,
	input		fifo_almost_empty,			// 写数据模块检查是否为空，为空后开始写入数据
	input		fifo_almost_full,			// 检查是否写满
	
	output		fifo_wr_en,					// 写使能
	output[7:0]	fifo_wr_data				// 写数据线
);

	reg[1:0]	almost_empty_flag = 2'b00;	// 抓取almost_empty上升沿
	wire		empty_sync;					// 读写时钟同步信号线
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)	almost_empty_flag <= 2'd0;
		else begin
			almost_empty_flag[0] <= fifo_almost_empty;
			almost_empty_flag[1] <= almost_empty_flag[0];
		end
	end
	assign	empty_sync = ~almost_empty_flag[1] & almost_empty_flag[0];
	
	// FIFO 写数据
	reg			wr_en;						// 时序语句中阻塞赋值必须使用寄存器类型
	reg[7:0]	wr_data;
	reg[1:0]	state;
	reg[3:0]	delay_to_hold;
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin	
			wr_en <= 1'b0;
			wr_data <= 8'd0;
			state <= 2'd0;
			delay_to_hold <= 4'd0;
		end
		else begin							// 有限状态机可以通过顺次状态跳转执行串行结构语句
			case (state)
			2'd0: begin
				if(empty_sync)	state <= 2'd1;
				else	state <= 2'd0;
			end
			2'd1: begin						// 延时，等待保持时间
				if(delay_to_hold == 4'd10) begin
					delay_to_hold <= 4'd0;
					state <= 2'd2;
				end
				else begin
					delay_to_hold <= delay_to_hold + 1'b1;
					state <= 2'd1;
				end
			end
			2'd2: begin
				if(!fifo_almost_full) begin	// 检查是否写满
					wr_en <= 1'b1;			// 未写满 写使能打开 写入数据
					wr_data <= {4'h0, delay_to_hold};
					state <= 2'd2;			// 状态不改变 重新检查是否写满
				end
				else begin					// 已经写满 写使能关闭 数据清除
					wr_en <= 1'b0;
					wr_data <= 8'h00;
					state <= 2'b0;
				end
			end
			default:
				state <= 2'd0;
		endcase
		end
	end
	assign fifo_wr_en = wr_en;
	assign fifo_wr_data = wr_data;
	
endmodule
