/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */
module moduletopproject(
	   input  clk,
	   input  rst,
           input  left_up,
           input  left_down,
           input  right_up,
           input  right_down,
           input  score_reset,
           input  speed_lsb,
           input  speed_msb,
	   output r0,
	   output r1,
	   output r2,
	   output r3,
	   output g0,
	   output g1,
	   output g2,
	   output g3,
	   output b0,
	   output b1,
	   output b2,
	   output b3,
	   output hs,
	   output vs
	   );

`default_nettype none

	module tt_um_WillyJules_chipbootcamp (
	    input  wire [7:0] ui_in,    // Dedicated inputs
	    output wire [7:0] uo_out,   // Dedicated outputs
	    input  wire [7:0] uio_in,   // IOs: Input path
	    output wire [7:0] uio_out,  // IOs: Output path
	    output wire [7:0] uio_oe,   // IOs: Enable path (0=input, 1=output)
	    input  wire       ena,      // always 1 when powered
	    input  wire       clk,      // clock
	    input  wire       rst_n     // reset_n - low to reset
	);
	
	    // Extract coordinates from input ports
	    wire [3:0] x1_in = ui_in[3:0];
	    wire [3:0] y1_in = ui_in[7:4];
	    wire [3:0] x2_in = uio_in[3:0];
	    wire [3:0] y2_in = uio_in[7:4];
	
	    // Internal registers
	    reg signed [7:0] dx, dy, slope_error;
		reg [3:0] x, y;
		reg signed [3:0] x_step, y_step;
		
	    // Calculate differences (combinational)
	    always @(*) begin
			x_step = (x2_in > x1_in) ? 1 : -1;
    		y_step = (y2_in > y1_in) ? 1 : -1;
	        dx = x2_in - x1_in;
	        dy = (y2_in - y1_in) <<< 1;   // dy = 2 * (y2 - y1)
	    end
	
		// Clocked state machine
    	always @(posedge clk or negedge rst_n) begin
        	if (!rst_n) begin
            	x <= x1_in;
            	y <= y1_in;
            	slope_error <= dy - dx;
        	end else begin
            	// Horizontal / diagonal line
            	if (dx != 0 && ((x_step > 0 && x < x2_in) || (x_step < 0 && x > x2_in))) begin
                	x <= x + x_step;
                	slope_error <= slope_error + dy;
                	if ((x_step > 0 && slope_error > 0) || (x_step < 0 && slope_error < 0)) begin
                    	y <= y + y_step;
                    	slope_error <= slope_error - (dx <<< 1);
                	end
            	end
            	// Vertical line
            	else if (dx == 0 && ((y_step > 0 && y < y2_in) || (y_step < 0 && y > y2_in))) begin
                	y <= y + y_step;
            	end
        	end
    	end
	    // Outputs: show current x and y position
	    assign uo_out  = {4'b0000, x};
	    assign uio_out = {4'b0000, y};
	    assign uio_oe  = 8'b00000000;  // All IOs are inputs
	
	    // Prevent unused warnings
	    wire _unused = &{ena, 1'b0};
	
	endmodule
