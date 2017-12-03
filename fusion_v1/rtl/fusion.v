`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// CONFIDENTIAL and PROPRIETARY software of IMyFusion Electronics Co., Ltd.
// Copyright (c) 2011-2017 IMyFusion Electronics Co., Ltd. (Nanjing) 
// All rights reserved. 
// This copyright notice MUST be reproduced on all authorized copies.
////////////////////////////////////////////////////////////////////////////////
module fusion#(
	parameter							LUT_W = 3,
	parameter							PIXEL_DATA_W = 8
	
)
(
    input               				iclk,
    input								rst_i,
    input               				isync,
    input               				ivalid,
    input	[7:0]         				idata_g_o,
    input	[7:0]         				idata_y_o,
    
    input	[7:0]         				idata_g_t,
    input	[7:0]         				idata_y_t,
    
    output              				osync,
    output              				ovalid,
    output	[7:0]        				odata,
    output	[LUT_W-1:0]			lut_o
);
/*------------------------------------------------------------------------------*/	
    reg [8:0] detail_o   ,detail_t   ,detail_2;
    reg [7:0] idata_g    ,idata_g_2  ;
    reg [7:0] idata_y_o_1,idata_y_o_2;    
    reg       ivalid_1   ,ivalid_2   ;
    
    always @(posedge iclk) begin
    	if(rst_i) begin
    		detail_o <= 0;
    		detail_t <= 0;
    		detail_2 <= 0;
    		idata_g_2 <= 0;
    		idata_y_o_1 <= 0;
    		idata_y_o_2 <= 0;
    		ivalid_1 <= 0;
    		ivalid_2 <= 0;
    	end
    	else begin
	        detail_o <= {1'b0,idata_y_o[7:0]} - {1'b0,idata_g_o[7:0]};
	        detail_t <= {1'b0,idata_y_t[7:0]} - {1'b0,idata_g_t[7:0]};
//	        detail_2   <= detail_o + detail_t;							//select the max
//	        
//	        if(idata_g_o > idata_g_t)   idata_g <= idata_g_o;			//weight select
//	        else                        idata_g <= idata_g_t;
			
			case({detail_o[PIXEL_DATA_W],detail_t[PIXEL_DATA_W]})
				2'b00: begin
					if(detail_o[PIXEL_DATA_W-1:0]>detail_t[PIXEL_DATA_W-1:0]) begin
						detail_2 <= detail_o;
					end
					else begin
						detail_2 <= detail_t;
					end
				end
				2'b01: begin
					detail_2 <= detail_o;
				end
				2'b10: begin
					detail_2 <= detail_t;
				end
				2'b11: begin
					if(detail_o[PIXEL_DATA_W-1:0]<detail_t[PIXEL_DATA_W-1:0]) begin
						detail_2 <= detail_o;
					end
					else begin
						detail_2 <= detail_t;
					end
				end
				default:;
			endcase
			
			idata_g <= {1'b0,idata_g_o[PIXEL_DATA_W-1:1]}+{1'b0,idata_g_t[PIXEL_DATA_W-1:1]};
			
			
	        idata_g_2 <= idata_g;
	        
	        
	        idata_y_o_1  <=  idata_y_o;
	        idata_y_o_2  <=  idata_y_o_1;
	        
	        ivalid_1     <=  ivalid;
	        ivalid_2     <=  ivalid_1;
	    end
    end
/*---------------�Ƚ�---------------------------------------------------------------*/
	wire        ivalid_b   = ivalid_2;
	wire [7:0]  idata_y_b  = idata_y_o_2;
	wire [7:0]  idata_g_b  = idata_g_2;//idata_y_o_2;
	wire [8:0]  idetail_b  = detail_2;
//                reg [7:0] detail_o_abs_2,detail_t_abs_2;

/*------------------------------------------------------------------------------*/	
//    reg flag = 0;
//    always @(posedge iclk)
//    begin
//        if(ivalid_b)  flag <= ~flag ;
//        else          flag <= 0 ;
//    end
    reg [7:0] data_m;
    reg       valid_m;
    always @ (posedge iclk) begin
    	if(rst_i) begin
    		valid_m <= 0;
    		data_m <= 0;
    	end
    	else begin
        	valid_m <= ivalid_b;
//        if(flag)
            data_m <= idata_g_b + idetail_b[7:0];
//        else
//            data_m <= idata_y_b;
		end
    end

//-------------------detail lut------------------------------
    reg		[LUT_W-1:0]			detail_lut;
    always @ (posedge iclk) begin
    	if(rst_i) begin
    		detail_lut <= 0;
    	end
    	else begin
    		detail_lut <= idetail_b[LUT_W-1:0];
    	end
    end
    
    
//----------------------------------------------------------------    


//-------------------ll_data lut------------------------------
	reg		[LUT_W-1:0]			ll_data_d1;
	reg		[LUT_W-1:0]			ll_data_d2;
	reg		[LUT_W-1:0]			ll_data_d3;
    always @ (posedge iclk) begin
    	if(rst_i) begin
			ll_data_d1 <= 0;
			ll_data_d2 <= 0;
			ll_data_d3 <= 0;
		end
		else begin
			ll_data_d1 <= idata_y_t[PIXEL_DATA_W-1:PIXEL_DATA_W-LUT_W];
			ll_data_d2 <= ll_data_d1;
			ll_data_d3 <= ll_data_d2;
		end
	end

//----------------------------------------------------------------    

	
	assign lut_o = detail_lut;//ll_data_d3
	
	assign osync  = isync;
	assign ovalid = valid_m;
	assign odata  = data_m;

endmodule
