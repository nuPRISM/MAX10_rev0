`ifndef FRAME_BUF_INTERFACE_DEFS_V
`define FRAME_BUF_INTERFACE_DEFS_V


typedef struct { 
logic [15:0] state;                                /* output   */ 
logic [31:0] buffer_start_address;                 /* output   */ 
logic [31:0] back_buf_start_address;               /* output   */ 
logic [31:0] last_written_buf_start_address;       /* output   */ 
logic [31:0] external_priority_backbuffer_address; /* input    */ 
logic        use_external_priority_backbuffer;     /* output   */ 
logic        dma_enabled;                          /* output   */ 
logic        pause_after_each_frame;               /* input    */ 
logic        currently_processing_packet;          /* output   */ 
logic        get_frame_now;                        /* input    */ 
logic        get_frame_now_ack;                    /* output   */ 
logic [31:0] num_buffer_swaps;                     /* output   */ 
logic [31:0] num_of_packets_processed;             /* output   */ 
logic [31:0] num_of_repeated_packets;              /* output   */ 
logic        swap_buffers_now;                     /* output   */ 
logic        external_swap_buffer_now;             /* input    */ 
logic        wait_for_swap;                        /* output   */ 
logic [31:0] default_buffer_address;               /* input    */ 
logic [31:0] default_back_buf_address;             /* input    */ 
} frame_buffer_hw_control_struct;

typedef struct { 
      logic [255:0] master_readdata;                          
      logic        master_readdatavalid;                     
      logic        master_waitrequest;                       
      logic [31:0] master_address;                           
      logic        master_write;                             
      logic [255:0] master_writedata;                         
      logic        master_read;                              
      logic [255:0] stream_data;                              
      logic        stream_startofpacket;                     
      logic        stream_endofpacket;                       
      logic        stream_empty;                             
      logic        stream_valid;                             
      logic        stream_ready;                             
      logic [15:0] state;                                    
      logic [31:0] back_buf_start_address;                   
      logic        dma_enabled;                              
      logic        soft_reset_now;                              
      logic [31:0] last_written_buf_start_address;           
      logic [31:0] external_priority_backbuffer_address;     
      logic        use_external_priority_backbuffer;         
      logic        currently_processing_packet;              
      logic        pause_after_each_frame;                   
      logic        get_frame_now;                            
      logic        get_frame_now_ack;                        
      logic [31:0] buffer_start_address;                     
      logic [31:0] num_buffer_swaps;                         
      logic [31:0] num_of_packets_processed;                 
      logic [31:0] num_of_repeated_packets;                  
      logic [31:0] write_bytes_left;                         
      logic        swap_buffers_now;                         
      logic        external_swap_buffer_now;                 
      logic        wait_for_swap;                            
      logic        out_of_band_data_received;                      
      logic [63:0] watchdog_counter;                               
      logic        watchdog_reset;                                 
      logic        increase_watchdog_event_count;                  
      logic [31:0] num_watchdog_events;                            
      logic [31:0] num_of_discarded_packets;                            
      logic        discarded_packet_event;                            
      logic [31:0] num_of_packets_finished_processing;
} frame_buffer_snoop_struct;

interface complete_dma_frame_buffer_hw_control_interface;
parameter numreaders = 2; 
frame_buffer_hw_control_struct frame_dma_writer_hw_control_struct;
frame_buffer_hw_control_struct frame_dma_reader_hw_control_struct[numreaders];
frame_buffer_snoop_struct frame_dma_writer_snoop_struct;
frame_buffer_snoop_struct frame_dma_reader_snoop_struct[numreaders];
endinterface

`endif