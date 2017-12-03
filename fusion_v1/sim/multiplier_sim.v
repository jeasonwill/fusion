`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:38:10 06/20/2017
// Design Name:   multiplier
// Module Name:   D:/360Downloads/shi/multiplier_sim.v
// Project Name:  shi
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: multiplier
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module multiplier_sim;
                parameter                       A_WIDTH = 10;
                parameter                       B_WIDTH = 1;
                // Inputs
                reg                             clk_i;
                reg                             reset_an_i;
                reg                             reset_i;
                reg                             stall_i;
                reg [A_WIDTH -1 :0]             data_a_i;
                reg [B_WIDTH -1 :0]             data_b_i;
                wire [B_WIDTH + A_WIDTH -1:0]   data_p_o;
                wire [A_WIDTH -1 :0]            data_a_o;
                wire [B_WIDTH -1 :0]            data_b_o;
                wire [B_WIDTH + A_WIDTH -1:0]   data_p = data_a_o*data_b_o;
                /*-------------------------------------------------------*/
                `include "math.v"
                localparam                              MIN_WIDTH           = `_min(A_WIDTH, B_WIDTH);
                localparam                              MAX_WIDTH           = `_max(A_WIDTH, B_WIDTH);
                localparam                              PIPELINE_STAGES     = `_bit_width(MIN_WIDTH - 1);
                //initial
                initial begin
                    // Initialize Inputs
                    clk_i = 0;
                    reset_an_i = 1;
                    reset_i = 0;
                    stall_i = 0;
                    data_a_i = 1;
                    data_b_i = 1;
                    // Wait 100 ns for global reset to finish
                    #100;
                    // Add stimulus here
                end
                // clk genrate
                always #100 clk_i = ~clk_i; 

                // data genrate
//                always @ (posedge clk_i ) begin
//                        data_a_i <= data_a_i + 1;
//                        data_b_i <= data_b_i + 1;
//                end
                always @ (posedge clk_i ) begin
                        data_a_i <= {$random}%{1'b1,{A_WIDTH{1'b0}}};
                        data_b_i <= {$random}%{1'b1,{B_WIDTH{1'b0}}};
                end
                // Instantiate the Unit Under Test (UUT)
                multiplier #(.A_WIDTH(A_WIDTH),.B_WIDTH(B_WIDTH))
                uut (
                    .clk_i          (clk_i          ), 
                    .reset_an_i     (reset_an_i     ), 
                    .reset_i        (reset_i        ), 
                    .stall_i        (stall_i        ), 
                    .data_a_i       (data_a_i       ), 
                    .data_b_i       (data_b_i       ), 
                    .data_p_o       (data_p_o       )
                );
                //check data
                generate begin
                    if(PIPELINE_STAGES != 0)begin
                        generic_pipeline #(
                            .DATA_W         (MIN_WIDTH + MAX_WIDTH              ),
                            .DEPTH          (PIPELINE_STAGES                    ),
                            .RESET_VALUE    ({(MIN_WIDTH + MAX_WIDTH){1'b0}}    )
                        )
                        data_pipeline_inst (
                            .clk_i          (clk_i          ),
                            .reset_an_i     (1'b1           ),
                            .reset_i        (1'b0           ),
                            .stall_i        (stall_i        ),
                            
                            .data_i         ({data_a_i[A_WIDTH -1 :0],data_b_i[B_WIDTH -1 :0]}),
                            .data_o         ({data_a_o[A_WIDTH -1 :0],data_b_o[B_WIDTH -1 :0]})
                        );
                    end
                    else begin
                        generic_pipeline #(
                            .DATA_W         (MIN_WIDTH + MAX_WIDTH              ),
                            .DEPTH          (1                                  ),
                            .RESET_VALUE    ({(MIN_WIDTH + MAX_WIDTH){1'b0}}    )
                        )
                        data_pipeline_inst (
                            .clk_i          (clk_i                  ),
                            .reset_an_i     (1'b1                   ),
                            .reset_i        (1'b0                   ),
                            .stall_i        (stall_i                ),
                            
                            .data_i         ({data_a_i[A_WIDTH -1 :0],data_b_i[B_WIDTH -1 :0]}),
                            .data_o         ({data_a_o[A_WIDTH -1 :0],data_b_o[B_WIDTH -1 :0]})
                        );
                    end
                end
                endgenerate
                
                always @ (posedge clk_i ) begin
                        if (data_p_o != data_p) begin
                            $display("Error value at: data_a_i = %d, data_b_i = %d; Expected: data_p = %d, Actual:data_p = %d", data_a_o, data_b_o, data_p, data_p_o);
                            $finish;
                        end
                        if(data_a_o == 10)
                        begin
                            $display("right value at: data_a_i = %d, data_b_i = %d; Expected: data_p = %d, Actual:data_p = %d", data_a_o, data_b_o, data_p, data_p_o);
                        end
                end
                
endmodule

