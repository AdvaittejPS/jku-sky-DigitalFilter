`timescale 1ns / 1ns

`include "df_fulladder.v"
`include "df_approx_fulladder.v"

module df_approx_fulladder_tb;
	reg a, b, ci;
	
	wire s_approx, co_approx;
	wire s_exact, co_exact;
	
	// Instantiate the exact full adder for baseline
	df_fulladder dut_exact(a, b, ci, s_exact, co_exact);
	
	// Instantiate the approximate full adder
	df_approx_fulladder dut_approx(a, b, ci, s_approx, co_approx);
	
	integer i;
	integer exact_val, approx_val, error_dist;
	integer total_error = 0;
	
	initial begin
		$dumpfile("df_approx_fulladder_tb.vcd");
		$dumpvars;
		
		$display("A B Cin | Cout_ex S_ex | Cout_ap S_ap | Error Dist");
		$display("--------------------------------------------------");
		
		for (i = 0; i < 8; i = i + 1) begin
			{a, b, ci} = i[2:0];
			#5;
			
			exact_val = {co_exact, s_exact};
			approx_val = {co_approx, s_approx};
			
			// Calculate absolute error distance
			if (exact_val > approx_val)
				error_dist = exact_val - approx_val;
			else
				error_dist = approx_val - exact_val;
				
			total_error = total_error + error_dist;
			
			$display("%b %b  %b  |    %b      %b   |    %b      %b   |     %d", 
			         a, b, ci, co_exact, s_exact, co_approx, s_approx, error_dist);
		end
		
		$display("--------------------------------------------------");
		// Since there are 8 combinations, MED is total / 8.0
		$display("Mean Error Distance (MED): %f", total_error / 8.0);
		$finish;
	end
endmodule
