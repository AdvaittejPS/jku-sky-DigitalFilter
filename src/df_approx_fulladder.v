// Copyright 2026
// Approximate Full Adder for DNN MAC Unit

`ifndef __DF_APPROX_FULLADDER__
`define __DF_APPROX_FULLADDER__

module df_approx_fulladder
	(
		input wire a,
		input wire b,
		input wire ci,
		output wire s,
		output wire co
	);
	
	// Inexact Full Adder (IFA) implementation
	// Extremely lightweight: 1 OR gate, 1 AND gate
	// We ignore ci to break the carry chain and save routing
	assign s = a | b;
	assign co = a & b;

endmodule

`endif
