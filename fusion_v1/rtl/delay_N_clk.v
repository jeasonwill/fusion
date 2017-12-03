`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:38:18 04/25/2017 
// Design Name: 
// Module Name:    delay_N_clk 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module delay_N_clk #(   
	parameter  							Delay_N         =  10,
	parameter  							DATA_WIDTH      =  8  
)
(
	input                        		iclk,
	input								rst_i,
	input	[DATA_WIDTH-1:0]     		i,
	output	[DATA_WIDTH-1:0]     		o
                );
/*------------------------------------------------------------------------------------*/
	genvar j;
	generate 
		if(Delay_N == 0) begin
			assign o = i;
		end
		else if(Delay_N == 1) begin
			reg [DATA_WIDTH-1:0] data;
			always @(posedge iclk) begin
				if(rst_i) begin
					data <=0;
				end
				else begin
					data <=i;
				end
			end
			assign o = data;
		end
		else begin
			reg	[Delay_N*DATA_WIDTH-1:0] data;
			always @ ( posedge iclk ) begin
				data <= {data[(Delay_N-1)*(DATA_WIDTH-1):0],i};
			end

			
			assign o = data[Delay_N*DATA_WIDTH-1:(Delay_N-1)*DATA_WIDTH];	
		end
		
//		else if(Delay_N >= 2) begin
//			generate 
//				for(j=0;j<DATA_WIDTH;j=j+1) begin:A
//					reg [Delay_N -1 : 0] data;
//					always @(posedge iclk) begin
//						if(rst_i) begin
//							data[Delay_N -1 : 0] <=0;
//						end
//						else begin
//							data[Delay_N -1 : 0] <={data[Delay_N -2 : 0],i[j]};
//						end
//					end
//					assign o[j] = data[Delay_N -1];
//				end
//			endgenerate
//		end
	endgenerate
	
	/*------------------------------------------------------------------------------------*/
endmodule
