`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// CONFIDENTIAL and PROPRIETARY software of IMyFusion Electronics Co., Ltd.
// Copyright (c) 2011-2017 IMyFusion Electronics Co., Ltd. (Nanjing) 
// All rights reserved. 
// This copyright notice MUST be reproduced on all authorized copies.
////////////////////////////////////////////////////////////////////////////////
module gauss_filter_8#(
	parameter							N           = 3,
	parameter							M           = 3,       
	parameter							DATAWIDTH   = 8,//�˴���λ����Ȼ���ò�����ʾ�ģ�������Ϊ������Ӧ����IP�ˣ�IP�˵�λ���ǹ̶��ģ����Ե��޸�λ��ʱ��ͬʱ�޸Ķ�Ӧ��IP��
	parameter							G_DATAWIDTH = 10,
	parameter							G_SUM       = 256,//data width = 9  div width = 8
	parameter							G_SUM_W		= 8
	
    )
    (
	input								iclk,
	input								rst_i,
	input								isync,
	input								ivalid,
	input	[DATAWIDTH*N*M-1:0]			idata,
	
	input	[G_DATAWIDTH*M*N-1:0]		ig_data,
	
	output								osync,
	output								ovalid,
	output	[DATAWIDTH-1:0]				odata_g,
	output	[DATAWIDTH-1:0]				odata_y 
);

	genvar								j;
	genvar								i;
/*-----------------------��һ��������������idata��ig_data�ֽ��� M*N ����--------------------------------------------------*/                
	generate
		for(i=0;i<N;i=i+1) begin:AN
			for(j=0;j<M;j=j+1) begin:AM
		    	wire	[G_DATAWIDTH-1:0]	g = ig_data[((i*M+j+1)*G_DATAWIDTH-1):((i*M+j)*G_DATAWIDTH)];     //����N��M�еľ������ţ�һ��Ϊһ����λ
		    	wire	[DATAWIDTH-1:0]		h =	idata[((i*M+j+1)*DATAWIDTH-1):((i*M+j)*DATAWIDTH)];//����N��M�еľ������ţ�һ��Ϊһ����λ
			end
		end
	endgenerate
	
	/*-------------------M*N���� ���м����Լ�valid------------------------------*/
	wire	[DATAWIDTH-1:0]				i_data = AN[(N-1)/2].AM[(M-1)/2].h; 
	wire								i_valid = ivalid;

/*--------------------��һ��end���õ��� ���� i �� �������� g---------------------------------------------------------*/
/*--------------------�ڶ�����data_d =  g .* i-------------------------------------------------------------------*/

	generate
		for(i=0;i<N;i=i+1) begin:FN
    		for(j=0;j<M;j=j+1) begin:FM
				wire   [DATAWIDTH + G_DATAWIDTH  - 1 : 0]   data_d;
//                        mult_10_8 TXILINX_mult0 (                           // delay 3 clk
//                              .clk  (iclk           ),                // input clk
//                              .a    (AN[i].AM[j].g  ),                // input [9 : 0] a
//                              .b    (AN[i].AM[j].h  ),                // input [7 : 0] b
//                              .p    (data_d         )                 // output [17 : 0] p
//                           );
				multiplier#(     // delay 3 clk
					.A_WIDTH			(10),
					.B_WIDTH			(8)
	    		)
	    		multiplier(
	                .clk_i				(iclk),
	                .reset_an_i			(1'b1),
	         		.reset_i			(rst_i),
	                .stall_i			(1'b0),//0
	            	.data_a_i			(AN[i].AM[j].g),
	            	.data_b_i			(AN[i].AM[j].h),
	            	.data_p_o			(data_d)
	    		);
         	end
      	end
   	endgenerate


/*------------------��2��end���õ��˲����ľ���ֵ data_d-------------------------------------------------------------*/
/*------------------���������ۼ� data_d ���˴�������ӦN= 3��M= 3 ������������������һ�����ã�---------------------------------*/ 
/*---------------��3.1���չΪ4*4--------------------------------*/
	generate
		for(i=0;i<N+1;i=i+1) begin:GN
			for(j=0;j<M+1;j=j+1) begin:GM
            	wire	[DATAWIDTH+G_DATAWIDTH-1:0]		data_d;
         	end
      	end
   	endgenerate
   
   	generate
      	for(i=0;i<N;i=i+1) begin:AA
         	for(j=0;j<M;j=j+1) begin:BB
            	assign	GN[i].GM[j].data_d = FN[i].FM[j].data_d;
         	end
      	end
   	endgenerate
   
   
   	generate
      	for(i=N;i<N+1;i=i+1) begin:CC
         	for(j=0;j<M;j=j+1) begin:DD
            	assign     GN[i].GM[j].data_d   =  0;
         	end
      	end
   	endgenerate
   	
   generate
      for(i=0;i<N+1;i=i+1)
      begin:EE
         for(j=M;j<M+1;j=j+1)
         begin:FF
            assign     GN[i].GM[j].data_d   =  0;
         end
      end
   endgenerate
/*---------------��3.2���ۼ�--------------------------------*/
/*----------��˹ϵ��������һ���ſ��ܴﵽG_DATAWIDTH + 1λ������k��λ��ֻҪ��ԭ������ϼ�1λ�Ϳ�����,data_d��λ��ԭ����k��ͬ*/
/*------4*4---> 2*2����----------------------------------------------------------------------------*/
	generate
      	for(i=0;i <(N+1);i=i+1) begin:HN
         	for(j=0;j<(M+1)/2;j=j+1) begin:HM
            	reg		[DATAWIDTH+G_DATAWIDTH-1+1:0]		data_d;
            	always@(posedge iclk) begin
            		if(rst_i) data_d <= 0;
               		else data_d <= GN[i].GM[j].data_d + GN[i].GM[(M+1)/1-j-1].data_d;
            	end 
         	end
      	end      
   	endgenerate

   	generate
      	for(i=0;i<(N+1)/2;i=i+1) begin:IN
         	for(j=0;j<(M+1)/2;j=j+1) begin:IM
            	reg		[DATAWIDTH+G_DATAWIDTH-1+1:0]		data_d;
            	always@(posedge iclk) begin
            		if(rst_i) data_d <= 0;
               		else data_d <= HN[i].HM[j].data_d + HN[(N+1)/1-i-1].HM[j].data_d;
            	end 
         	end
      	end
   	endgenerate

/*------2*2---> 1*1����----------------------------------------------------------------------------*/
   	generate
      	for(i=0;i<(N+1)/2;i=i+1) begin:JN
         	for(j=0;j<(M+1)/4;j=j+1) begin:JM
            	reg    [DATAWIDTH + G_DATAWIDTH  - 1 +1: 0]      data_d;
            	always@(posedge iclk) begin
               		if(rst_i) data_d <= 0;
               		else data_d  <=  IN[i].IM[j].data_d  + IN[i].IM[ (M+1)/2-j-1].data_d;
            	end 
         	end
     	end
   	endgenerate

   	generate
      	for(i=0;i<(N+1)/4;i=i+1) begin:KN
         	for(j=0;j<(M+1)/4;j=j+1) begin:KM
            	reg    [DATAWIDTH + G_DATAWIDTH  - 1 + 1: 0]   data_d;
            	always@(posedge iclk) begin
               		if(rst_i) data_d <= 0;
               		else data_d  <=  JN[i].JM[j].data_d  + JN[(N+1)/2-i-1].JM[j].data_d;
            	end 
        	end
      	end      
   	endgenerate

/*---------������end�� �õ� KN[0].KM[0].k,KN[0].KM[0].data_d ,data_d ������ k �ӳ���4��ʱ��---------------------------*/
/*---------���Ĳ��� odata = data_d_sum /k_sum--------------------------*/
   	wire	[DATAWIDTH+G_DATAWIDTH-1+1:0]			data_d_sum = KN[0].KM[0].data_d;

//   	wire [18:0]             quotient;
	reg		[18:0]						quotient;
   	wire	[DATAWIDTH-1:0]				quotient_data;
//   	division_19_10 TXILINX_div0 (		//delay 21 clk
//		.clk           (iclk),			// input clk
//		.rfd           (),				// output rfd
//		.dividend      (data_d_sum),	// input  [18 : 0] dividend
//		.divisor       (G_SUM),			// input  [9  : 0] divisor 
//		.quotient      (quotient),		// output [18 : 0] quotient
//		.fractional    ()				// output [9  : 0] fractional
//	);
	always@(posedge iclk) begin
		if(rst_i) quotient <= 0;
        else quotient <= data_d_sum[DATAWIDTH+G_DATAWIDTH-1+1:G_SUM_W];//delay 1 clk
	end


	
   	assign quotient_data = quotient[DATAWIDTH - 1 : 0];
/*---------���岽��ʱ������---3+4+21 = 28��ʱ�ӣ�i��i_valid ������quotient_data,Ҫ�ӳ�28��clk�ſ��Զ���---------------------------------------------------*/        
//----------------------------3+4+1 = 8
	wire    [DATAWIDTH : 0]       i_and_ivalid = {i_data[DATAWIDTH - 1:0],i_valid};
	wire    [DATAWIDTH : 0]       i_and_ivalid_1;
   
    delay_N_clk #(
    	.Delay_N(8/*28*/), 
    	.DATA_WIDTH(9)
    )               //delay 28 clk
    sxilinx_3 (
    	.iclk(iclk), 
    	.rst_i(rst_i),
    	.i(i_and_ivalid), 
    	.o(i_and_ivalid_1) 
    );
   

/*-------------�����������մ������������Լ�ԭʼ�����Լ���Ч�ź�(�Դ˴�Ϊ�ֽ��ߣ�����Ϊ�źŴ����֣������ɣ�����Ϊͼ�����ش���)---------------------------*/
	wire	[DATAWIDTH-1:0]				data_m		= quotient_data[DATAWIDTH-1:0];
	wire								valid_m		= i_and_ivalid_1[0];
	wire	[DATAWIDTH-1:0]				data_y_m	= i_and_ivalid_1[DATAWIDTH:1];
	
	/*---��ȡϸ��----------------------------------------*/
	reg    [DATAWIDTH-1 : 0]   data_n;
	reg    [DATAWIDTH-1 : 0]   data_y_n;
	reg                        valid_n;
	always@(posedge iclk) begin //delay 1 clk
		if(rst_i) begin
			valid_n <= 0;
			data_y_n <= 0;
			data_n <= 0;
		end
        else begin
			valid_n    <=  valid_m;
			data_y_n   <=  data_y_m;
			data_n     <=  data_m[DATAWIDTH-1:0];//{1'b0,data_y_m[DATAWIDTH-1:0]} - {1'b0,data_m[DATAWIDTH-1:0]};
		end
	end 
	/*-----------------------------------------------------------------------------------------------------*/
	assign odata_g    = data_n;
	assign odata_y    = data_y_n;
	assign ovalid     = valid_n;
	assign osync      = isync;


///*-------------------------------------------------------------------------------------------------------*/
//                wire [35:0] CONTROL0;
//                icon_test YourInstanceName1 (
//                    .CONTROL0(CONTROL0) // INOUT BUS [35:0]
//                );
//                ila_test YourInstanceName2 (
//                    .CONTROL(CONTROL0),      // INOUT BUS [35:0]
//                    .CLK(iclk),              // IN
//                    .TRIG0(ivalid       ),   // IN BUS [0:0]
//                    .TRIG1(idata[71:64] ),   // IN BUS [0:0]
//                    .TRIG2(idata[63:56] ),   // IN BUS [0:0]
//                    .TRIG3(idata[55:48] ),   // IN BUS [0:0]
//                    .TRIG4(idata[47:40] ),   // IN BUS [0:0]
//                    .TRIG5(idata[39:32] ),   // IN BUS [0:0]
//                    .TRIG6(idata[31:24] ),   // IN BUS [0:0]
//                    .TRIG7(idata[23:16] ),   // IN BUS [0:0]
//                    .TRIG8(idata[15:8 ] ),   // IN BUS [0:0]
//                    .TRIG9(idata[7 :0 ] ),   // IN BUS [0:0]
//                    
//                    .TRIG10(valid_m     ),   // IN BUS [0:0]
//                    .TRIG11(data_m      ),   // IN BUS [0:0]
//                    .TRIG12(data_y_m    )    // IN BUS [0:0]
//                );





endmodule
////-------------------------------��˹ϵ������---------------------------------------
//                localparam          G_WH_G       =   10;    
//                localparam          N_G          =   3;
//                localparam          M_G          =   3;                                                
//                reg gauss_on = 1;
//                always @(posedge iclk )
//                begin
//                    if((addr_parameter[15:0] == 16'h001C))
//                          gauss_on      <= data_parameter[0];
//                     else gauss_on      <= gauss_on;
//                end                                                   
//                reg [9:0] ratio_g = 10'd128;
//                always @(posedge iclk )
//                begin
//                    if((addr_parameter[15:0] == 16'h001D)||(addr_parameter[15:0] == 16'h001E))
//                          ratio_g      <= data_parameter[9:0];
//                     else ratio_g      <= ratio_g;
//                end                                                                                                   
//                reg [G_WH_G*N_G*M_G-1:0]  ig_data_g0 = {   10'd5,  10'd7,  10'd5
//                                                   ,10'd22, 10'd30, 10'd22
//                                                   ,10'd54, 10'd73, 10'd54
//                                                   ,10'd73, 10'd98, 10'd73
//                                                   ,10'd54, 10'd73, 10'd54
//                                                   ,10'd22, 10'd30, 10'd22
//                                                   ,10'd5,  10'd7,  10'd5  };//1.3  
//                 generate
//                     for(i=0;i<N_G;i=i+1)
//                     begin:BN
//                     for(j=0;j<M_G;j=j+1)
//                         begin:BM
//                          always@(posedge iclk)  //delay 1 clk
//                             begin
//                                 if(addr_parameter[15:0] == (i*M_G+j + 16'h0200))
//                                     ig_data_g0[(i*M_G+j+1)*G_WH_G - 1:(i*M_G+j)*G_WH_G] <= data_parameter[G_WH_G-1:0];
//                                 else
//                                     ig_data_g0[(i*M_G+j+1)*G_WH_G - 1:(i*M_G+j)*G_WH_G] <= ig_data_g0[(i*M_G+j+1)*G_WH_G - 1:(i*M_G+j)*G_WH_G];
//                             end
//                         end
//                     end
//                 endgenerate  