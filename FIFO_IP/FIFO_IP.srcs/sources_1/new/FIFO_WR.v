module FIFO_WR(
	input		clk,
	input		rst_n,
	input		fifo_almost_empty,			// д����ģ�����Ƿ�Ϊ�գ�Ϊ�պ�ʼд������
	input		fifo_almost_full,			// ����Ƿ�д��
	
	output		fifo_wr_en,					// дʹ��
	output[7:0]	fifo_wr_data				// д������
);

	reg[1:0]	almost_empty_flag = 2'b00;	// ץȡalmost_empty������
	wire		empty_sync;					// ��дʱ��ͬ���ź���
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)	almost_empty_flag <= 2'd0;
		else begin
			almost_empty_flag[0] <= fifo_almost_empty;
			almost_empty_flag[1] <= almost_empty_flag[0];
		end
	end
	assign	empty_sync = ~almost_empty_flag[1] & almost_empty_flag[0];
	
	// FIFO д����
	reg			wr_en;						// ʱ�������������ֵ����ʹ�üĴ�������
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
		else begin							// ����״̬������ͨ��˳��״̬��תִ�д��нṹ���
			case (state)
			2'd0: begin
				if(empty_sync)	state <= 2'd1;
				else	state <= 2'd0;
			end
			2'd1: begin						// ��ʱ���ȴ�����ʱ��
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
				if(!fifo_almost_full) begin	// ����Ƿ�д��
					wr_en <= 1'b1;			// δд�� дʹ�ܴ� д������
					wr_data <= {4'h0, delay_to_hold};
					state <= 2'd2;			// ״̬���ı� ���¼���Ƿ�д��
				end
				else begin					// �Ѿ�д�� дʹ�ܹر� �������
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
