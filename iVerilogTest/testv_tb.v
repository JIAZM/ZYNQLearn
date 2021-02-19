module testv_tb();

	reg count_clk;
	reg rst;

	wire io_tb;
	wire clk_tb;
	wire rstn_tb;

	initial begin
		count_clk = 1'b0;
		rst = 1'b0;
		#10 count_clk = 1'b1;
		#10 rst = 1'b1;
		#10
		repeat(10000)
			#1 count_clk = ~count_clk;
	end

	/* 什么意思 */
	initial begin
		$dumpfile("testv.lxt");
		$dumpvars(0,testv_tb);
	end


	//always #1 count_clk = ~count_clk;

	assign clk_tb = count_clk;
	assign rstn_tb = rst;

	testv test(clk_tb,rstn_tb,io_tb);


endmodule
