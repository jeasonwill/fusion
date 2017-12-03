`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: magewell
// Engineer: ykf
// 
// Create Date: 2017/06/20 14:45:04
// Design Name: 
// Module Name: multiplier
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 乘法器：根据最小位宽确定延迟时钟数，比如最小位宽为32位（0-31），用五位二进制可表示0到31，所以延迟时钟数为5个(round_up(log2(MIN_WIDTH - 1))).
//              例外：MIN_WIDTH为1时，理论上延迟时钟数为0个，但这里将其特殊设置，为1个时钟延迟。
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//module multiplier
module multiplier#(     parameter                       A_WIDTH = 10,
                        parameter                       B_WIDTH = 10
                )
                (
                        input                           clk_i       ,
                        input                           reset_an_i  ,
                        input                           reset_i     ,
                        input                           stall_i     ,
                        input [A_WIDTH - 1:0]           data_a_i    ,
                        input [B_WIDTH - 1:0]           data_b_i    ,
                        output[A_WIDTH+B_WIDTH - 1:0]   data_p_o
                );
                `include "math.v"
                localparam                              MIN_WIDTH           = `_min(A_WIDTH, B_WIDTH);
                localparam                              MAX_WIDTH           = `_max(A_WIDTH, B_WIDTH);
                localparam                              PIPELINE_STAGES     = `_bit_width(MIN_WIDTH - 1);
                localparam                              MAX_WIDTH_REG_NUM   = 1<<PIPELINE_STAGES;
                localparam  [MAX_WIDTH + MIN_WIDTH-1:0] RESET_VALUE         = {(MAX_WIDTH + MIN_WIDTH){1'b0}};
                generate begin:A
                    if(MIN_WIDTH == A_WIDTH) begin
                        wire  [MIN_WIDTH - 1:0]          data_a = data_a_i;
                        wire  [MAX_WIDTH - 1:0]          data_b = data_b_i;
                    end
                    else begin
                        wire  [MIN_WIDTH - 1:0]          data_a = data_b_i;
                        wire  [MAX_WIDTH - 1:0]          data_b = data_a_i;
                    end
                end
                endgenerate
                genvar                 i,j;
                generate    
                    for (i = 0; i <= PIPELINE_STAGES; i = i+1 )begin:B
                        if(i == 0)
                            wire [MAX_WIDTH + MIN_WIDTH - 1:0] data_sum[MAX_WIDTH_REG_NUM - 1:0];
                        else
                            reg [MAX_WIDTH + MIN_WIDTH - 1:0] data_sum[(MAX_WIDTH_REG_NUM>>i) - 1:0];
                    end
                endgenerate
                
                generate    
                        for (i = 0; i < MIN_WIDTH; i = i+1 ) begin
                            assign  B[0].data_sum[i] = A.data_a[i] ? {{(MIN_WIDTH - i){1'b0}},A.data_b[MAX_WIDTH - 1:0],{i{1'b0}}} : {(MAX_WIDTH+MIN_WIDTH){1'b0}};
                        end
                        for (i = MIN_WIDTH; i < MAX_WIDTH_REG_NUM; i = i+1 ) begin
                            assign  B[0].data_sum[i] = {(MAX_WIDTH + MIN_WIDTH){1'b0}};
                        end
                endgenerate
                
                generate begin
                    if(PIPELINE_STAGES != 0)begin
                        for (i = 1; i <= PIPELINE_STAGES; i = i+1 )begin
                            for (j = 0; j < (MAX_WIDTH_REG_NUM>>i); j = j+1 )begin
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
                end
                endgenerate

endmodule
