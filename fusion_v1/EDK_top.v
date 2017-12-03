`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// 
// Create Date:    15:22:28 11/11/2016 
// Design Name: 
// Module Name:    EDK_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module EDK_top(
    inout                   [35:0]      CONTROL,
    input                   rst_n, 
    input                   fpga_0_clk_1_sys_clk_pin,
    
    output                  clk_133M_o,
    
                        /*---parameter control-----------------------------*/
                        output [31:0]               parameter_ctr           ,
                        /*--IIC--------------------------------------------*/
                        inout                       IIC_Bus_Sda_pin         ,
                        inout                       IIC_Bus_Scl_pin         ,
                        /*--OCC--------------------------------------------*/
                        input                       clk_rd_OCC_i,

                        input                       rd_OCC_frame_syn_i,    
                        input   [26:0]              rd_OCC_line_valid_i,

                        output  [31:0]              DDAC_o,  
                        /*--视频输入-----------------------------------------*/
                        input                       ddr2_din_clk            ,
                        input                       ddr2_din_vsync          ,
                        input                       ddr2_line_valid         ,
                        input                       ddr2_din_valid          ,
                        input    [15:0]             ddr2_din                ,
                        /*--视频输出-----------------------------------------*/
                        input                       ddr2_dout_clk           ,
                        input                       ddr2_dout_vsync         ,
                        input                       ddr2_dout_data_valid    ,
                        input                       ddr2_dout_line_valid    ,
                        output   [31:0]             ddr2_dout_data          ,
                        //menu
                        output                      clka_menu               ,
                        output                      wea_menu                ,
                        output    [13: 0]           addra_menu              ,
                        output    [4 : 0]           dina_menu               ,
                        /*--flash-------------------------------------------*/
                        inout                       spi_flash_sck           ,
                        inout                       spi_flash_miso          ,
                        inout                       spi_flash_mosi          ,
                        output                      spi_flash_ss            ,
                        /*--------------------------------------------------*/
                        inout                       adv7343_iic_sda         , 
                        inout                       adv7343_iic_scl         , 
                        
                        inout                       tvp5150_iic_sda         , 
                        inout                       tvp5150_iic_scl         ,
                        /*--uart--------------------------------------------*/
                        input                       RS232_RX_pin            ,
                        output                      RS232_TX_pin            
                );

                wire                    LPDDR_MCB3_cmd_clk_pin;
                wire                    LPDDR_MCB3_cmd_en_pin;
                wire        [2:0]       LPDDR_MCB3_cmd_instr_pin;
                wire        [5:0]       LPDDR_MCB3_cmd_bl_pin;
                wire        [29:0]      LPDDR_MCB3_cmd_byte_addr_pin;
                wire                    LPDDR_MCB3_cmd_empty_pin;
                wire                    LPDDR_MCB3_cmd_full_pin;

                wire                    LPDDR_MCB3_rd_clk_pin;
                wire                    LPDDR_MCB3_rd_en_pin;
                wire        [31:0]      LPDDR_MCB3_rd_data_pin;
                wire                    LPDDR_MCB3_rd_full_pin;
                wire                    LPDDR_MCB3_rd_empty_pin;
                wire        [6:0]       LPDDR_MCB3_rd_count_pin;
                wire                    LPDDR_MCB3_rd_overflow_pin;
                wire                    LPDDR_MCB3_rd_error_pin;
                /*---------------edk变量-----------------------------------------------------*/
                //MCB2 and MCB3 cmd
                wire                        LPDDR_MCB2_wr_clk_pin            ,LPDDR_MCB4_rd_clk_pin        ,LPDDR_MCB5_rd_clk_pin        ; 
                wire                        LPDDR_MCB2_cmd_en_pin            ,LPDDR_MCB4_cmd_en_pin        ,LPDDR_MCB5_cmd_en_pin          ;
                wire  [2:0]                 LPDDR_MCB2_cmd_instr_pin         ,LPDDR_MCB4_cmd_instr_pin     ,LPDDR_MCB5_cmd_instr_pin       ;
                wire  [5:0]                 LPDDR_MCB2_cmd_bl_pin            ,LPDDR_MCB4_cmd_bl_pin        ,LPDDR_MCB5_cmd_bl_pin        ;
                wire  [29:0]                LPDDR_MCB2_cmd_byte_addr_pin     ,LPDDR_MCB4_cmd_byte_addr_pin ,LPDDR_MCB5_cmd_byte_addr_pin   ;
                wire                        LPDDR_MCB2_cmd_empty_pin         ,LPDDR_MCB4_cmd_empty_pin     ,LPDDR_MCB5_cmd_empty_pin    ;
                wire                        LPDDR_MCB2_cmd_full_pin          ,LPDDR_MCB4_cmd_full_pin      ,LPDDR_MCB5_cmd_full_pin   ;
                //MCB2 wr and MCB3 rd
                wire                        LPDDR_MCB2_wr_en_pin             ,LPDDR_MCB4_rd_en_pin         ,LPDDR_MCB5_rd_en_pin   ;
                wire [3:0]                  LPDDR_MCB2_wr_mask_pin           = 4'b0000;
                wire [31:0]                 LPDDR_MCB2_wr_data_pin           ,LPDDR_MCB4_rd_data_pin       ,LPDDR_MCB5_rd_data_pin     ;
                wire                        LPDDR_MCB2_wr_full_pin           ,LPDDR_MCB4_rd_full_pin       ,LPDDR_MCB5_rd_full_pin    ;
                wire                        LPDDR_MCB2_wr_empty_pin          ,LPDDR_MCB4_rd_empty_pin      ,LPDDR_MCB5_rd_empty_pin   ;
                wire [6:0]                  LPDDR_MCB2_wr_count_pin          ,LPDDR_MCB4_rd_count_pin      ,LPDDR_MCB5_rd_count_pin    ;
                wire                        LPDDR_MCB2_wr_underrun_pin       ,LPDDR_MCB4_rd_overflow_pin   ,LPDDR_MCB5_rd_overflow_pin   ;
                wire                        LPDDR_MCB2_wr_error_pin          ,LPDDR_MCB4_rd_error_pin      ,LPDDR_MCB5_rd_error_pin   ;
                //DDR InitDone
                wire                        LPDDR_MPMC_InitDone_pin         ; 
                //GPIO
//                wire [31:0]                 parameter_ctr                   ; 
                wire                        wirte_status                    ; 
				// BRAM
				wire                        menu_BRAM_Rst_pin               ;
				wire                        menu_BRAM_Clk_pin               ;
				wire                        menu_BRAM_EN_pin                ;
				wire    [3:0]               menu_BRAM_WEN_pin               ;
				wire    [31:0]              menu_BRAM_Addr_pin              ;
				wire    [31:0]              menu_BRAM_Din_pin               ;
				wire    [31:0]              menu_BRAM_Dout_pin              ;
                //---read occ------------------------------------------------------------------------------------------
    ddr2_rd_controller_32 rd_DDAC (
        .rst_n                      (1'b1                                   ), 
        .iclk                       (clk_rd_OCC_i                          ), 
        .ivsync                     (rd_OCC_frame_syn_i                      ), 
        .iline_valid                ( ~rd_OCC_frame_syn_i                    ),//ddr2_dout_line_valid
        .idata_valid                ( rd_OCC_line_valid_i                  ), 

        .odata                      (DDAC_o                   ),
        .image_rd_start_addr        (30'h00000000                           ), 
        .parameter_in               (parameter_ctr                          ), 
        
        .mcb_rd_clk                 (LPDDR_MCB3_rd_clk_pin                  ), 
        .mcb_rd_full                (LPDDR_MCB3_rd_full_pin                 ), 
        .mcb_rd_data                (LPDDR_MCB3_rd_data_pin                 ), 
        
        .mcb_initdone               (LPDDR_MPMC_InitDone_pin                ), 
        .mcb_rd_en                  (LPDDR_MCB3_rd_en_pin                   ), 
        .mcb_cmd_rd_bl              (LPDDR_MCB3_cmd_bl_pin                  ), 
        .mcb_cmd_rd_addr            (LPDDR_MCB3_cmd_byte_addr_pin           ), 
        .mcb_cmd_rd_en              (LPDDR_MCB3_cmd_en_pin                  ), 
        .mcb_cmd_rd_instr           (LPDDR_MCB3_cmd_instr_pin               )
    );
                
 
                //---write image-------------------------------------------------------------     
                ddr2_wr_controller1
                SXILINX_1(
                        .rst_n                      (1'b1                                   ),
                        
                        .iclk                       (ddr2_din_clk                           ), 
                        .ivalid                     (ddr2_din_valid                         ), 
                        .isync                      (ddr2_din_vsync                         ), 
                        .idata                      (ddr2_din                               ), 
                        .wirte_status               (wirte_status                           ), 
                        .parameter_in               (parameter_ctr                          ), 

                        .mcb_wr_clk                 (LPDDR_MCB2_wr_clk_pin                  ), 
                        .mcb_wr_empty               (LPDDR_MCB2_wr_empty_pin                ), 
                        .mcb_initdone               (LPDDR_MPMC_InitDone_pin                ), 
                        .mcb_wr_en                  (LPDDR_MCB2_wr_en_pin                   ), 
                        .mcb_wr_data                (LPDDR_MCB2_wr_data_pin                 ), 
                        .mcb_cmd_wr_bl              (LPDDR_MCB2_cmd_bl_pin                  ), 
                        .mcb_cmd_wr_addr            (LPDDR_MCB2_cmd_byte_addr_pin           ), 
                        .mcb_cmd_wr_en              (LPDDR_MCB2_cmd_en_pin                  ), 
                        .mcb_cmd_wr_instr           (LPDDR_MCB2_cmd_instr_pin               ) 
                ); 
/*-------------------------------------------------------------------------------------------------*/    
                /*--------生成一个新的场同步信号-----------------------------------------------*/
                wire sync_rd       = ddr2_dout_vsync;
                wire line_valid_rd = ddr2_dout_line_valid;
                wire data_valid_rd = ddr2_dout_data_valid;
                
                reg [9:0]   count = 0;
                reg         line_valid_rd_1;
                reg [31:0]  cnt_sync;
                reg          sync_gen;
                always @(posedge ddr2_dout_clk) 
                begin
                    line_valid_rd_1 <= line_valid_rd;
                    if(sync_rd)                                          count <= 0;
                    else if({line_valid_rd_1,line_valid_rd} == 2'b10)    count <= count + 1;
                    else                                                 count <= count;
                   
                    if(count == 512) cnt_sync <= cnt_sync + 1;
                    else             cnt_sync <= 0;
                   
                    if((cnt_sync >=128) &&(cnt_sync <= 512))  sync_gen <= 1;
                    else                                      sync_gen <= 0;
                end
            
                wire ddr2_dout_vsync_1 = sync_gen;
                /*------------------------------------------------------------------------*/
                ddr2_rd_controller1 SXILINX_2 (
                        .rst_n                      (1'b1                                   ), 
                        .iclk                       (ddr2_dout_clk                          ), 
                        .ivsync                     (ddr2_dout_vsync_1                      ), 
                        .iline_valid                ( ~ddr2_dout_vsync_1                    ),//ddr2_dout_line_valid
                        .idata_valid                ( ddr2_dout_data_valid                  ), 

                        .odata                      (ddr2_dout_data[15:0]                   ), 
                        .image_rd_start_addr        (30'h000A0000                           ), 
                        .parameter_in               (parameter_ctr                          ), 
                        
                        .mcb_rd_clk                 (LPDDR_MCB4_rd_clk_pin                  ), 
                        .mcb_rd_full                (LPDDR_MCB4_rd_full_pin                 ), 
                        .mcb_rd_data                (LPDDR_MCB4_rd_data_pin                 ), 
                        
                        .mcb_initdone               (LPDDR_MPMC_InitDone_pin                ), 
                        .mcb_rd_en                  (LPDDR_MCB4_rd_en_pin                   ), 
                        .mcb_cmd_rd_bl              (LPDDR_MCB4_cmd_bl_pin                  ), 
                        .mcb_cmd_rd_addr            (LPDDR_MCB4_cmd_byte_addr_pin           ), 
                        .mcb_cmd_rd_en              (LPDDR_MCB4_cmd_en_pin                  ), 
                        .mcb_cmd_rd_instr           (LPDDR_MCB4_cmd_instr_pin               )
                );
                /*------------------------------------------------------------------------*/
                ddr2_rd_controller1 SXILINX_3 (
                        .rst_n                      (1'b1                                   ), 
                        .iclk                       (ddr2_dout_clk                          ), 
                        .ivsync                     (ddr2_dout_vsync_1                      ), 
                        .iline_valid                ( ~ddr2_dout_vsync_1                    ),//ddr2_dout_line_valid
                        .idata_valid                ( ddr2_dout_data_valid                  ), 

                        .odata                      (ddr2_dout_data[31:16]                  ), 
                        .image_rd_start_addr        (30'h001E0000                           ), 
                        .parameter_in               (parameter_ctr                          ), 
                        
                        
                        .mcb_rd_clk                 (LPDDR_MCB5_rd_clk_pin                  ), 
                        .mcb_rd_full                (LPDDR_MCB5_rd_full_pin                 ), 
                        .mcb_rd_data                (LPDDR_MCB5_rd_data_pin                 ), 
                        
                        .mcb_initdone               (LPDDR_MPMC_InitDone_pin                ), 
                        .mcb_rd_en                  (LPDDR_MCB5_rd_en_pin                   ), 
                        .mcb_cmd_rd_bl              (LPDDR_MCB5_cmd_bl_pin                  ), 
                        .mcb_cmd_rd_addr            (LPDDR_MCB5_cmd_byte_addr_pin           ), 
                        .mcb_cmd_rd_en              (LPDDR_MCB5_cmd_en_pin                  ), 
                        .mcb_cmd_rd_instr           (LPDDR_MCB5_cmd_instr_pin               )
                );
    //---------------------------------------------------------------------------------------------
    wire    [31:0]      CMD_GPIO_IO_O_pin;
    (* BOX_TYPE = "user_black_box" *)
    EDK EDK (
        .clock_133mhz_o_pin                     (clk_133M_o),
    
        .fpga_0_clk_1_sys_clk_pin               ( fpga_0_clk_1_sys_clk_pin          ),
        .fpga_0_rst_1_sys_rst_pin               ( 1'b1                              ),

        .CMD_GPIO_IO_O_pin                      (CMD_GPIO_IO_O_pin                  ), 
        .DDR2_WRITE_STATUS_GPIO_IO_I_pin        (wirte_status                       ), 

//                        .IIC_Bus_Sda_pin                        ( IIC_Bus_Sda_pin                   ),
//                        .IIC_Bus_Scl_pin                        ( IIC_Bus_Scl_pin                   ),
        //---------------------------------------rd 32-------------------------------    
        .LPDDR_MCB2_cmd_clk_pin                 ( LPDDR_MCB2_wr_clk_pin             ),
        .LPDDR_MCB2_cmd_en_pin                  ( LPDDR_MCB2_cmd_en_pin             ),
        .LPDDR_MCB2_cmd_instr_pin               ( LPDDR_MCB2_cmd_instr_pin          ),
        .LPDDR_MCB2_cmd_bl_pin                  ( LPDDR_MCB2_cmd_bl_pin             ),
        .LPDDR_MCB2_cmd_byte_addr_pin           ( LPDDR_MCB2_cmd_byte_addr_pin      ),
        .LPDDR_MCB2_cmd_empty_pin               ( LPDDR_MCB2_cmd_empty_pin          ),
        .LPDDR_MCB2_cmd_full_pin                ( LPDDR_MCB2_cmd_full_pin           ),

        .LPDDR_MCB2_wr_clk_pin                  (LPDDR_MCB2_wr_clk_pin              ), 
        .LPDDR_MCB2_wr_en_pin                   (LPDDR_MCB2_wr_en_pin               ),
        .LPDDR_MCB2_wr_mask_pin                 (LPDDR_MCB2_wr_mask_pin             ), 
        .LPDDR_MCB2_wr_data_pin                 (LPDDR_MCB2_wr_data_pin             ), 
        .LPDDR_MCB2_wr_full_pin                 (LPDDR_MCB2_wr_full_pin             ), 
        .LPDDR_MCB2_wr_empty_pin                (LPDDR_MCB2_wr_empty_pin            ), 
        .LPDDR_MCB2_wr_count_pin                (LPDDR_MCB2_wr_count_pin            ), 
        .LPDDR_MCB2_wr_underrun_pin             (LPDDR_MCB2_wr_underrun_pin         ), 
        .LPDDR_MCB2_wr_error_pin                (LPDDR_MCB2_wr_error_pin            ), 
        //---------------------------------------rd 32-------------------------------
        .LPDDR_MCB3_cmd_clk_pin                 ( LPDDR_MCB3_cmd_clk_pin            ),
        .LPDDR_MCB3_cmd_en_pin                  ( LPDDR_MCB3_cmd_en_pin             ),
        .LPDDR_MCB3_cmd_instr_pin               ( LPDDR_MCB3_cmd_instr_pin          ),
        .LPDDR_MCB3_cmd_bl_pin                  ( LPDDR_MCB3_cmd_bl_pin             ),
        .LPDDR_MCB3_cmd_byte_addr_pin           ( LPDDR_MCB3_cmd_byte_addr_pin      ),
        .LPDDR_MCB3_cmd_empty_pin               ( LPDDR_MCB3_cmd_empty_pin          ),
        .LPDDR_MCB3_cmd_full_pin                ( LPDDR_MCB3_cmd_full_pin           ),

        .LPDDR_MCB3_rd_clk_pin                  ( LPDDR_MCB3_rd_clk_pin             ),
        .LPDDR_MCB3_rd_en_pin                   ( LPDDR_MCB3_rd_en_pin              ),
        .LPDDR_MCB3_rd_data_pin                 ( LPDDR_MCB3_rd_data_pin            ),
        .LPDDR_MCB3_rd_full_pin                 ( LPDDR_MCB3_rd_full_pin            ),
        .LPDDR_MCB3_rd_empty_pin                ( LPDDR_MCB3_rd_empty_pin           ),
        .LPDDR_MCB3_rd_count_pin                ( LPDDR_MCB3_rd_count_pin           ),
        .LPDDR_MCB3_rd_overflow_pin             ( LPDDR_MCB3_rd_overflow_pin        ),
        .LPDDR_MCB3_rd_error_pin                ( LPDDR_MCB3_rd_error_pin           ),
        //--------------------------------------- 32-------------------------------
        .LPDDR_MCB4_cmd_clk_pin                 ( LPDDR_MCB4_rd_clk_pin             ),
        .LPDDR_MCB4_cmd_en_pin                  ( LPDDR_MCB4_cmd_en_pin             ),
        .LPDDR_MCB4_cmd_instr_pin               ( LPDDR_MCB4_cmd_instr_pin          ),
        .LPDDR_MCB4_cmd_bl_pin                  ( LPDDR_MCB4_cmd_bl_pin             ),
        .LPDDR_MCB4_cmd_byte_addr_pin           ( LPDDR_MCB4_cmd_byte_addr_pin      ),
        .LPDDR_MCB4_cmd_empty_pin               ( LPDDR_MCB4_cmd_empty_pin          ),
        .LPDDR_MCB4_cmd_full_pin                ( LPDDR_MCB4_cmd_full_pin           ),
        
        .LPDDR_MCB4_rd_clk_pin                  (LPDDR_MCB4_rd_clk_pin              ), 
        .LPDDR_MCB4_rd_en_pin                   (LPDDR_MCB4_rd_en_pin               ), 
        .LPDDR_MCB4_rd_data_pin                 (LPDDR_MCB4_rd_data_pin             ), 
        .LPDDR_MCB4_rd_full_pin                 (LPDDR_MCB4_rd_full_pin             ),
        .LPDDR_MCB4_rd_empty_pin                (LPDDR_MCB4_rd_empty_pin            ),
        .LPDDR_MCB4_rd_count_pin                (LPDDR_MCB4_rd_count_pin            ), 
        .LPDDR_MCB4_rd_overflow_pin             (LPDDR_MCB4_rd_overflow_pin         ), 
        .LPDDR_MCB4_rd_error_pin                (LPDDR_MCB4_rd_error_pin            ),
        //--------------------------------------- 32-------------------------------
        .LPDDR_MCB5_cmd_clk_pin                 ( LPDDR_MCB5_rd_clk_pin             ),
        .LPDDR_MCB5_cmd_en_pin                  ( LPDDR_MCB5_cmd_en_pin             ),
        .LPDDR_MCB5_cmd_instr_pin               ( LPDDR_MCB5_cmd_instr_pin          ),
        .LPDDR_MCB5_cmd_bl_pin                  ( LPDDR_MCB5_cmd_bl_pin             ),
        .LPDDR_MCB5_cmd_byte_addr_pin           ( LPDDR_MCB5_cmd_byte_addr_pin      ),
        .LPDDR_MCB5_cmd_empty_pin               ( LPDDR_MCB5_cmd_empty_pin          ),
        .LPDDR_MCB5_cmd_full_pin                ( LPDDR_MCB5_cmd_full_pin           ),
        
        .LPDDR_MCB5_rd_clk_pin                  (LPDDR_MCB5_rd_clk_pin              ), 
        .LPDDR_MCB5_rd_en_pin                   (LPDDR_MCB5_rd_en_pin               ), 
        .LPDDR_MCB5_rd_data_pin                 (LPDDR_MCB5_rd_data_pin             ), 
        .LPDDR_MCB5_rd_full_pin                 (LPDDR_MCB5_rd_full_pin             ),
        .LPDDR_MCB5_rd_empty_pin                (LPDDR_MCB5_rd_empty_pin            ),
        .LPDDR_MCB5_rd_count_pin                (LPDDR_MCB5_rd_count_pin            ), 
        .LPDDR_MCB5_rd_overflow_pin             (LPDDR_MCB5_rd_overflow_pin         ), 
        .LPDDR_MCB5_rd_error_pin                (LPDDR_MCB5_rd_error_pin            ),

        .LPDDR_MPMC_InitDone_pin                (LPDDR_MPMC_InitDone_pin            ),
        //BRAM_MENU
		.xps_bram_if_cntlr_menu_BRAM_Rst_pin    (menu_BRAM_Rst_pin                  ), 
        .xps_bram_if_cntlr_menu_BRAM_Clk_pin    (menu_BRAM_Clk_pin                  ), 
        .xps_bram_if_cntlr_menu_BRAM_EN_pin     (menu_BRAM_EN_pin	                ), 
        .xps_bram_if_cntlr_menu_BRAM_WEN_pin    (menu_BRAM_WEN_pin                  ), 
        .xps_bram_if_cntlr_menu_BRAM_Addr_pin   (menu_BRAM_Addr_pin                 ), 
        .xps_bram_if_cntlr_menu_BRAM_Din_pin    (menu_BRAM_Din_pin                  ), 
        .xps_bram_if_cntlr_menu_BRAM_Dout_pin   (menu_BRAM_Dout_pin                 ),
        //----------------------------------------
        .SPI_FLASH_SCK_O_pin                    ( spi_flash_sck                     ),
        .SPI_FLASH_MISO_I_pin                   ( spi_flash_miso                    ),
        .SPI_FLASH_MOSI_O_pin                   ( spi_flash_mosi                    ),
        .SPI_FLASH_SS_O_pin                     ( spi_flash_ss                      ),
        
        .adv7343_iic_Sda                        (adv7343_iic_sda                    ), 
        .adv7343_iic_Scl                        (adv7343_iic_scl                    ), 
        .tvp5150_iic_Sda                        (tvp5150_iic_sda                    ), 
        .tvp5150_iic_Scl                        (tvp5150_iic_scl                    ),

        .RS232_RX_pin                           ( RS232_RX_pin                      ),
        .RS232_TX_pin                           ( RS232_TX_pin                      )
    );
    parameter_set SXILINX_41 (
        .iclk                                      (ddr2_din_clk                        ), 
        .parameter_in                              (CMD_GPIO_IO_O_pin                   ), 
        .data_parameter                            (parameter_ctr[15:0]                 ), 
        .addr_parameter                            (parameter_ctr[31:16]                )
    );
///*-------------------------------ram_menu_1------------------------------------------------------------------------------------------------------------------------*/
assign   clka_menu                  = menu_BRAM_Clk_pin         ;
assign    wea_menu                  = menu_BRAM_WEN_pin[0]      ;
assign    addra_menu                = menu_BRAM_Addr_pin[15:2]  ;
assign    dina_menu                 = menu_BRAM_Dout_pin[4:0]   ;
assign    menu_BRAM_Din_pin[31:0]   = 0;  
  
endmodule

