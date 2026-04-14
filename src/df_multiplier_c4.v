// Copyright 2026
// Event-Driven Dual-Mode ASIC Filter / MAC Unit
// Optimized for Tiny Tapeout 1x1 Tile

module df_digital_filter
(
    input  wire        CLK,
    input  wire        nRST,
    input  wire        mode_sel,      // 0 = Radiography (X-Ray), 1 = Thermal (Ejecta)
    input  wire [7:0]  datain,        // 8-bit unsigned sensor data (0-255)
    output wire        trigger_alarm  // Zero-latency hardware safety interrupt
);

    // ─────────────────────────────────────────────
    // 4-TAP SLIDING WINDOW PIPELINE
    // ─────────────────────────────────────────────
    reg [7:0] val1, val2, val3, val4;

    // EVENT DETECTION: High if any bit in datain is 1 (Sparsity Gating)
    wire event_valid;
    assign event_valid = |datain; 

    always @(posedge CLK or negedge nRST) begin
        if (nRST == 1'b0) begin
            val1 <= 8'b0;
            val2 <= 8'b0;
            val3 <= 8'b0;
            val4 <= 8'b0;
        end else begin
            // Pipeline only shifts when an active event occurs to save power
            if (event_valid) begin
                val4 <= val3;
                val3 <= val2;
                val2 <= val1;
                val1 <= datain;
            end
        end
    end

    // ─────────────────────────────────────────────
    // DUAL-BANK WEIGHT MULTIPLEXER
    // ─────────────────────────────────────────────
    wire signed [8:0] w0, w1, w2, w3;
    wire signed [15:0] threshold;

    // Tap 0 (t-3) - Oldest Frame
    assign w0 = mode_sel ? 9'sd111 :  9'sd69;
    
    // Tap 1 (t-2)
    assign w1 = mode_sel ? 9'sd11  : -9'sd127;
    
    // Tap 2 (t-1)
    assign w2 = mode_sel ? 9'sd127 :  9'sd63;
    
    // Tap 3 (t-0) - Current Frame
    assign w3 = mode_sel ? 9'sd99  : -9'sd118;

    // Trigger Thresholds
    // Radiography looks for spike out of deep negative sums (> -12000)
    // Thermal looks for an accumulation of heat (> 97)
    assign threshold = mode_sel ? 16'sd97 : -16'sd12000;

    // ─────────────────────────────────────────────
    // MULTIPLY-ACCUMULATE (MAC) UNIT
    // ─────────────────────────────────────────────
    // Cast unsigned 8-bit pipeline values to 9-bit signed for mixed arithmetic
    wire signed [8:0] s_val1 = {1'b0, val1};
    wire signed [8:0] s_val2 = {1'b0, val2};
    wire signed [8:0] s_val3 = {1'b0, val3};
    wire signed [8:0] s_val4 = {1'b0, val4};

    // 18-bit products prevent overflow (9-bit * 9-bit = 18-bit max)
    wire signed [17:0] p0, p1, p2, p3; 

    // OpenLane/Yosys will synthesize these into optimal constant shift-and-add trees
    assign p0 = s_val4 * w0; // t-3
    assign p1 = s_val3 * w1; // t-2
    assign p2 = s_val2 * w2; // t-1
    assign p3 = s_val1 * w3; // t-0 (current)

    // Combinatorial accumulator (Zero-Latency)
    wire signed [17:0] fir_sum;
    assign fir_sum = p0 + p1 + p2 + p3;

    // ─────────────────────────────────────────────
    // DIGITAL COMPARATOR / TRIGGER
    // ─────────────────────────────────────────────
    // If accumulated signature exceeds the AI-calculated threshold, pull the pin high
    assign trigger_alarm = (fir_sum > threshold);

endmodule
