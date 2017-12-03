`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// CONFIDENTIAL and PROPRIETARY software of IMyFusion Electronics Co., Ltd.
// Copyright (c) 2011-2017 IMyFusion Electronics Co., Ltd. (Nanjing) 
// All rights reserved. 
// This copyright notice MUST be reproduced on all authorized copies.
////////////////////////////////////////////////////////////////////////////////
module gauss_filter_8bit#(
	parameter							PERIOD_X = 864

)
(
    input               				iclk,
    input								rst_i,
    input               				isync,
    input               				ivalid,
    input	[7 :0]       				idata,
    output              				osync,
    output              				ovalid,
    output	[7 :0]       				odata_g,
    output	[7 :0]       				odata_y
);

	

/*------------------------------------------------------------------------------------*/
    wire        						ivalid_w = ivalid;
    wire	[7:0] 						idata_w  = idata;
    wire        						ovalid_w;
    wire	[71:0] 						odata_3_3_w;
    wire	[7:0] 						odata_w;
    window_3_3#(
    	.PERIOD_X						(PERIOD_X)
    )
    xilinx_7 (
        .iclk           				(iclk), 
        .rst_i							(rst_i),
        .ivalid         				(ivalid_w), 
        .idata          				(idata_w), 
        .ovalid         				(ovalid_w), 
        .odata_3_3      				(odata_3_3_w), 
        .odata          				(odata_w)
    );
                
/*------------------------------高斯系数部分--------------------------------------------*/
    localparam          				G_WH_G       = 10;
    localparam          				N_G          = 3;
    localparam          				M_G          = 3;                                                
                
	localparam	[G_WH_G*N_G*M_G-1:0]	ig_data_g0 = 	{10'd27, 10'd29, 10'd27
                                           				,10'd29, 10'd32, 10'd29
                                           				,10'd27, 10'd29, 10'd27};//1.3  
                                           				
                                           				
    localparam							G_SUM = 256;//add all above
//    reg [G_WH_G*N_G*M_G-1:0]  ig_data_g0 = {10'd1, 10'd1, 10'd1
//                                           ,10'd1, 10'd1, 10'd1
//                                           ,10'd1, 10'd1, 10'd1};//1.3  
    wire         						isync_g  = isync;
    wire         						ivalid_g = ovalid_w;
    wire [71:0] 						idata_g  = odata_3_3_w;
    
    wire         						osync_g;
    wire         						ovalid_g;
    wire [7:0]  						odata_g_g;
    wire [7:0]  						odata_y_g;
    gauss_filter_8 #(
	    .N								(3),
		.M								(3),       
		.DATAWIDTH						(8),//此处的位宽虽然是用参数表示的，但是因为程序中应用了IP核，IP核的位宽是固定的，所以当修改位宽时需同时修改对应的IP核
		.G_DATAWIDTH					(10),
		.G_SUM       					(G_SUM),//data width = 9  div width = 8
		.G_SUM_W						(8)
    ) 
    xilinx_8 (                                  //delay 29 clk
        .iclk           				(iclk               ),
        .rst_i							(rst_i),
        .isync          				(isync_g            ), 
        .ivalid         				(ivalid_g           ), 
        .idata          				(idata_g            ), 
        .ig_data        				(ig_data_g0         ), 
        .osync          				(osync_g            ), 
        .ovalid         				(ovalid_g           ), 
        .odata_g        				(odata_g_g          ), 
        .odata_y        				(odata_y_g          )
    );
                
	assign  osync   =  osync_g;
	assign  ovalid  =  ovalid_g;
	assign  odata_g =  odata_g_g;
	assign  odata_y =  odata_y_g;

endmodule
