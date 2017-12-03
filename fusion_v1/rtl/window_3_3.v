`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// CONFIDENTIAL and PROPRIETARY software of IMyFusion Electronics Co., Ltd.
// Copyright (c) 2011-2017 IMyFusion Electronics Co., Ltd. (Nanjing) 
// All rights reserved. 
// This copyright notice MUST be reproduced on all authorized copies.
////////////////////////////////////////////////////////////////////////////////
module window_3_3(
	input                   			iclk,
	input								rst_i,
	input                   			ivalid,
	input  [7:0]           				idata,
	output                  			ovalid,
	output [71:0]           			odata_3_3,
	output [7:0]           				odata
);

//---------------------------------------------------------------
//	parameter
	parameter							PERIOD_X = 864;
//	parameter							PERIOD_Y = 625;
	

	wire [8 :0] data_33,data_32,data_31;
	wire [8 :0] data_23,data_22,data_21;
	wire [8 :0] data_13,data_12,data_11;
	
	assign  data_33 = {ivalid,idata[7 :0] };

    /*-----------------------------------------------------------------*/
    delay_N_clk #(
	    .Delay_N(PERIOD_X), 
	    .DATA_WIDTH(9)
    )               //delay 1 line
    sxilinx_1 (
    	.iclk(iclk), 
    	.rst_i							(rst_i),
    	.i(data_33), 
    	.o(data_23) 
    );
    delay_N_clk #(
    	.Delay_N(PERIOD_X), 
    	.DATA_WIDTH(9)
    	)               //delay 1 line
    sxilinx_2 (
    	.iclk(iclk), 
    	.rst_i							(rst_i),
    	.i(data_23), 
    	.o(data_13) 
    );

    /*-----------------------------------------------------------------*/
    delay_N_clk #(
    	.Delay_N(1), 
    	.DATA_WIDTH(9)
    )               //delay 2 clk
    sxilinx_3 (
    	.iclk(iclk), 
    	.rst_i							(rst_i),
    	.i(data_33), 
    	.o(data_32) 
    );
    delay_N_clk #(
    	.Delay_N(1), 
    	.DATA_WIDTH(9)
    	)               //delay 2 clk
    sxilinx_4 (
    	.iclk(iclk), 
    	.rst_i							(rst_i),
    	.i(data_23), 
    	.o(data_22) 
    );
    delay_N_clk #(
    	.Delay_N(1), 
    	.DATA_WIDTH(9)
    )               //delay 2 clk
    sxilinx_5 (
    	.iclk(iclk), 
    	.rst_i							(rst_i),
    	.i(data_13), 
    	.o(data_12) 
    );
    /*-----------------------------------------------------------------*/
    delay_N_clk #(
    	.Delay_N(1), 
    	.DATA_WIDTH(9)
    )               //delay 2 clk
    sxilinx_6 (
    	.iclk(iclk), 
    	.rst_i							(rst_i),
    	.i(data_32), 
    	.o(data_31) 
    	);
    delay_N_clk #(
    	.Delay_N(1), 
    	.DATA_WIDTH(9)
    )               //delay 2 clk
    sxilinx_7 (
    	.iclk(iclk), 
    	.rst_i							(rst_i),
    	.i(data_22), 
    	.o(data_21) 
    );
    delay_N_clk #(
    	.Delay_N(1), 
    	.DATA_WIDTH(9)
    )               //delay 2 clk
    sxilinx_8 (
    	.iclk(iclk), 
    	.rst_i							(rst_i),
    	.i(data_12), 
    	.o(data_11) 
    );
                
                
	assign ovalid       = data_22[8];
	assign odata        = data_22[7:0];
	assign odata_3_3    = {data_11[7:0],data_12[7:0],data_13[7:0],data_21[7:0],data_22[7:0],data_23[7:0],data_31[7:0],data_32[7:0],data_33[7:0]};


endmodule
