`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// CONFIDENTIAL and PROPRIETARY software of IMyFusion Electronics Co., Ltd.
// Copyright (c) 2011-2017 IMyFusion Electronics Co., Ltd. (Nanjing) 
// All rights reserved. 
// Engineer: Will Chen
// This copyright notice MUST be reproduced on all authorized copies.
////////////////////////////////////////////////////////////////////////////////
module pseudo_color(
	clk_i,
	rst_i,
	
	data_lut_i,
	
	y_data_o,
	u_data_o,
	v_data_o
);
	////////////////////////////////////////////////////////////////////////////
	// Parameters
	parameter							PIXEL_DATA_W	= 8;
	parameter							Y_DATA_W		= 8;
	parameter							U_DATA_W		= 8;
	parameter							V_DATA_W		= 8;
	parameter							DETAIL_LUT_W	= 3;
	
	localparam							DATA_LUT_W		= PIXEL_DATA_W+DETAIL_LUT_W;
	localparam							YUV_DATA_W		= Y_DATA_W+U_DATA_W+V_DATA_W;
	
	////////////////////////////////////////////////////////////////////////////
	// Interface
	input								clk_i;
	input								rst_i;
	input	[DATA_LUT_W-1:0]			data_lut_i;
	
	output	[Y_DATA_W-1:0]				y_data_o;
	output	[U_DATA_W-1:0]				u_data_o;
	output	[V_DATA_W-1:0]				v_data_o;
	
	
	
	////////////////////////////////////////////////////////////////////////////
	// Implementation
	
	
	reg [YUV_DATA_W-1:0] ram_gray2yuv[0:(1<<DATA_LUT_W)-1] /* synthesis syn_romstyle = "block_rom" */;
	initial begin
//		$readmemh("E:/rtl/fusion_3_3/ram_gray2yuv.txt",ram_gray2yuv);
		$readmemh("E:\rtl\fusion_3_3/ram_gray2yuv.txt",ram_gray2yuv);
	end
	
	
	reg  [YUV_DATA_W-1:0]				yuv_data;
    always@(posedge clk_i) begin
        yuv_data <= ram_gray2yuv[data_lut_i];
    end
    
    
    assign y_data_o = yuv_data[YUV_DATA_W-1:YUV_DATA_W-Y_DATA_W];
	assign u_data_o = yuv_data[YUV_DATA_W-Y_DATA_W-1:V_DATA_W];
	assign v_data_o = yuv_data[V_DATA_W-1:0];
    
    
endmodule