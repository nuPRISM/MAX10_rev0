// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

package msgdma_constants;
parameter ALTERA_MSGDMA_DESCRIPTOR_READ_ADDRESS_REG                  =    32'h0 ;
parameter ALTERA_MSGDMA_DESCRIPTOR_WRITE_ADDRESS_REG                 =    32'h4 ;
parameter ALTERA_MSGDMA_DESCRIPTOR_LENGTH_REG                        =    32'h8 ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_STANDARD_REG              =    32'hC ;
parameter ALTERA_MSGDMA_DESCRIPTOR_SEQUENCE_NUMBER_REG               =    32'hC ;
parameter ALTERA_MSGDMA_DESCRIPTOR_READ_BURST_REG                    =    32'hE ;
parameter ALTERA_MSGDMA_DESCRIPTOR_WRITE_BURST_REG                   =    32'hF ;
parameter ALTERA_MSGDMA_DESCRIPTOR_READ_STRIDE_REG                   =    32'h10;
parameter ALTERA_MSGDMA_DESCRIPTOR_WRITE_STRIDE_REG                  =    32'h12;
parameter ALTERA_MSGDMA_DESCRIPTOR_READ_ADDRESS_HIGH_REG             =    32'h14;
parameter ALTERA_MSGDMA_DESCRIPTOR_WRITE_ADDRESS_HIGH_REG            =    32'h18;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_ENHANCED_REG              =    32'h1C;


/* masks and offsets for the sequence number and programmable burst counts */
parameter ALTERA_MSGDMA_DESCRIPTOR_SEQUENCE_NUMBER_MASK              =    32'hFFFF     ;
parameter ALTERA_MSGDMA_DESCRIPTOR_SEQUENCE_NUMBER_OFFSET            =    0          ;
parameter ALTERA_MSGDMA_DESCRIPTOR_READ_BURST_COUNT_MASK             =    32'h00FF0000 ;
parameter ALTERA_MSGDMA_DESCRIPTOR_READ_BURST_COUNT_OFFSET           =    16         ;
parameter ALTERA_MSGDMA_DESCRIPTOR_WRITE_BURST_COUNT_MASK            =    32'hFF000000 ;
parameter ALTERA_MSGDMA_DESCRIPTOR_WRITE_BURST_COUNT_OFFSET          =    24         ;


/* masks and offsets for the read and write strides */
parameter ALTERA_MSGDMA_DESCRIPTOR_READ_STRIDE_MASK                =     32'hFFFF       ;
parameter ALTERA_MSGDMA_DESCRIPTOR_READ_STRIDE_OFFSET              =     0            ;
parameter ALTERA_MSGDMA_DESCRIPTOR_WRITE_STRIDE_MASK               =     32'hFFFF0000   ;
parameter ALTERA_MSGDMA_DESCRIPTOR_WRITE_STRIDE_OFFSET             =     16           ;


/* masks and offsets for the bits in the descriptor control field */
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_TRANSMIT_CHANNEL_MASK        =  32'hFF       ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_TRANSMIT_CHANNEL_OFFSET      =  0          ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_SOP_MASK            =  (1 << 8)   ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_SOP_OFFSET          =  8          ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_EOP_MASK            =  (1 << 9)   ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_EOP_OFFSET          =  9          ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_PARK_READS_MASK              =  (1 << 10)  ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_PARK_READS_OFFSET            =  10         ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_PARK_WRITES_MASK             =  (1 << 11)  ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_PARK_WRITES_OFFSET           =  11         ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_END_ON_EOP_MASK              =  (1 << 12)  ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_END_ON_EOP_OFFSET            =  12         ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_TRANSFER_COMPLETE_IRQ_MASK   =  (1 << 14)  ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_TRANSFER_COMPLETE_IRQ_OFFSET =  14         ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_EARLY_TERMINATION_IRQ_MASK   =  (1 << 15)  ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_EARLY_TERMINATION_IRQ_OFFSET =  15         ;
/* the read master will use this as the transmit error, the dispatcher will use 
this to generate an interrupt if any of the error bits are asserted by the 
write master */
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_ERROR_IRQ_MASK               =  (32'hFF << 16)  ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_ERROR_IRQ_OFFSET             =  16            ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_EARLY_DONE_ENABLE_MASK       =  (1 << 24)     ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_EARLY_DONE_ENABLE_OFFSET     =  24            ;
/* at a minimum you always have to write '1' to this bit as it commits the 
descriptor to the dispatcher */
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GO_MASK                     = (1 << 31)    ;
parameter ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GO_OFFSET                   = 31           ;

endpackage
