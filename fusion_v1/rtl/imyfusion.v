`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// CONFIDENTIAL and PROPRIETARY software of IMyFusion Electronics Co., Ltd.
// Copyright (c) 2011-2017 IMyFusion Electronics Co., Ltd. (Nanjing) 
// All rights reserved. 
// Engineer: Will Chen
// This copyright notice MUST be reproduced on all authorized copies.
////////////////////////////////////////////////////////////////////////////////
module imyfusion#(
	parameter							PERIOD_X = 864,
	parameter							LUT_W = 3
)
(
	input								pixelclk_is,
	input								reset_is,

	input	[9:0]						YSTART_IM,
	input	[9:0]						XSTART_IM,
	
	input	[9:0]						ycount_im,
	input	[9:0]						xcount_im,
	
	input	[7:0]						ir_data_im,
	input	[7:0]						ccd_data_im,

	input	[3:0]						mode_im,

	output								pixelclk_os,
	
	output	[9:0]						YSTART_OM,
	output	[9:0]						XSTART_OM,
	
	output	[9:0]						ycount_om,
	output	[9:0]						xcount_om,
	
	output	[7:0]						Y_data_om,
	output	[7:0]						U_data_om,
	output	[7:0]						V_data_om
);




	assign pixelclk_os = pixelclk_is;
	wire         						syn_g;
	wire         						valid_g;
	
	wire	[7:0]						ir_data_g;
	wire	[7:0]						ir_data_orgn;
	wire	[7:0]						ll_data_g;
	wire	[7:0]						ll_data_orgn;
	
	gauss_filter_8bit#(
		.PERIOD_X						(PERIOD_X)
	)
	ir_gauss_filter(
        .iclk           				(pixelclk_is),
        .rst_i							(reset_is),
        .isync          				(1'b0),
        .ivalid         				(),
        .idata          				(ir_data_im),
		
        .osync          				(),
        .ovalid         				(),
        .odata_g        				(ir_data_g),
        .odata_y        				(ir_data_orgn)
	);

	gauss_filter_8bit#(
		.PERIOD_X						(PERIOD_X)
	)
	ll_gauss_filter (
        .iclk   						(pixelclk_is), 
        .rst_i							(reset_is),
        .isync  						(1'b0), 
        .ivalid 						(), 
        .idata  						(ccd_data_im), 
                						
        .osync  						(), 
        .ovalid 						(), 
        .odata_g						(ll_data_g), 
        .odata_y						(ll_data_orgn)
	);  
	/*------------------------------------------------------------------------------------*/





	
	wire         						syn_f;
	wire        	 					valid_f;
	wire	[7:0]  						data_f;
	wire	[LUT_W-1:0]					lut;
	fusion#(
		.LUT_W							(LUT_W)
	)
	fusion (
        .iclk           				(pixelclk_is), 
        .rst_i							(reset_is),
        .isync          				(), 
        .ivalid         				(), 
                        				
        .idata_g_o      				(ir_data_g), 
        .idata_y_o      				(ir_data_orgn), 
                        				
        .idata_g_t      				(ll_data_g), 
        .idata_y_t      				(ll_data_orgn), 
                        				
        .osync          				(), 
        .ovalid         				(), 
        .odata          				(data_f),
        .lut_o							(lut)
	);
	
	
	pseudo_color#(
		.LUT_W							(LUT_W)
	)
	pseudo_color(
		.clk_i							(pixelclk_is),
		.rst_i							(reset_is),
		.data_lut_i						({data_f,lut}),
		.y_data_o						(Y_data_om),
		.u_data_o						(U_data_om),
		.v_data_o						(V_data_om)
	);
	
	
endmodule