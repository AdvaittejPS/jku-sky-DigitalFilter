`timescale 1ns / 1ps

module df_digital_filter_sparse_tb;
	
	parameter clk_period = 20;
	
	reg clk = 1'b0;
	reg rst_n = 1'b0;
	
	reg [7:0] ui_in;
	reg [3:0] uio_in;
	wire [7:0] uo_out;
	
	df_digital_filter df_top(
		.CLK(clk),
		.nRST(rst_n),
		.enconfig(uio_in[3]),
		.configin(uio_in[2:0]),
		.datain(ui_in),
		.dataout(uo_out)
	);
	
	always #(clk_period/2) clk = ~clk;
	
	initial begin
		$dumpfile("df_digital_filter_sparse_tb.vcd");
		$dumpvars;
		
		rst_n = 1'b0;
		ui_in = 8'b0;
		uio_in = 4'b0;
		#(5 * clk_period);
		
		rst_n = 1'b1;
		
		// Configure filter (Lowpass, wg_0125)
		uio_in[3] = 1'b1; // enconfig
		uio_in[2:0] = 3'b000; 
		#(clk_period);
		uio_in[3] = 1'b0;
		
		$display("Time | Data In | Data Out | Event Valid");
		$display("---------------------------------------");
		
		// Inject a sequence with deliberate sparsity (0s)
		send_data(8'd10);
		send_data(8'd20);
		send_data(8'd0);  // Pipeline should freeze!
		send_data(8'd0);  // Pipeline should freeze!
		send_data(8'd30);
		send_data(8'd40);
		send_data(8'd0);  // Pipeline should freeze!
		send_data(8'd50);
		
		#(5 * clk_period);
		$finish;
	end
	
	task send_data(input [7:0] data);
	begin
		ui_in = data;
		#(clk_period);
		$display("%4t |   %3d   |   %3d    |     %b", $time, ui_in, uo_out, |ui_in);
	end
	endtask

endmodule
