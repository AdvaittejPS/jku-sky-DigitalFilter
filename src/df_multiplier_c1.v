// Copyright 2026
// Approximate Multiplier C1 for DNN MAC Unit

`include "df_halfadder.v"
`include "df_fulladder.v"
`include "df_approx_fulladder.v"

module df_multiplier_c1
	(
		input wire [1:0] coef,
		input wire [7:0] data,
		output wire [7:0] out
	);
	
	genvar i;
	
	wire [14:5] stage1 [0:2];
	wire [14:5] stage2 [0:1];
	wire [15:5] result;
	wire [15:7] carrys;
	
	assign stage1[0][12:5] = data[7:0];
	assign stage1[1][13:6] = data[7:0] & {8{coef[0]}};
	assign stage1[2][14:7] = data[7:0] & {8{coef[1]}};
	
	assign stage2[0][6:5] = stage1[0][6:5];
	assign stage2[1][6] = stage1[1][6];
	assign stage2[1][7] = stage1[2][7];
    
	df_halfadder s2v7(stage1[0][7], stage1[1][7], stage2[0][7], stage2[1][8]);
    
	generate
	// APPROXIMATE STAGE: Lower significance bits (8-9)
	for (i = 8; i <= 9; i = i + 1) begin : gens2_approx
		df_approx_fulladder s2f_approx(stage1[0][i], stage1[1][i], stage1[2][i], stage2[0][i], stage2[1][i+1]);
	end
	// EXACT STAGE: Higher significance bits (10-12)
	for (i = 10; i <= 12; i = i + 1) begin : gens2_exact
		df_fulladder s2f_exact(stage1[0][i], stage1[1][i], stage1[2][i], stage2[0][i], stage2[1][i+1]);
	end
	endgenerate
    
	df_halfadder s2v13(stage1[1][13], stage1[2][13], stage2[0][13], stage2[1][14]);
	assign stage2[0][14] = stage1[2][14];
	
	assign result[5] = stage2[0][5];
	df_halfadder resv6(stage2[0][6], stage2[1][6], result[6], carrys[7]);
    
	generate
	// APPROXIMATE STAGE: Lower significance bits (7-9)
	for (i = 7; i <= 9; i = i + 1) begin : genres_approx
		df_approx_fulladder resf_approx(stage2[0][i], stage2[1][i], carrys[i], result[i], carrys[i+1]);
	end
	// EXACT STAGE: Higher significance bits (10-14)
	for (i = 10; i <= 14; i = i + 1) begin : genres_exact
		df_fulladder resf_exact(stage2[0][i], stage2[1][i], carrys[i], result[i], carrys[i+1]);
	end
	endgenerate
    
	assign result[15] = carrys[15];
	assign out = result[15:8];
	
	wire _unused = &{result[7:5]};
endmodule
