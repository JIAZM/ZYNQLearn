module testv(
	input sysclk,
	input rst_n,

	output io
);
	
	parameter clk = 50000000;
	parameter io_hz = 100000;
	parameter flip_hz = clk / io_hz / 2;

	reg[31:0] count;
	reg io_o;

	always@(posedge sysclk or negedge rst_n) begin
		if(!rst_n)	count <= 32'd0;
		else begin
			if(count == flip_hz)	count <= 32'd0;
			else	count <= count + 1'b1;
		end 
	end

	always@(posedge sysclk or negedge rst_n) begin
		if(!rst_n)	io_o <= 1'b0;
		else begin
			if(count == 32'd0)	io_o <= ~io_o;
			else	io_o <= io_o;
		end
	end

	assign io = io_o;

endmodule
