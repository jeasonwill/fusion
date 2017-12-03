`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// CONFIDENTIAL and PROPRIETARY software of IMyFusion Electronics Co., Ltd.
// Copyright (c) 2011-2017 IMyFusion Electronics Co., Ltd. (Nanjing) 
// All rights reserved. 
// Engineer: Kevin Yang
// This copyright notice MUST be reproduced on all authorized copies.
////////////////////////////////////////////////////////////////////////////////

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
