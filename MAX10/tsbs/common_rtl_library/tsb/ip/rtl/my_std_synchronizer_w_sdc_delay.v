// START_MODULE_NAME-----------------------------------------------------------
//
// Module Name : my_std_synchronizer
//
// Description : Single bit clock domain crossing synchronizer. 
//               Composed of two or more flip flops connected in series.

`timescale 1ns / 1ns

module my_std_synchronizer_w_sdc_delay (
                                clk, 
                                reset_n, 
                                din, 
                                dout
                                );

    // GLOBAL PARAMETER DECLARATION
    parameter depth = 3; // This value must be >= 2 !
       
    // INPUT PORT DECLARATION 
    input   clk;
    input   reset_n;    
    input   din;

    // OUTPUT PORT DECLARATION 
    output  dout;

    // QuartusII synthesis directives:
    //     1. Preserve all registers ie. do not touch them.
    //     2. Do not merge other flip-flops with synchronizer flip-flops.
    // QuartusII TimeQuest directives:
    //     1. Identify all flip-flops in this module as members of the synchronizer 
    //        to enable automatic metastability MTBF analysis.
    //     2. Cut all timing paths terminating on data input pin of the first flop din_s1.

    (* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_max_delay -to [get_keepers {*my_std_synchronizer_w_sdc_delay:*|din_s1}] 40\" -name SDC_STATEMENT \"set_min_delay -to [get_keepers {*my_std_synchronizer_w_sdc_delay:*|din_s1}] -15\"  "} *) reg din_s1;

    (* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg [depth-2:0] dreg;    

    always @(posedge clk or negedge reset_n) begin
        if (reset_n == 0) 
            din_s1 <= 1'b0;
        else
            din_s1 <= din;
    end  

    // the remaining synchronizer registers form a simple shift register
    // of length depth-1

    generate
        if (depth < 3) begin
            always @(posedge clk or negedge reset_n) begin
                if (reset_n == 0) 
                    dreg <= {depth-1{1'b0}};      
                else
                    dreg <= din_s1;
            end     
        end else begin
            always @(posedge clk or negedge reset_n) begin
                if (reset_n == 0) 
                    dreg <= {depth-1{1'b0}};
                else
                    dreg <= {dreg[depth-3:0], din_s1};
            end
        end
    endgenerate

    assign dout = dreg[depth-2];
   
endmodule  // my_std_synchronizer
// END OF MODULE