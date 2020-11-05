module FIFO_RD(
	input		clk,
	input		rst_n,
	input		fifo_almost_empty,
	input		fifo_almost_full,
	input[7:0]	fifo_rd_data,
	
	output		fifo_rd_en,
	output[7:0]	data
);
	
	parameter	IDLE		= 2'b00;
	parameter	CAP_FULL_UP = 2'b01;
	parameter	CNT_BEGIN	= 2'b10;

	reg[1:0]	almost_full_flag = 2'b00;	// 抓取almost_empty上升沿
	wire		full_sync;					// 读写时钟同步信号线
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)	almost_full_flag <= 2'b00;
		else begin
			almost_full_flag[0] <= fifo_almost_full;
			almost_full_flag[1] <= almost_full_flag[0];
		end
	end
	assign	full_sync = (~almost_full_flag[1]) & almost_full_flag[0];
	
	// FIFO 读数据
	reg			rd_en;		// 时序语句中阻塞赋值必须使用寄存器类型
	reg[7:0]	rd_data;
	reg[1:0]	state;
	reg[3:0]	delay_to_hold;
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			rd_en <= 1'b0;
			state <= IDLE;
			delay_to_hold <= 4'd0;
		end
		else begin			// 有限状态机可以通过顺次状态跳转执行串行结构语句
			case (state)
			IDLE: begin
				if(full_sync)	state <= CAP_FULL_UP;
				else	state <= IDLE;
			end
			CAP_FULL_UP: begin		// 延时，等待保持时间
				if(delay_to_hold >= 4'd10) begin
					delay_to_hold <= 4'd0;
					state <= CNT_BEGIN;
				end
				else begin
					delay_to_hold <= delay_to_hold + 1'b1;
					state <= 2'd1;
				end
			end
			CNT_BEGIN: begin
				if(!fifo_almost_empty) begin
					rd_en <= 1'b1;
					rd_data <= fifo_rd_data;
					state <= CNT_BEGIN;
				end
				else begin
					rd_en <= 1'b0;
					state <= IDLE;
				end
			end
			default:	state <= IDLE;
		endcase
		end
	end
	
	assign fifo_rd_en = rd_en;
	assign	data = rd_data;
endmodule
