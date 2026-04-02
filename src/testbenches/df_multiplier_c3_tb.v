`timescale 1ns / 1ns

module df_multiplier_c3_tb;
	
	integer j;
	integer exact_val, approx_val, error_dist;
	integer total_error = 0;
	
	reg [7:0] data;
	wire [7:0] out;
	
	wire [7:0] c;
	wire [15:0] mul_exact;
	wire [7:0] out_exact;
	
	// Instantiate the Approximate Multiplier
	df_multiplier_c3 dut(data, out);
	
	// Calculate exact expected value for baseline comparison
	assign c = 8'b00011011;
	assign mul_exact = data * c;
	assign out_exact = mul_exact[15:8];
	
	initial begin
		$dumpfile("df_multiplier_c3_tb.vcd");
		$dumpvars;
		
		$display("Running Approximate Multiplier C3 Test...");
		$display("Data | Exact Out | Approx Out | Error");
		$display("------------------------------------------");
		
		for (j = 0; j <= 255; j = j + 1) begin
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
			
			// Print errors
			if (error_dist > 0 && j % 16 == 0)
				$display(" %3d |    %3d    |     %3d    |   %d", data, exact_val, approx_val, error_dist);
		end
		
		$display("------------------------------------------");
		$display("Mean Error Distance (MED) for Multiplier C3: %f", total_error / 256.0);
		$finish;
	end
endmodule
