`timescale 1ns / 1ns

module df_multiplier_c2_tb;

	integer i, j;
	integer exact_val, approx_val, error_dist;
	integer total_error = 0;
	
	reg [2:0] coef;
	reg [7:0] data;
	wire [7:0] out;
	
	wire [7:0] c;
	wire [15:0] mul_exact;
	wire [7:0] out_exact;
	
	// Instantiate the Approximate Multiplier
	df_multiplier_c2 dut(coef, data, out);
	
	// Calculate exact expected value for baseline comparison
	assign c = {1'b0, coef[2], 1'b0, coef[1], 1'b1, coef[0], 2'b10};
	assign mul_exact = data * c;
	assign out_exact = mul_exact[15:8]; // Truncate exactly like the hardware
	
	initial begin
		$dumpfile("df_multiplier_c2_tb.vcd");
		$dumpvars;
		
		$display("Running Approximate Multiplier C2 Test...");
		$display("Coef | Data | Exact Out | Approx Out | Error");
		$display("-------------------------------------------------");
		
		for (i = 0; i <= 7; i = i + 1) begin
			for (j = 0; j <= 255; j = j + 1) begin
				coef = i[2:0];
				data = j[7:0];
				#5;
				
				exact_val = out_exact;
				approx_val = out;
				
				// Calculate absolute error distance
				if (exact_val > approx_val)
					error_dist = exact_val - approx_val;
				else
					error_dist = approx_val - exact_val;
					
				total_error = total_error + error_dist;
				
				// Print a sample of the errors
				if (error_dist > 0 && j % 16 == 0)
					$display(" %b |  %3d |    %3d    |     %3d    |   %d", coef, data, exact_val, approx_val, error_dist);
			end
		end
		
		$display("-------------------------------------------------");
		$display("Mean Error Distance (MED) for Multiplier C2: %f", total_error / 2048.0);
		$finish;
	end
endmodule
