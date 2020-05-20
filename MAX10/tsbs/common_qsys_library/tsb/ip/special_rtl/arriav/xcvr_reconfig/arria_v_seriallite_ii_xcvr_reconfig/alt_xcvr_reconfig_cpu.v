// alt_xcvr_reconfig_cpu.v

// Generated using ACDS version 14.1 186 at 2014.12.26.21:43:42

`timescale 1 ps / 1 ps
module alt_xcvr_reconfig_cpu (
		input  wire        clk_clk,                        //                    clk.clk
		input  wire        reset_reset_n,                  //                  reset.reset_n
		output wire [9:0]  reconfig_mem_mem_address,       //       reconfig_mem_mem.address
		output wire        reconfig_mem_mem_read,          //                       .read
		input  wire [31:0] reconfig_mem_mem_readdata,      //                       .readdata
		output wire        reconfig_mem_mem_write,         //                       .write
		output wire [31:0] reconfig_mem_mem_writedata,     //                       .writedata
		output wire [3:0]  reconfig_mem_mem_byteenable,    //                       .byteenable
		output wire        reconfig_mem_reset_reset,       //     reconfig_mem_reset.reset
		output wire        reconfig_mem_reset_reset_req,   //                       .reset_req
		output wire        reconfig_ctrl_reset_reset,      //    reconfig_ctrl_reset.reset
		output wire [4:0]  reconfig_ctrl_ctrl_address,     //     reconfig_ctrl_ctrl.address
		output wire        reconfig_ctrl_ctrl_read,        //                       .read
		input  wire [31:0] reconfig_ctrl_ctrl_readdata,    //                       .readdata
		output wire        reconfig_ctrl_ctrl_write,       //                       .write
		output wire [31:0] reconfig_ctrl_ctrl_writedata,   //                       .writedata
		input  wire        reconfig_ctrl_ctrl_waitrequest, //                       .waitrequest
		input  wire        reconfig_ctrl_ctrl_irq_irq      // reconfig_ctrl_ctrl_irq.irq
	);

	wire  [31:0] reconfig_cpu_data_master_readdata;           // mm_interconnect_0:reconfig_cpu_data_master_readdata -> reconfig_cpu:d_readdata
	wire         reconfig_cpu_data_master_waitrequest;        // mm_interconnect_0:reconfig_cpu_data_master_waitrequest -> reconfig_cpu:d_waitrequest
	wire  [13:0] reconfig_cpu_data_master_address;            // reconfig_cpu:d_address -> mm_interconnect_0:reconfig_cpu_data_master_address
	wire   [3:0] reconfig_cpu_data_master_byteenable;         // reconfig_cpu:d_byteenable -> mm_interconnect_0:reconfig_cpu_data_master_byteenable
	wire         reconfig_cpu_data_master_read;               // reconfig_cpu:d_read -> mm_interconnect_0:reconfig_cpu_data_master_read
	wire         reconfig_cpu_data_master_write;              // reconfig_cpu:d_write -> mm_interconnect_0:reconfig_cpu_data_master_write
	wire  [31:0] reconfig_cpu_data_master_writedata;          // reconfig_cpu:d_writedata -> mm_interconnect_0:reconfig_cpu_data_master_writedata
	wire  [31:0] reconfig_cpu_instruction_master_readdata;    // mm_interconnect_0:reconfig_cpu_instruction_master_readdata -> reconfig_cpu:i_readdata
	wire         reconfig_cpu_instruction_master_waitrequest; // mm_interconnect_0:reconfig_cpu_instruction_master_waitrequest -> reconfig_cpu:i_waitrequest
	wire  [11:0] reconfig_cpu_instruction_master_address;     // reconfig_cpu:i_address -> mm_interconnect_0:reconfig_cpu_instruction_master_address
	wire         reconfig_cpu_instruction_master_read;        // reconfig_cpu:i_read -> mm_interconnect_0:reconfig_cpu_instruction_master_read
	wire  [31:0] reconfig_cpu_d_irq_irq;                      // irq_mapper:sender_irq -> reconfig_cpu:d_irq

	alt_xcvr_reconfig_cpu_reconfig_cpu reconfig_cpu (
		.clk           (clk_clk),                                     //                       clk.clk
		.reset_n       (~reconfig_ctrl_reset_reset),                  //                   reset_n.reset_n
		.d_address     (reconfig_cpu_data_master_address),            //               data_master.address
		.d_byteenable  (reconfig_cpu_data_master_byteenable),         //                          .byteenable
		.d_read        (reconfig_cpu_data_master_read),               //                          .read
		.d_readdata    (reconfig_cpu_data_master_readdata),           //                          .readdata
		.d_waitrequest (reconfig_cpu_data_master_waitrequest),        //                          .waitrequest
		.d_write       (reconfig_cpu_data_master_write),              //                          .write
		.d_writedata   (reconfig_cpu_data_master_writedata),          //                          .writedata
		.i_address     (reconfig_cpu_instruction_master_address),     //        instruction_master.address
		.i_read        (reconfig_cpu_instruction_master_read),        //                          .read
		.i_readdata    (reconfig_cpu_instruction_master_readdata),    //                          .readdata
		.i_waitrequest (reconfig_cpu_instruction_master_waitrequest), //                          .waitrequest
		.d_irq         (reconfig_cpu_d_irq_irq),                      //                     d_irq.irq
		.no_ci_readra  ()                                             // custom_instruction_master.readra
	);

	alt_xcvr_reconfig_cpu_mm_interconnect_0 mm_interconnect_0 (
		.clk_0_clk_clk                                    (clk_clk),                                     //                                  clk_0_clk.clk
		.reconfig_cpu_reset_n_reset_bridge_in_reset_reset (reconfig_ctrl_reset_reset),                   // reconfig_cpu_reset_n_reset_bridge_in_reset.reset
		.reconfig_cpu_data_master_address                 (reconfig_cpu_data_master_address),            //                   reconfig_cpu_data_master.address
		.reconfig_cpu_data_master_waitrequest             (reconfig_cpu_data_master_waitrequest),        //                                           .waitrequest
		.reconfig_cpu_data_master_byteenable              (reconfig_cpu_data_master_byteenable),         //                                           .byteenable
		.reconfig_cpu_data_master_read                    (reconfig_cpu_data_master_read),               //                                           .read
		.reconfig_cpu_data_master_readdata                (reconfig_cpu_data_master_readdata),           //                                           .readdata
		.reconfig_cpu_data_master_write                   (reconfig_cpu_data_master_write),              //                                           .write
		.reconfig_cpu_data_master_writedata               (reconfig_cpu_data_master_writedata),          //                                           .writedata
		.reconfig_cpu_instruction_master_address          (reconfig_cpu_instruction_master_address),     //            reconfig_cpu_instruction_master.address
		.reconfig_cpu_instruction_master_waitrequest      (reconfig_cpu_instruction_master_waitrequest), //                                           .waitrequest
		.reconfig_cpu_instruction_master_read             (reconfig_cpu_instruction_master_read),        //                                           .read
		.reconfig_cpu_instruction_master_readdata         (reconfig_cpu_instruction_master_readdata),    //                                           .readdata
		.reconfig_ctrl_ctrl_address                       (reconfig_ctrl_ctrl_address),                  //                         reconfig_ctrl_ctrl.address
		.reconfig_ctrl_ctrl_write                         (reconfig_ctrl_ctrl_write),                    //                                           .write
		.reconfig_ctrl_ctrl_read                          (reconfig_ctrl_ctrl_read),                     //                                           .read
		.reconfig_ctrl_ctrl_readdata                      (reconfig_ctrl_ctrl_readdata),                 //                                           .readdata
		.reconfig_ctrl_ctrl_writedata                     (reconfig_ctrl_ctrl_writedata),                //                                           .writedata
		.reconfig_ctrl_ctrl_waitrequest                   (reconfig_ctrl_ctrl_waitrequest),              //                                           .waitrequest
		.reconfig_mem_mem_address                         (reconfig_mem_mem_address),                    //                           reconfig_mem_mem.address
		.reconfig_mem_mem_write                           (reconfig_mem_mem_write),                      //                                           .write
		.reconfig_mem_mem_read                            (reconfig_mem_mem_read),                       //                                           .read
		.reconfig_mem_mem_readdata                        (reconfig_mem_mem_readdata),                   //                                           .readdata
		.reconfig_mem_mem_writedata                       (reconfig_mem_mem_writedata),                  //                                           .writedata
		.reconfig_mem_mem_byteenable                      (reconfig_mem_mem_byteenable)                  //                                           .byteenable
	);

	alt_xcvr_reconfig_cpu_irq_mapper irq_mapper (
		.clk           (clk_clk),                    //       clk.clk
		.reset         (reconfig_ctrl_reset_reset),  // clk_reset.reset
		.receiver0_irq (reconfig_ctrl_ctrl_irq_irq), // receiver0.irq
		.sender_irq    (reconfig_cpu_d_irq_irq)      //    sender.irq
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (1),
		.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (1),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller (
		.reset_in0      (~reset_reset_n),               // reset_in0.reset
		.clk            (clk_clk),                      //       clk.clk
		.reset_out      (reconfig_ctrl_reset_reset),    // reset_out.reset
		.reset_req      (reconfig_mem_reset_reset_req), //          .reset_req
		.reset_req_in0  (1'b0),                         // (terminated)
		.reset_in1      (1'b0),                         // (terminated)
		.reset_req_in1  (1'b0),                         // (terminated)
		.reset_in2      (1'b0),                         // (terminated)
		.reset_req_in2  (1'b0),                         // (terminated)
		.reset_in3      (1'b0),                         // (terminated)
		.reset_req_in3  (1'b0),                         // (terminated)
		.reset_in4      (1'b0),                         // (terminated)
		.reset_req_in4  (1'b0),                         // (terminated)
		.reset_in5      (1'b0),                         // (terminated)
		.reset_req_in5  (1'b0),                         // (terminated)
		.reset_in6      (1'b0),                         // (terminated)
		.reset_req_in6  (1'b0),                         // (terminated)
		.reset_in7      (1'b0),                         // (terminated)
		.reset_req_in7  (1'b0),                         // (terminated)
		.reset_in8      (1'b0),                         // (terminated)
		.reset_req_in8  (1'b0),                         // (terminated)
		.reset_in9      (1'b0),                         // (terminated)
		.reset_req_in9  (1'b0),                         // (terminated)
		.reset_in10     (1'b0),                         // (terminated)
		.reset_req_in10 (1'b0),                         // (terminated)
		.reset_in11     (1'b0),                         // (terminated)
		.reset_req_in11 (1'b0),                         // (terminated)
		.reset_in12     (1'b0),                         // (terminated)
		.reset_req_in12 (1'b0),                         // (terminated)
		.reset_in13     (1'b0),                         // (terminated)
		.reset_req_in13 (1'b0),                         // (terminated)
		.reset_in14     (1'b0),                         // (terminated)
		.reset_req_in14 (1'b0),                         // (terminated)
		.reset_in15     (1'b0),                         // (terminated)
		.reset_req_in15 (1'b0)                          // (terminated)
	);

	assign reconfig_mem_reset_reset = reconfig_ctrl_reset_reset;

endmodule
