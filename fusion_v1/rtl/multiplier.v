`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// CONFIDENTIAL and PROPRIETARY software of IMyFusion Electronics Co., Ltd.
// Copyright (c) 2011-2017 IMyFusion Electronics Co., Ltd. (Nanjing) 
// All rights reserved. 
// Engineer: ykf
// This copyright notice MUST be reproduced on all authorized copies.
////////////////////////////////////////////////////////////////////////////////
// Description: �˷��������Сλ��ȷ���ӳ�ʱ������������Сλ��Ϊ32λ��0-31��������λ�����ƿɱ�ʾ0��31�������ӳ�ʱ����Ϊ5��(round_up(log2(MIN_WIDTH - 1))).
//              ���⣺MIN_WIDTHΪ1ʱ���������ӳ�ʱ����Ϊ0������ｫ���������ã�Ϊ1��ʱ���ӳ١�
//////////////////////////////////////////////////////////////////////////////////
module multiplier#(     
	parameter                       A_WIDTH = 4,
    parameter                       B_WIDTH = 2
)
(
    input                           clk_i       ,
    input                           reset_an_i  ,
    input                           reset_i     ,
    input                           stall_i     ,//0
    input [A_WIDTH - 1:0]           data_a_i    ,
    input [B_WIDTH - 1:0]           data_b_i    ,
    output[A_WIDTH+B_WIDTH - 1:0]   data_p_o
);
    function integer next_pow2;
    input integer in;
    begin
        next_pow2 = 32'd1;
        while (next_pow2 < in)
            next_pow2 = next_pow2 << 1;
    end
endfunction

function integer clog2;
	input integer value;
	begin
		for (clog2 = 0; value > 0; clog2 = clog2 + 1)
			value = value >> 1;
	end
endfunction

function [15:0] bswap16;
	input [15:0] in;
	begin
		bswap16 = {in[7:0], in[15:8]};
	end
endfunction

function [31:0] bswap32;
	input [31:0] in;
	begin
		bswap32 = {in[7:0], in[15:8], in[23:16], in[31:24]};
	end
endfunction

`ifdef __ICARUS__	
`define _bit_width(a)	$clog2((a) + 1)
`else 
`define _bit_width(a)	clog2(a)
`endif

`define _min(a, b)		((a) < (b) ? (a) : (b))
`define _max(a, b)		((a) > (b) ? (a) : (b))

`define _min3(a, b, c)	((a) < (b) ? `_min(a, c) : `_min(b, c))
`define _max3(a, b, c)	((a) > (b) ? `_max(a, c) : `_max(b, c))

    localparam                              MIN_WIDTH           = `_min(A_WIDTH, B_WIDTH);
    localparam                              MAX_WIDTH           = `_max(A_WIDTH, B_WIDTH);
    localparam                              PIPELINE_STAGES     = `_bit_width(MIN_WIDTH - 1);
    localparam                              MAX_WIDTH_REG_NUM   = 1<<PIPELINE_STAGES;
    localparam  [MAX_WIDTH + MIN_WIDTH-1:0] RESET_VALUE         = {(MAX_WIDTH + MIN_WIDTH){1'b0}};
    /*--1.1ȷ��λ������ֵ��λ����Сֵ----------------------------------------------------------------------------------*/
    reg  [MIN_WIDTH - 1:0]          data_a ;
    reg  [MAX_WIDTH - 1:0]          data_b ;
    generate 
        if(MIN_WIDTH == A_WIDTH) begin
            always @(*)begin
                data_a = data_a_i;
                data_b = data_b_i;
            end
        end
        else begin
            always @(*)begin
                data_a = data_b_i ;
                data_b = data_a_i;
            end
        end
    endgenerate
    /*---1.2�����ۼӹ�������Ҫ�ı�����Խ��ն˱����ֵ--------------------------------------------------------------------*/
    genvar                 i,j;
    generate
        for (i = 0; i <= PIPELINE_STAGES; i = i+1 )begin:B
            reg [MAX_WIDTH + MIN_WIDTH - 1:0] data_sum[(MAX_WIDTH_REG_NUM>>i) - 1:0];
        end                
        for (i = 0; i < MIN_WIDTH; i = i+1 ) begin:C
            always @(*)
                B[0].data_sum[i] = data_a[i] ? {{(MIN_WIDTH - i){1'b0}},data_b[MAX_WIDTH - 1:0],{i{1'b0}}} : {(MAX_WIDTH+MIN_WIDTH){1'b0}};
        end
        for (i = MIN_WIDTH; i < MAX_WIDTH_REG_NUM; i = i+1 ) begin:D
            always @(*)
                B[0].data_sum[i] = {(MAX_WIDTH + MIN_WIDTH){1'b0}};
        end
    endgenerate
    /*---1.3�ۼӲ�����----------------------------------------------------------------------------------------------*/
    generate 
        if(PIPELINE_STAGES != 0)begin
            for (i = 1; i <= PIPELINE_STAGES; i = i+1 )begin:E
                for (j = 0; j < (MAX_WIDTH_REG_NUM>>i); j = j+1 )begin:F
                    always @ (posedge clk_i or negedge reset_an_i) begin
                        if (~reset_an_i)
                            B[i].data_sum[j] <= RESET_VALUE;
                        else if (reset_i)
                            B[i].data_sum[j] <= RESET_VALUE;
                        else if (~stall_i)
                            B[i].data_sum[j] <= B[i-1].data_sum[j] + B[i-1].data_sum[(MAX_WIDTH_REG_NUM>>i) + j];
                    end
                end
            end
        assign data_p_o = B[PIPELINE_STAGES].data_sum[0];
        end
        else begin
            reg [MAX_WIDTH + MIN_WIDTH - 1:0]   data;
            always @ (posedge clk_i or negedge reset_an_i) begin
                if (~reset_an_i)
                    data <= RESET_VALUE;
                else if (reset_i)
                    data <= RESET_VALUE;
                else if (~stall_i)
                    data <= B[0].data_sum[0];
            end
        assign data_p_o = data;
        end
    endgenerate

endmodule
