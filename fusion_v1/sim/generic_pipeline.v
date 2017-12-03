////////////////////////////////////////////////////////////////////////////////
// CONFIDENTIAL and PROPRIETARY software of Magewell Electronics Co., Ltd.
// Copyright (c) 2011-2016 Magewell Electronics Co., Ltd. (Nanjing) 
// All rights reserved.
// This copyright notice MUST be reproduced on all authorized copies.
////////////////////////////////////////////////////////////////////////////////

module generic_pipeline(
		clk_i, 
		reset_an_i, 
		
		reset_i,		
		stall_i,
		
		data_i,		
		data_o
	);

	////////////////////////////////////////////////////////////////////////////
	// Parameters
	
	parameter 					DATA_W 		= 8;
	parameter					DEPTH		= 1;
	parameter [DATA_W-1:0]		RESET_VALUE	= {DATA_W{1'b0}};
	
	////////////////////////////////////////////////////////////////////////////
	// Interface
	
	input						clk_i;
	input						reset_an_i;
	
	input						reset_i;
	input						stall_i;
	
	input [DATA_W - 1:0]		data_i;
	output [DATA_W - 1:0]		data_o;
	
	////////////////////////////////////////////////////////////////////////////
	// Implementation
	genvar						i;
	
	generate		
		if (DEPTH == 0) begin
			assign data_o = data_i;
		end 
		else begin
			reg [DATA_W-1:0] 	stage[0:DEPTH-1];
			
			for (i = 0; i < DEPTH; i = i+1 ) begin: loop
				always @ (posedge clk_i or negedge reset_an_i) begin
					if (~reset_an_i)
						stage[i] <= RESET_VALUE;
					else if (reset_i)
						stage[i] <= RESET_VALUE;
					else if (~stall_i)
						stage[i] <= (i == (DEPTH-1)) ? data_i : stage[i+1];
				end
			end
			
			assign data_o = stage[0];
		end
	endgenerate
	
endmodule
