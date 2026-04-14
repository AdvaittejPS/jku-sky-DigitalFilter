// Copyright 2026
// Tiny Tapeout Wrapper for Dual-Mode Battery Failure ASIC

`include "df_digital_filter.v"

module tt_um_df_top
	(
	    input  wire [7:0] ui_in,    // Dedicated inputs
    	output wire [7:0] uo_out,   // Dedicated outputs
    	input  wire [7:0] uio_in,   // IOs: Input path
    	output wire [7:0] uio_out,  // IOs: Output path
    	output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    	input  wire       ena,      // always 1 when the design is powered
    	input  wire       clk,      // clock
    	input  wire       rst_n     // reset_n - low to reset
	);
	
	wire trigger_alarm;
	
    // Double-flop synchronizers to prevent metastability on asynchronous external inputs
	reg [7:0] sync_ui_in [0:1];
	reg       sync_mode_sel [0:1];  // Reduced from 4-bits to 1-bit
	
	// Instantiate the updated Digital Filter / Trigger Core
	df_digital_filter digital_filter_inst(
		.CLK(clk),
		.nRST(rst_n),
		.mode_sel(sync_mode_sel[1]),
		.datain(sync_ui_in[1]),
		.trigger_alarm(trigger_alarm)
	);
	
	always @(posedge clk or negedge rst_n) begin
		if (rst_n == 1'b0) begin
			sync_ui_in[0] <= 8'b0;
			sync_ui_in[1] <= 8'b0;
			sync_mode_sel[0] <= 1'b0;
			sync_mode_sel[1] <= 1'b0;
		end else begin
			sync_ui_in[0] <= ui_in;
			sync_ui_in[1] <= sync_ui_in[0];
            
            // Map the physical uio_in[0] pin to the mode_sel input
			sync_mode_sel[0] <= uio_in[0];
			sync_mode_sel[1] <= sync_mode_sel[0];
		end
	end
	
    // ─────────────────────────────────────────────
    // PHYSICAL PIN MAPPING
    // ─────────────────────────────────────────────
    // Map the 1-bit hardware interrupt to the very first output pin (uo_out[0])
	assign uo_out[0] = trigger_alarm;
    
    // Tie the remaining 7 output pins to Ground (0) to prevent floating leakage
    assign uo_out[7:1] = 7'b0000000;
	
    // Bidirectional IOs are unused as outputs, disable them
	assign uio_out[7:0] = 8'b0;
	assign uio_oe = 8'b0000_0000;
	
    // Catch all unused input wires to satisfy the synthesis tool and prevent warnings
	wire _unused = &{uio_in[7:1], ena, 1'b0};

endmodule
