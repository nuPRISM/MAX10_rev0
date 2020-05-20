/****************************************************************************************
*
* Copyright(c) ISSI Inc., 2015
*
* == 128M HyperRAM behavioral Model  ==
*
* Address : 1940 Zanker Road San Jose,CA95112-4216,U.S.A.
* Tel : +1-408-969-6600, Fax : +1-408-969-7800
*
* Revision : Rev0.0 (2015.2.13)
* Revision : Rev0.1 (2017.2.07)
*        - HyperBus Transaction Error    : Modified Sensitive csb signal added
*        - Burst Counter Error           : Modified Burst Decode task
* Revision : Rev0.2 (2017.3.14)
*    - Row address r[ROW_BITS-1:0] error increment when if Column address c[8:0]reaches and 1FF roll back 000.
*     : Modified Row Decode task added
* Revision : Rev0.3 (2017.3.21)
*    - Modified ck2/ck2b change to psc/pscb.
*    - Modified Variable mode and Deep Power Down mode not support.
* Revision : Rev0.4 (2017.5.11)
*    - Configuration Register 0, 1 must be set per each die individually by CA[35] (0 or 1)
*      : Modified CA[35] is added by adding flag signal
*    - When Linear Burst is selected by CA[45], the device cannot advance accross to next die
*      : Modified Row address r[13] is divided into Bank signals Die0 and Die1
*
*
*
* Running Options
*  +S10     : Set AC timing parameter for -10(100MHz )
*  +S75     : Set AC timing parameter for -75(133MHz )
*  +S60     : Set AC timing parameter for -60(166MHz )
*  +VERBOSE : Display internal operation status
*  +OFF_ST  : Phase Shifted Clock enabled
*             (default : Phase Shifted Clock disable)
****************************************************************************************/
`timescale 1ns / 1ps

module IS66WVH16M8ALL (ck, ckb, psc, pscb, csb, dq, rwds,resetb);

        parameter       ROW_BITS        =            14;
        parameter       COL_BITS        =             9;
        parameter       DQ_BITS         =             8;
        parameter       mem_cnt         =            23;
        parameter       mem_width       =             8;
        parameter       mem_sizes       =       8388607;
        parameter VT    =       1;

// Timing Parameter -10 PC100

    `ifdef S10

        parameter       tCK            =  10;
        parameter       tRFH           =  40;
        parameter       tPO            =  40;
        parameter       tDSS           =  0.8;
        parameter       tDSH           =  0.8;
        parameter       tIS            =  1.0;
        parameter       tIH            =  1.0;
        parameter       tRWR           =  40;
        parameter       tCSHI          =  10;
        parameter       tCK2RWDS       =  3.0;
  parameter       SS             =  1;
     `endif

// Timing Parameter -75 PC133

     `ifdef S75

        parameter       tCK            =  7.5;
        parameter       tRFH           =  37.5;
        parameter       tPO            =  37.5;
        parameter       tDSS           =  0.6;
        parameter       tDSH           =  0.6;
        parameter       tIS            =  0.9;
        parameter       tIH            =  0.9;
        parameter       tRWR           =  37.5;
        parameter       tCSHI          =  7.5;
        parameter       tCK2RWDS       =  3.0;
        parameter       SS             =        1;
     `endif

// Timing Parameter -60 PC166

     `ifdef S60

        parameter       tCK            =  6;
        parameter       tRFH           =  36;
        parameter       tPO            =  36;
        parameter       tDSS           =  0.45;
        parameter       tDSH           =  0.45;
        parameter       tIS            =  0.8;
        parameter       tIH            =  0.8;
        parameter       tRWR           =  36;
        parameter       tCSHI          =  6;
        parameter       tCK2RWDS       =        3.0;
        parameter       SS             =        1;


    `endif


// Timing Parameter

  parameter       tCSS            = 3.0;
  parameter tCSM    = 4e3;
  parameter tRP   = 200;
  parameter tRH   = 200;
  parameter tRPH    = 400;
  `ifdef SPEEDSIM
  parameter tVCS    = 10e3;
  `else
  parameter tVCS    = 150e3;
  `endif
  parameter tDPDIN    = 10e3;
  parameter tDPDOUT   = 150e3;
  parameter tDPDCSL   = 200;
  parameter tCKDS   = 2.78;



        `define MAX_BITS   (ROW_BITS+COL_BITS-1)



    // ports
    input                       ck;
    input                       ckb;
    input                       psc;
    input                       pscb;
    input                       csb;
    input     resetb;
    inout         [DQ_BITS-1:0] dq;
    inout     rwds;

    `protect

    `ifdef VERBOSE
  wire  Debug = 1'b1;
    `else
  wire  Debug   = 1'b0;
    `endif


    `ifdef OFF_ST
  wire  IDR_Off_st = (SS==1)? 1'b1: 1'b0;
    `else
  wire  IDR_Off_st = 1'b0;
    `endif


    wire    ck_b = ~ck;
    wire    psc_b =~psc;

    wire      ckb_b;
    wire      pscb_b;

    assign ckb_b = (VT== 1)? ckb: ck_b;

    assign pscb_b = (VT== 1)? pscb : psc_b;



    reg                         diff_ck;

    always @(posedge ck)        diff_ck <= ck;

    always @(posedge ckb_b)     diff_ck <= ~ckb_b;


    reg                         diff_psc;

    always @(posedge psc)        diff_psc <= psc;

    always @(posedge pscb_b)       diff_psc <= ~pscb_b;




    parameter

  CRW_CMD     = 3'b011,
  CRR_CMD_0   = 3'b110,
  CRR_CMD_1   = 3'b111
    ;

    parameter
        WRITE_CMD  = 2'b00,
        READ_CMD   = 2'b10
    ;



//   parameter IDR0_default = 16'b0000_1101_1001_0011; //Die0 [128M]

//Rev0_4
   parameter IDR0_Die1_default = 16'b0100_1101_1001_0011;

   parameter IDR0_Die0_default = 16'b0000_1101_1001_0011;



   parameter IDR1_default = 16'b0000_0000_0000_0000;

//Rev0_4
//   parameter CR0_default = 16'b1000_1111_0001_1111; // (DPD:15) [X], (Variable:3) [X]
//   parameter CR1_default = 16'b0000_0000_0000_0010; //(Distributed refresh :1,0) [default]

   parameter DMIR0_default = 16'b0000_0000_0000_0000;
   parameter DMIR1_default = 16'b0000_0000_0000_0000;
   parameter DMIR2_default = 16'b0000_0000_0000_0000;


   parameter IDR0 = 'b0000;
   parameter IDR1 = 'b0001;
   parameter CR0 = 'b0100;
   parameter CR1 = 'b0101;
   parameter DMIR0 = 'b1000;
   parameter DMIR1 = 'b1001;
   parameter DMIR2 = 'b1010;





    //20150105
    reg IDR0_en,IDR1_en, CR0_en, CR1_en, DMIR0_en, DMIR1_en, DMIR2_en;

    // command address
    reg     [47:0] CA;
    reg     [47:0] CA_in;
    reg     [15:0] CR;
    reg     [15:0] CR_in;

    reg       DPD_CMD;

    reg     [8:0] burst_addr;


    reg                 [3:0]   flag;

    integer     count;


    reg     Data_in_enable;
    reg     Data_out_enable;

    reg     CR_out_enable;

    //internal wire
    wire      csb_in =  csb;

    wire      #1 csb_inn = csb;

    wire      #1 resetb_w = resetb;

    wire      #tCSS csb_ik = csb;

    wire                  [1:0] cmd = { ~csb ? {CA[47], CA[46]} : 'bz};

    wire      [2:0] cmd_R = { ~csb ? {CA[47], CA[46] , CA[45]} : 'bz};

    integer     CL;
    integer     BL;
    reg       BT;
    reg       HB_EN;

//    reg                 [13:0] r; //128M[35:22]

    //Rev0_4
    reg                 [ROW_BITS-1:0] r;

    reg     [8:0] c;

    reg     FL_EN;

    time    ref_col;

    integer   random_delay;

    //Rev0_4
    wire    BA = {r[13] ? 1: 0};

    wire  [15:0]  IDR0_default = { CA_in[35] ? IDR0_Die1_default : IDR0_Die0_default};

    reg   Die0_flag;
    reg   Die1_flag;

    reg   CR0_Die0_flag;
    reg         CR0_Die1_flag;

    reg         CR1_Die0_flag;
    reg         CR1_Die1_flag;

    reg         [15: 0] CR0_Die0;
    reg         [15: 0] CR0_Die1;

    reg         [15: 0] CR1_Die0;
    reg         [15: 0] CR1_Die1;
    
    initial
    begin
    	 CR1_Die0 = 16'h0002;
    	 CR1_Die1 = 16'h0002;
    end


    reg     PWER; //RESETB

    reg     dpd;
    reg     dpd_exit; // dpd exit



    reg     [2:0] out_imp;
    reg     [3:0] Inital_lat;
    reg     Fcl_en;
    reg     HB_en;
    reg     [1:0] Burst_len;
    reg     [1:0] dri;

    reg     [4:0] lat_cnt;
    reg     lat_delay;


//    wire  [15:0]  CR0_reg = {dpd,out_imp[2:0],4'b1111,Inital_lat[3:0],Fcl_en,HB_en,Burst_len[1:0]};

    wire        [15:0]  CR0_reg = {1'b1,out_imp[2:0],4'b1111,Inital_lat[3:0],Fcl_en,HB_en,Burst_len[1:0]};


    wire  [15:0]  CR1_reg = {14'b0000_0000_0000_00,dri[1:0]};
    wire        [15:0]  IDR0_reg = 16'b1000_1100_1001_0011;//128M
//    wire        [15:0]  IDR1_reg = {11'b0000_0000_000,IDR_Off_st,4'b0000};

    wire        [15:0]  IDR1_reg = {11'b0000_0000_000,1'b0,4'b0000};

    wire  [15:0]  DMIR0_reg = 16'b0000_0000_0000_0000;
    wire  [15:0]  DMIR1_reg = 16'b0000_0000_0000_0000;
    wire        [15:0]  DMIR2_reg = 16'b0000_0000_0000_0000;




    // cmd timers/counters
    realtime                    tm_init5;
    realtime                    tm_tRFH_tPO;
    realtime                    tm_tRFH;

    realtime      tm_trwr;
    realtime      tm_clk_period;
    realtime      tm_clk_pos;

    realtime      tm_power_up;

    realtime      tm_tdpd;
    realtime      tm_tdpdx;

    realtime      tm_tRP;
    realtime      tm_tRH;


    reg                   [4:0] init;

    reg                         neg_en;
    reg       neg_enn;
    integer                     i;
    integer                     j;



    wire                  [7:0] dq_in = dq;

    wire      rwds_in;
    assign    rwds_in = rwds;


    reg                       rwds_out;


    reg       rwds_out_en;

    wire    rwds = (rwds_out_en ? rwds_out : 'bz);

    reg       rwds_ref;

    reg   [10:0]    ref_t;


    reg       rwds_out_t;
    reg       rwds_dly;

    reg       rwds_to;

    reg   [8:0]   burst_cnt;

    reg       rwds_out_in;


    reg       rwds_H;
    reg       rwds_L;

    reg       CL_ref;


    reg       ref_cnt;


    reg                  [7:0] dq_in_pos;
    reg                  [7:0] dq_in_neg;


    reg                  [7:0] dq_out_pos;
    reg                  [7:0] dq_out_neg;


    reg     rwds_init;

    reg      [7:0] dq_in_dummy;

    // transmit
    reg                         dq_out_en;

    reg       dq_out_en_dly;
    reg          [DQ_BITS-1:0]  dq_out;


    reg     [10:0]  as_bl;

    wire [DQ_BITS-1:0] dq = (dq_out_en ? dq_out :'bz);

    wire enable =  ~dq_out_en && ~csb_inn;


    reg   AS;
    reg   R_W;

    reg   CONT;


    reg     [15:0]  dq_tmp;

    reg     [15:0]  dq_temp;


    reg [mem_width - 1 : 0]      mem_array0 [0 : mem_sizes - 1] ;
    reg [mem_width - 1 : 0]      mem_array1 [0 : mem_sizes - 1] ;

    reg [mem_cnt - 1: 0]  memiadr;

    function  real min_clk_period;

  input [3:0] Inital_lat;

  begin

  min_clk_period = 0.0;

  `ifdef S12

    case(Inital_lat)

      4'b0000 : min_clk_period = 7.50;
      4'b0001 : min_clk_period = 6.00;
      4'b1110 : min_clk_period = 12.00;
      4'b1111 : min_clk_period = 10.00;


    endcase

  `else `ifdef S10

                case(Inital_lat)

                        4'b0000 : min_clk_period = 7.50;
                        4'b0001 : min_clk_period = 6.00;
      4'b1110 : min_clk_period = 0.00;
                        4'b1111 : min_clk_period = 10.00;


                endcase
  `else `ifdef S75

                case(Inital_lat)

                        4'b0000 : min_clk_period = 7.50;
                        4'b0001 : min_clk_period = 6.00;
      4'b1110 : min_clk_period = 0.00;
                        4'b1111 : min_clk_period = 0.00;

                endcase

        `else `ifdef S60

                case(Inital_lat)
      4'b0000 : min_clk_period = 0.00;
                        4'b0001 : min_clk_period = 6.00;
      4'b1110 : min_clk_period = 0.00;
                        4'b1111 : min_clk_period = 0.00;

                endcase

  `endif `endif `endif `endif

  end

     endfunction





    // initial state
    initial begin

  $timeformat(-9,3,"ns",12);


  i =0;

  mem_init;

        init = 1;
        neg_en = 0;
  neg_enn = 0;

        dq_out_en = 0;
  dq_out_en_dly = 0;


  as_bl = 0;


  rwds_H = 0;
  rwds_L = 0;

  dq_tmp =0;

  dq_temp = 0;

  rwds_out_en =0;
  rwds_ref = 0;
        rwds_dly = 0;

  rwds_to = 0;

  rwds_init = 0;

  FL_EN = 1;
  CA = 0;

  BT = 0;

  ref_t = 0;

  ref_cnt = 0;

  Data_in_enable = 0;
  Data_out_enable = 0;

  CR_out_enable = 0;

//Rev0_4
//  config_reg_write(CR0, CR0_default, 1'b1);
//  config_reg_write(CR1, CR1_default, 1'b1);

//  config_reg_read (IDR0,IDR0_default);
//      config_reg_read (IDR1,IDR1_default);
//      config_reg_read (DMIR0,DMIR0_default);
//      config_reg_read (DMIR1,DMIR1_default);
//      config_reg_read (DMIR2,DMIR2_default);

        CA_in = 0;
  CR_in = 0;

  CR0_en =0;
  CR1_en =0;
  IDR0_en = 0;
  IDR1_en = 0;
  DMIR0_en = 0;
  DMIR1_en = 0;
  DMIR2_en = 0;

  CR = 0;

        AS = 0;
    R_W = 1;
  dq_in_pos = 0;
  dq_in_neg = 0;

        dq_out_pos = 0;
        dq_out_neg = 0;



  dq_in_dummy = 'hff;

  burst_cnt = 0;

  dq_out = 'hff;

  lat_cnt    = 0;
  lat_delay  = 0;
  rwds_out_t = 0;

  rwds_out_in = 0;

  rwds_out = 'bz;

  CL_ref = 0;

  tm_power_up <= 0.0;

  dpd_exit = 0;

  PWER = 0;


       ref_col <= 0;

  //20170208
       dpd = 1;

        flag = 0;


  //Rev0_4

        CR0_Die0_flag =0;
        CR0_Die1_flag =0;
        CR1_Die0_flag =0;
        CR1_Die1_flag =0;
    end



   always @(csb) begin



  if(!csb) begin

    if($realtime - tm_power_up < tVCS)

      $display ("%t Wran : tVCS violation CSB# by %t ", $realtime, tm_power_up + tVCS-$realtime);

   end

//    tm_tdpd <= $realtime;

   end



   always @(csb)  begin

  if(!csb) begin

    random_delay <= 0;
    ref_cnt <=0;

  end

/*
  if(!csb_inn && csb) begin

                if(!dpd) begin

                        if(Debug)

                                $display("%t INFO : DPD [Deep Power Down] Entry", $realtime);

                                mem_init;

                        end


                if(dpd_exit)  begin


                        if($realtime - tm_tdpdx < tDPDCSL)

                                $display("%t Error : tDPDCSL violation on CSB# by %t", $realtime, tm_tdpdx+tDPDCSL-$realtime);

                                        dpd_exit = 1'b0;

                                        tm_power_up <= $realtime;

                end

        end else if(csb_inn && !csb) begin


                        if(!dpd) begin

                         config_reg_write(CR0, CR0_reg | 16'h8f1f , 1'b1);

                  if(dpd && CR0_reg[15])

                        begin

                           begin

                                if($realtime - tm_tdpd < tDPDIN)

                                        $display("%t Error : tDPD violation on csb# by %t",$realtime,tm_tdpd + tDPDIN - $realtime);

                                        dpd_exit = 1'b1;

                                        tm_tdpdx <= $realtime;

                                end

                                if(Debug)

                                        $display("%t INFO : DPD [Deep Power Down] EXIT", $realtime);

                                end




                        end


        end
*/

  end





  always @(resetb) begin

    if(!resetb && resetb_w) begin

        PWER <= 1;

        tm_tRP <= $realtime;

/*
      if(!dpd) begin
        config_reg_write(CR0, CR0_reg | 16'h8f1f , 1'b1);


                        if(dpd && CR0_reg[15])

                        begin

                           begin

                                if($realtime - tm_tdpd < tDPDIN)

                                        $display("%t Error : tDPD violation on csb# by %t",$realtime,tm_tdpd + tDPDIN - $realtime);

                                        dpd_exit = 1'b1;

                                        tm_tdpdx <= $realtime;

                                end

                                if(Debug)

                                        $display("%t INFO : DPD [Deep Power Down] EXIT", $realtime);

                                end

/////
      end

*/

    end

    else if(dpd_exit || (resetb && !resetb_w)) begin


      if(resetb && !resetb_w) begin

        if($realtime - tm_tRP < tRP)

                                  $display("%t Error : tRP violation on RESETB by %t", $realtime, tm_tRP+tRP - $realtime);

                                    PWER <= 0;
      end


/*
                  if(dpd_exit)  begin

                          if($realtime - tm_tdpdx < tDPDCSL)

                                  $display("%t Error : tDPDCSL violation on CE# by %t", $realtime, tm_tdpdx+tDPDCSL-$realtime);

                                        dpd_exit = 1'b0;
      end

*/

      if(tm_power_up == 0.0 && !PWER) begin //

        tm_power_up <= $realtime;
      end //

                end



  end


   always @(posedge diff_ck) begin

  if($realtime > tCK) begin

    if(!csb_in) begin

      tm_clk_period = min_clk_period(Inital_lat[3:0]);

    if(tm_clk_period == 0.0)

      //$display("%t Error : Illegal latency counter = %b", $realtime, Inital_lat);

    if($realtime - tm_clk_pos < tm_clk_period)

  $display("%t Error : CK period Must >= %f While Latency count = %b. ACT CK period %f", $realtime,tm_clk_period,Inital_lat,$realtime-tm_clk_pos);

    end

  end

  tm_clk_pos = $realtime - 0.0001;

   end


   always @(diff_ck) begin

      if(dq_out_en == 1 && csb_inn ==0  ) begin
                dq_out_en_dly = 1;

        end

        else
                begin

                dq_out_en_dly = 0;

        end

   end

   always @(diff_ck) begin

      if(rwds_out_t == 1 && csb_inn ==0  ) begin
                rwds_init = 1;

        end

        else
                begin

                rwds_init = 0;

        end

   end



  always @(diff_ck) begin

    if(IDR_Off_st == 0 && rwds_out_t == 1) begin

      rwds_to <= #tCKDS (diff_ck && dq_out_en_dly ) ;

          end


  end


  always @(diff_psc) begin

    if(IDR_Off_st== 1 && rwds_out_t == 1) begin

      rwds_to <= #tCK2RWDS (diff_psc && dq_out_en_dly ) ;

                end

  end



    always @(diff_ck) begin



  if(!FL_EN &&($time - ref_col >= tCSM)) begin

    ref_col <= $time;

    random_delay = ($random % (CL-1));


    if(random_delay > 0) begin

      ref_cnt <= 1;

      if(Debug)

      $display ("%t INFO : Refresh Collision %d",$realtime,random_delay);

    end else
    begin
      ref_cnt <= 0;
    end


  end

   end


   always @(csb &&!csb_inn)

  begin

        CL_ref <= ref_cnt;

  tm_trwr <= $realtime;

  end




   always @(!csb)
  begin


  assign rwds_out_en = (!csb_ik) ? 1'b1: 1'b0;


  if(csb && !csb_ik) begin

    assign rwds_out_en = 0;
  end


  assign rwds_out = ((!csb_ik) &&  (FL_EN == 1) ||((FL_EN == 0) && (CL_ref == 1))) ? 1'b1 : 1'b0;



  end
   always @(diff_ck) begin

  if (ck | ckb_b) begin
            // initialization

            case (init)

                1 : begin
                    // CA0 /CA1/CA2 Command / Address Bit Assignments

                    if (!csb_in) begin

                        CA[47:40]  = dq_in[7:0];
      R_W <= CA[47];
      AS  <= CA[46];
      //BT <= CA[45];

      if(AS == 0)
      BT<= CA[45];

                        init = 2;

      assign rwds_ref = ((FL_EN == 1) |((FL_EN == 0) && (CL_ref == 1)) && (!csb_in)) ? 1'b1 : 1'b0;


                    end


                end
                2 : begin
       if (!csb_in) begin
                        CA[39:32] = dq_in[7:0];

      //Rev0_4
      if(CA[35]== 1) begin
        Die1_flag = 1;
        Die0_flag = 0;
      end
      else begin
        Die0_flag = 1;
        Die1_flag = 0;
      end


                        init = 3;



        end

                end
                3 : begin
                   if (!csb_in) begin
                        CA[31:24] = dq_in[7:0];
                        init = 4;



                    end

    end

                4 : begin
                   if (!csb_in) begin
                        CA[23:16] = dq_in[7:0];
                        init = 5;
                        tm_init5 <= $realtime;

      if($realtime - tm_trwr < tRWR-1.00)

        $display("%t Error :  tRWR violation by  %t ", $realtime, tm_trwr + (tRWR-1.00) - $realtime);


                    end


                end
                5 : begin
                   if (!csb_in) begin
                        CA[15:8] = dq_in[7:0];
                        init = 6;


                    end


                end


                6 : begin
                   if (!csb_in) begin
                        CA[7:0] = dq_in[7:0];



      if(AS == 1) begin
        case({CA[28],CA[24],CA[1],CA[0]})
          'b0000 : IDR0_en <= 1;
          'b0001 : IDR1_en <= 1;
          'b0100 : CR0_en <= 1;
          'b0101 : CR1_en <= 1;
          'b1000 : DMIR0_en <= 1;
          'b1001 : DMIR1_en <= 1;
          'b1010 : DMIR2_en <= 1;
        endcase
      end

                    end

        if((AS == 1)&& (R_W == 0) &&(csb_in==0)) begin

      init = 7;
        end else begin
          init = 9;
        end

      assign rwds_out = ((R_W == 1) ? 'b0: 'bz);


    end

    7 : begin

        if(!csb_in) begin
                        CR[15:8] = dq_in[7:0];
                        init = 8;


                    end
                    if(CR[15] == 0) begin
//      DPD_CMD = 1;

         end
         else begin
      DPD_CMD = 0;
         end
                end



    8 : begin

         if(!csb_in && init==8) begin
      CR[7:0] = dq_in[7:0];
      init = 1;
      AS <= 0;

         end


                end




            endcase



    CA_in[47:0] <= CA[47:0];
    CR_in[15:0] <= CR[15:0];



            casex ({csb_in, cmd_R})

                {1'b0, CRW_CMD} : begin



       if((CR0_en==1) && (init ==1))

         begin

//
                         if(Die0_flag==1) begin

                                CR0_Die0_flag = 1'b1;

                                CR0_Die0 = CR[15:0];

                                $display( "%t Configuration Register 0 Die0 Setting %h ",$realtime,CR0_Die0[15:0] );
                         end

                        if(Die1_flag==1) begin

                                CR0_Die1_flag = 1'b1;
                                CR0_Die1 = CR[15:0];
                                $display( "%t Configuration Register 0 Die1 Setting %h ",$realtime,CR0_Die1[15:0] );

                         end



      if((CR0_Die0_flag ==1'b1) &&  (CR0_Die1_flag==1'b1)) begin

        if(!(CR0_Die0[15:0] == CR0_Die1[15:0])) begin

        $display( "%t Configuration Register 0 Die0 setting [%h], Die1 Setting [%h] ",$realtime,CR0_Die0[15:0], CR0_Die1[15:0]);

        end
      end

//

      config_reg_write (CR0, CR[15:0],1);
      CR0_en = 0;

       end


       if((CR1_en==1) && (init ==1))
                   begin

//
                         if(Die0_flag==1) begin

                                CR1_Die0_flag = 1'b1;

                                CR1_Die0 = CR[15:0];

                                $display( "%t Configuration Register 1 Die0 Setting %h ",$realtime,CR1_Die0[15:0] );
                         end

                        if(Die1_flag==1) begin

                                CR1_Die1_flag = 1'b1;
                                CR1_Die1 = CR[15:0];
                                $display( "%t Configuration Register 1 Die1 Setting %h ",$realtime,CR1_Die1[15:0] );

                         end



                        if((CR1_Die1_flag ==1'b1) &&  (CR1_Die1_flag==1'b1)) begin

                                if(!(CR1_Die0[15:0] == CR1_Die1[15:0])) begin

                                $display( "%t Configuration Register 1 Die0 setting [%h], Die1 Setting [%h] ",$realtime,CR1_Die0[15:0], CR1_Die1[15:0]);

                                end
                        end


//
      config_reg_write (CR1, CR[15:0],1);
      CR1_en = 0;

       end

                end



                {1'b0, CRR_CMD_0} : begin

                   if(IDR0_en== 1 && init == 9)
                   begin
                        config_reg_read (IDR0,IDR0_default);
      dq_in_pos = IDR0_default[15:8];
                        dq_in_neg = IDR0_default[7:0];
      IDR0_en = 0;
                   end
                   if(IDR1_en== 1&& init == 9)
                   begin

                        config_reg_read (IDR1,IDR1_reg);
                        dq_in_pos = IDR1_reg[15:8];
                        dq_in_neg = IDR1_reg[7:0];


      IDR1_en = 0;
                   end
/*
                   if(CR0_en ==1 &&( init ==9))
                   begin
                        config_reg_write(CR0,CR0_reg,1);
      dq_in_pos = CR0_reg[15:8];
      dq_in_neg = CR0_reg[7:0];
      CR0_en = 0;
                   end


                   if(CR1_en == 1 &&  init == 9)
                   begin
                        config_reg_write (CR1,CR1_reg,1);
                        dq_in_pos = CR1_reg[15:8];
                        dq_in_neg = CR1_reg[7:0];
      CR1_en = 0;
                   end
*/

///
    //Rev0_4
                   if(CR0_en ==1 &&( init ==9))
                   begin

                        if(Die1_flag == 1) begin

                        config_reg_write(CR0,CR0_Die1,1);
                        dq_in_pos = CR0_Die1[15:8];
                        dq_in_neg = CR0_Die1[7:0];
                        CR0_en = 0;

                        end else if(Die0_flag == 1) begin

                        config_reg_write(CR0,CR0_Die0,1);
                        dq_in_pos = CR0_Die0[15:8];
                        dq_in_neg = CR0_Die0[7:0];
                        CR0_en = 0;

                        end

                        if(!(CR0_Die0[15:0] == CR0_Die1[15:0])) begin

                                $display($time, " Configuration Register 0 Die0 [%h], Die1 [%h] Setting Error ",CR0_Die0[15:0],CR0_Die1[15:0]);

                        end

                    end

                   if(CR1_en == 1 &&  init == 9)
                   begin
                        if(Die1_flag == 1) begin

                        config_reg_write(CR1,CR1_Die1,1);
                        dq_in_pos = CR1_Die1[15:8];
                        dq_in_neg = CR1_Die1[7:0];
                        CR1_en = 0;

                        end else if(Die0_flag == 1) begin

                        config_reg_write(CR1,CR1_Die0,1);
                        dq_in_pos = CR1_Die0[15:8];
                        dq_in_neg = CR1_Die0[7:0];
                        CR1_en = 0;

                        end

                        if(!(CR1_Die0[15:0] == CR1_Die1[15:0])) begin

                                $display($time, " Configuration Register 1 Die0 [%h], Die1 [%h] Setting Error ",CR1_Die0[15:0],CR1_Die1[15:0]);

                        end

                   end



///
                   if(DMIR0_en == 1 && init == 9)
                   begin
                        config_reg_read (DMIR0,DMIR0_default);
                        dq_in_pos = DMIR0_default[15:8];
                        dq_in_neg = DMIR0_default[7:0];
      DMIR0_en = 0;
                   end
                   if(DMIR1_en == 1 && init == 9 )
                   begin
                        config_reg_read (DMIR1,DMIR1_default);
                        dq_in_pos = DMIR1_default[15:8];
                        dq_in_neg = DMIR1_default[7:0];

      DMIR1_en = 0;
                   end
                   if(DMIR2_en == 1 && init == 9)
                   begin
                        config_reg_read (DMIR2,DMIR2_default);
                        dq_in_pos = DMIR2_default[15:8];
                        dq_in_neg = DMIR2_default[7:0];

      //20170209
      DMIR2_en = 0;
                   end

        neg_en <= 1'b1;
        neg_enn <= 1'b1;

      as_bl <= 1;


                end
                {1'b0, CRR_CMD_1} : begin

                   if(IDR0_en== 1 && init == 9)
                   begin
                        config_reg_read (IDR0,IDR0_default);
                        dq_in_pos = IDR0_default[15:8];
                        dq_in_neg = IDR0_default[7:0];
                        IDR0_en = 0;
                   end
                   if(IDR1_en== 1&& init == 9)
                   begin

                        config_reg_read (IDR1,IDR1_reg);
                        dq_in_pos = IDR1_reg[15:8];
                        dq_in_neg = IDR1_reg[7:0];


                        IDR1_en = 0;
                   end

/*
                   if(CR0_en ==1 &&( init ==9))
                   begin
                        config_reg_write(CR0,CR0_reg,1);
                        dq_in_pos = CR0_reg[15:8];
                        dq_in_neg = CR0_reg[7:0];
                        CR0_en = 0;
                   end


                   if(CR1_en == 1 &&  init == 9)
                   begin
                        config_reg_write (CR1,CR1_reg,1);
                        dq_in_pos = CR1_reg[15:8];
                        dq_in_neg = CR1_reg[7:0];
                        CR1_en = 0;
                   end
*/

////
       //Rev0_4
                   if(CR0_en ==1 &&( init ==9))

                   begin

                        if(Die1_flag == 1) begin

                        config_reg_write(CR0,CR0_Die1,1);
                        dq_in_pos = CR0_Die1[15:8];
                        dq_in_neg = CR0_Die1[7:0];
                        CR0_en = 0;

                        end else if(Die0_flag == 1) begin

                        config_reg_write(CR0,CR0_Die0,1);
                        dq_in_pos = CR0_Die0[15:8];
                        dq_in_neg = CR0_Die0[7:0];
                        CR0_en = 0;

                        end

                        if(!(CR0_Die0[15:0] == CR0_Die1[15:0])) begin

                                $display($time, " Configuration Register 0 Die0 [%h], Die1 [%h] Setting Error ",CR0_Die0[15:0],CR0_Die1[15:0]);

                        end

                    end

                   if(CR1_en == 1 &&  init == 9)
                   begin
                        if(Die1_flag == 1) begin

                        config_reg_write(CR1,CR1_Die1,1);
                        dq_in_pos = CR1_Die1[15:8];
                        dq_in_neg = CR1_Die1[7:0];
                        CR1_en = 0;

                        end else if(Die0_flag == 1) begin

                        config_reg_write(CR1,CR1_Die0,1);
                        dq_in_pos = CR1_Die0[15:8];
                        dq_in_neg = CR1_Die0[7:0];
                        CR1_en = 0;

                        end

                        if(!(CR1_Die0[15:0] == CR1_Die1[15:0])) begin
                             $display($time, " Configuration Register 1 Die0 [%h], Die1 [%h] Setting Error ",CR1_Die0[15:0],CR1_Die1[15:0]);
                        end

                   end


////
                   if(DMIR0_en == 1 && init == 9)
                   begin
                        config_reg_read (DMIR0,DMIR0_default);
                        dq_in_pos = DMIR0_default[15:8];
                        dq_in_neg = DMIR0_default[7:0];
                        DMIR0_en = 0;
                   end
                   if(DMIR1_en == 1 && init == 9 )
                   begin
                        config_reg_read (DMIR1,DMIR1_default);
                        dq_in_pos = DMIR1_default[15:8];
                        dq_in_neg = DMIR1_default[7:0];

                        DMIR1_en = 0;
                   end
                   if(DMIR2_en == 1 && init == 9)
                   begin
                        config_reg_read (DMIR2,DMIR2_default);
                        dq_in_pos = DMIR2_default[15:8];
                        dq_in_neg = DMIR2_default[7:0];
      //20170209
                        DMIR2_en = 0;
                   end
                    neg_en <= 1'b1;
                    neg_enn <= 1'b1;

                        as_bl <= 1;


                end



  endcase

            casex ({csb_in, cmd})

            {1'b0, WRITE_CMD} : begin
            //Rev0_4
               if(CR0_Die0 == CR0_Die1 ) begin
               end else begin
                  $display( "%t Configuration Register 0 Die0,Die1 Setting Error ",$realtime );
               end

               if(CR1_Die0 == CR1_Die1 ) begin
               end else begin
                  $display( "%t Configuration Register 1 Die0,Die1 Setting Error ",$realtime );
               end
//

               if(init==9 && csb_in==0) begin
                    r = CA[35:22]; //128M

                    c = {CA[21:16],CA[2:0]};
                end

                as_bl = BL;

                neg_en <= 1'b1;
                neg_enn <= 1'b1;
             end
            {1'b0, READ_CMD} : begin

////////

      //Rev0_4
                if(CR0_Die0 == CR0_Die1 ) begin
                end else begin
                   $display( "%t Configuration Register 0 Die0,Die1 Setting Error ",$realtime );
                end

                if(CR1_Die0 == CR1_Die1 ) begin
                end else begin
                    $display( "%t Configuration Register 1 Die0,Die1 Setting Error ",$realtime );
                end


///////

                if(init==9 && csb_in==0) begin
                    r = CA[35:22]; //128M

                    c = {CA[21:16],CA[2:0]};
                    end

                        as_bl = BL;

                        neg_en <= 1'b1;
      neg_enn <= 1'b1;

                end


          endcase



        end


    end






  always @(diff_ck) begin
         if (ck   && init ==9 && csb_in == 0) begin

      lat_cnt = lat_cnt + 1;

      casex(cmd_R[2:0])
    3'b110 : begin

      if(rwds_ref == 1) begin

                        ref_t = (CL*2)-1;
                        end
                        else begin

                        ref_t = CL-1;

                        end

                        if( lat_cnt >= ref_t && (csb_in==0) ) begin
                                lat_delay = 1;
                        end
                        else begin
                                lat_delay = 0;
                        end

                        if(lat_delay==1 && csb_in == 0 )begin

                                rwds_out_t = neg_en;
                                CR_out_enable = 1;
                                if(rwds_ref == 1)
                                begin
                                tm_tRFH_tPO <= $realtime;
                                if($realtime - tm_init5+(0.5*tCK) < tRFH+tPO )
                                $display( "%t Error CR tRFH+tPO violation on by %t ",$realtime, (tm_init5 -(0.5*tCK))+ tRFH+tPO - $realtime);
                                end

                                else begin

                                tm_tRFH <= $realtime;
                          if($realtime - tm_init5+(0.5*tCK) < tRFH )
                                $display( "%t Error CR tRFH violation on by %t ",$realtime, (tm_init5 -(0.5*tCK))+ tRFH - $realtime);

                                end
                        end

                end

                3'b111 : begin

                        if(rwds_ref == 1) begin

                        ref_t = (CL*2)-1;
                        end
                        else begin

                        ref_t = CL-1;

                        end

                        if( lat_cnt >= ref_t && (csb_in==0) ) begin
                                lat_delay = 1;
                        end
                        else begin
                                lat_delay = 0;
                        end

                        if(lat_delay==1 && csb_in == 0 )begin

                                rwds_out_t = neg_en;
                                CR_out_enable = 1;
                                if(rwds_ref == 1)
                                begin
                                tm_tRFH_tPO <= $realtime;
                                if($realtime - tm_init5+(0.5*tCK) < tRFH+tPO )
                                  $display( "%t Error CR tRFH+tPO violation on by %t ",$realtime, (tm_init5 -(0.5*tCK))+ tRFH+tPO - $realtime);
                                end

                                else begin

                                tm_tRFH <= $realtime;
                          if($realtime - tm_init5+(0.5*tCK) < tRFH )
                                  $display( "%t Error CR tRFH violation on by %t ",$realtime, (tm_init5 -(0.5*tCK))+ tRFH - $realtime);

                                end
                        end

                end




          endcase

    casex (cmd[1:0])
                2'b00 : begin // WRITE

                        if(rwds_ref) begin

                        ref_t = CL*2-1;
                        end
                        else begin

                        ref_t = CL-1;

                        end


      if( lat_cnt >= ref_t && (csb_inn==0) ) begin
        lat_delay = 1;
                        end
                        else begin
                                lat_delay = 0;
                        end

      if(lat_delay==1 && csb_inn == 0 )begin


        rwds_out_in = neg_enn;
        Data_in_enable = 1;

        count = 1;

                                if(rwds_ref == 1)
                                begin
                                tm_tRFH_tPO <= $realtime;

        if($realtime - tm_init5+(0.5*tCK) < tRFH+tPO )

                                $display( "%t Error WT tRFH +tPO violation on by %t ",$realtime, (tm_init5 -(0.5*tCK))+ tRFH+tPO - $realtime);
                                end

                                else begin

                                tm_tRFH <= $realtime;


                          if($realtime - tm_init5+(0.5*tCK) < tRFH )

                                $display( "%t Error WT tRFH violation on by %t ",$realtime, (tm_init5 -(0.5*tCK))+ tRFH - $realtime);

                                end



                        end


                end

                2'b10 : begin // READ

                        if(rwds_ref) begin

                        ref_t = (CL*2)-1;
                        end
                        else begin

                        ref_t = CL-1;

                        end

      if( lat_cnt >= ref_t && (csb_inn==0) ) begin
                                lat_delay = 1;
                        end
                        else begin
                                lat_delay = 0;
                        end

      if(lat_delay==1 && csb_inn == 0 )begin
                                rwds_out_t = neg_en;

        Data_out_enable = 1;

        count = 1;

                                if(rwds_ref == 1)
                                begin
                                tm_tRFH_tPO <= $realtime;

        if($realtime - tm_init5+(0.5*tCK) < tRFH+tPO )

                                $display( "%t Error RD tRFH +tPO  violation on by %t ",$realtime, (tm_init5 -(0.5*tCK))+ tRFH+tPO - $realtime);
                                end

                                else begin

                                tm_tRFH <= $realtime;


                          if($realtime - tm_init5+(0.5*tCK) < tRFH )

                                $display( "%t Error RD tRFH violation on by %t ",$realtime, (tm_init5 -(0.5*tCK))+ tRFH - $realtime);

                                end



                        end

      else if(csb_inn ==1) begin
        rwds_out_t = 0;
                                Data_out_enable = 0;

      end


    end


            endcase
            neg_en = 1'b0;
      neg_enn <= 1'b0;



        end




   end //always


  always @(diff_ck or csb_in) begin


  if(lat_delay== 1 && csb_in ==0 ) begin

    init = 10;



  end

        else if(csb_in == 1) begin

    init = 1;
    neg_en = 0;

    neg_enn = 0;
    lat_delay = 0;
    rwds_out_t = 0;
    AS = 0;
    CA = 0;
    dq_out = 'hff;

    dq_in_pos = 'h0;
    dq_in_neg = 'h0;

    dq_out_pos = 'h0;
                dq_out_neg = 'h0;


    lat_cnt = 0;


    Data_in_enable = 0;

    Data_out_enable = 0;


    CR_out_enable = 0;

    count = 0;


    burst_cnt = 0;


    rwds_out_in = 0;


    rwds_init = 0;

    dq_out_en = 0;

    c = 0;

    rwds_H = 0;
    rwds_L = 0;

                R_W = 'bz;
                rwds_to = 0;


    flag = 0;

  end



  if(Data_in_enable == 1 && neg_enn==1 ) begin



  if(diff_ck==1) begin


    dq_in_pos[7:0] = dq_in[7:0];
    rwds_H = rwds_in;

  end
        if(diff_ck==0 ) begin

    dq_in_neg[7:0]= dq_in[7:0];
          rwds_L = rwds_in;

  end

  if(diff_ck==0) begin


    dq_tmp[15:0] = {dq_in_pos[7:0],dq_in_neg[7:0]};

      memory_write_H (r,c,dq_tmp[15:8],rwds_H);

      memory_write_L (r,c,dq_tmp[7:0],rwds_L);


                if(c[8:0] == 'h1ff) begin
                        flag[0] = 1'b1;
                end




          if(Debug)

          $display($time, " WRITE : row [%h] col[%h]  [data [%h],rwds [%b]] == [data[%h],rwds [%b]] ", r, c,dq_tmp[15:8],rwds_H,dq_tmp[7:0],rwds_L);


//                if( c < as_bl && csb_inn == 0 && init==10 ) begin

                if( csb_in == 0 && init==10 ) begin

      Row_Decode;

      Burst_Decode;

    end
//      c = c+ 1;

  end

end


   if(Data_out_enable == 1 ) begin

    if(rwds_out_t == 1 && csb_inn == 0)
          begin

       assign rwds_out = rwds_to;

          end

          else

    assign rwds_out = 1'b0;

    if(rwds_out_t == 1 && csb_inn ==0 )

            #tIS  dq_out_en = 1;
          else
                          dq_out_en = 0;



  if(dq_out_en_dly == 1) begin


                dq_out_neg[7:0] = memory_read_L (r,c);
                dq_out_pos[7:0] = memory_read_H (r,c);



    if(rwds_out) begin

//    if(c < as_bl && csb_inn == 0 && init==10 ) begin

                if(csb_in == 0 && init==10 ) begin


                        if(c[8:0] == 'h1ff) begin

                                flag[0] = 1'b1;
                        end


                        if(Debug)

                        $display($time, " READ : row [%h]   col [%h]   data [%h] ", r, c,{dq_out_pos[7:0],dq_out_neg[7:0]});

      Row_Decode;

                        Burst_Decode;

                end
//                        c = c + 1;
//                  if(Debug)
//                  $display($time, " READ : row [%h]   col [%h]   data [%h] ", r, c,{dq_out_pos[7:0],dq_out_neg[7:0]});


    end
        end



  end




  if((AS == 1) && (R_W == 1)&& (CR_out_enable == 1)) begin

          if(rwds_out_t == 1 && csb_inn == 0 )

          begin

       assign rwds_out = rwds_to;



          end

  else
    assign rwds_out = 0;



        if(rwds_out_t == 1 && csb_inn ==0 )

      #tIS dq_out_en = 1;

  else
      dq_out_en = 0;


  if(rwds_out) begin


    if(burst_cnt < as_bl && csb_inn == 0 && init==10 ) begin

      burst_cnt = burst_cnt + 1;


    end else begin

      burst_cnt = 0;
    end


  end



   end



 end




  always @(posedge rwds_out) begin

    if(rwds_init == 1 && AS==1 && CR_out_enable == 1 ) begin

      dq_out[7:0] =  dq_in_pos[7:0];



    end

  end

        always @(negedge rwds_out) begin

                if(rwds_init == 1 && AS==1 && CR_out_enable == 1 ) begin

      dq_out[7:0] =  dq_in_neg[7:0];


                end

        end





        always @(posedge rwds_out) begin

                if(rwds_init == 1 && dq_out_en == 1  && Data_out_enable==1 ) begin


                        dq_out[7:0] =  dq_out_pos[7:0];


                end

        end

        always @(negedge rwds_out) begin

                if(rwds_init == 1 && dq_out_en == 1  && Data_out_enable==1  ) begin

                        dq_out[7:0] =  dq_out_neg[7:0];


                end

        end




    task Burst_Decode;

  begin

                if(BT)begin
      c[8:0] = c[8:0] + 1;

      if(c[8:0] == 'h1ff) begin
                                flag[3] = 1'b1;
                        end

                end
                else
                if(HB_EN==0) begin
                        case(BL)

      8 : begin
                                if(count < 8) begin
                                        c[8:3] = c[8:3];
                                        c[2:0] = c[2:0] + 1;

                                        if(c[8:0] == 'h1ff) begin
                                                flag[1] = 1'b1;
                                        end


                                end

                                if(count == 8) begin

                                        c[2:0] = c[2:0] && 'b000;

                                        c[8:3] = c[8:3] +1;
                                end

                                if(count >8) begin

                                        c[8:0] = c[8:0] + 1 ;

                                end

                                if(count >8 && (c[8:0] == 'h1ff)) begin

                                        flag[2] = 1'b1 ;

                                end





           end
      16 : begin

                                if(count <16) begin
                                        c[8:4] = c[8:4];
                                        c[3:0] = c[3:0] +1;

                                        if(c[8:0] == 'h1ff) begin
                                                flag[1] = 1'b1;
                                        end

                                end

                                if(count == 16) begin

                                        c[3:0] = c[3:0] && 'b0000;

                                        c[8:4] = c[8:4] +1;
                                end

                                if(count >16) begin

                                        c[8:0] = c[8:0] + 1 ;

                                end

                                if(count >16 && (c[8:0] == 'h1ff)) begin

                                        flag[2] = 1;

                                end


           end

                        32: begin

                                if(count <32) begin
                                        c[8:5] = c[8:5];
                                        c[4:0] = c[4:0] + 1;

                                        if(c[8:0] == 'h1ff) begin
                                                flag[1] = 1'b1;
                                        end


                                end

                                if(count == 32) begin

                                        c[4:0] = c[4:0] && 'b00000;

                                        c[8:5] = c[8:5] +1;
                                end

                                if(count >32) begin

                                        c[8:0] = c[8:0] + 1 ;

                                end


                                if(count >32 && (c[8:0] == 'h1ff)) begin
                                        flag[2] = 1'b1;

                                end




          end

      64 : begin

                                if(count <64) begin
                                        c[8:6] = c[8:6];
                                        c[5:0] = c[5:0] + 1;


                                        if(c[8:0] == 'h1ff) begin
                                                flag[1] = 1'b1;
                                        end



                                end

                                if(count == 64) begin

                                        c[5:0] = c[5:0] && 'b000000;

                                        c[8:6] = c[8:6] +1;
                                end

                                if(count >64) begin

                                        c[8:0] = c[8:0] + 1 ;

                                end

                                if(count >64 && (c[8:0] == 'h1ff)) begin
                                        flag[2] = 1'b1;

                                end


           end
      endcase

      end

        else

              if(HB_EN==1) begin
                        case(BL)
                                8 : begin //16
                                        c[8:3] = c[8:3];
                                        c[2:0] = c[2:0] + 1;
                                    end

                                16: begin //32
                                        c[8:4] = c[8:4];
                                        c[3:0] = c[3:0] + 1;
                                    end
                                32: begin //64
                                        c[8:5] = c[8:5];
                                        c[4:0] = c[4:0] + 1;

                                   end
                                64: begin //128
                                        c[8:6] = c[8:6];
                                        c[5:0] = c[5:0] + 1;

                                    end

                        endcase
                end

    count = count + 1;

        end

  endtask


    task Row_Decode;

        begin

        if(BT) begin

                 if((flag[3] ==1) && (c[8:0] == 'h1ff)) begin

                        //r[ROW_BITS-1:0] = r[ROW_BITS-1:0] + 1;

      //Rev0_4
      if(BA == 1) begin
                        r[ROW_BITS-2:0] = r[ROW_BITS-2:0] + 1;
      end

      else if(BA == 0) begin
                        r[ROW_BITS-2:0] = r[ROW_BITS-2:0] + 1;
      end

                end

                        flag = 0;

        end else
        if(HB_EN == 0) begin

                case(BL)

                8 : begin

                        if(count > 7) begin

                                if((flag[0] == 1) || (flag[1] == 1)|| (flag[2] == 1)) begin

                                       // r[ROW_BITS-1:0] = r[ROW_BITS-1:0] + 1;

                            if(BA == 1) begin
                            r[ROW_BITS-2:0] = r[ROW_BITS-2:0] + 1;
                            end

                            else if(BA == 0) begin
                            r[ROW_BITS-2:0] = r[ROW_BITS-2:0] + 1;
                            end



                                end

                                flag = 0;




                        end

                    end

                16 : begin

                        if(count > 15) begin

                                if((flag[0] == 1) || (flag[1] == 1)|| (flag[2] == 1)) begin

                                        //r[ROW_BITS-1:0] = r[ROW_BITS-1:0] + 1;

                                        if(BA == 1) begin
                                        r[ROW_BITS-2:0] = r[ROW_BITS-2:0] + 1;
                                        end

                                        else if(BA == 0) begin
                                        r[ROW_BITS-2:0] = r[ROW_BITS-2:0] + 1;
                                        end



                                end

                                flag = 0;


                        end

                    end

                32 : begin

                        if((count > 31) ) begin


                                if((flag[0] == 1) || (flag[1] == 1)|| (flag[2] == 1)) begin

                                        //r[ROW_BITS-1:0] = r[ROW_BITS-1:0] + 1;

                                        if(BA == 1) begin
                                        r[ROW_BITS-2:0] = r[ROW_BITS-2:0] + 1;
                                        end

                                        else if(BA == 0) begin
                                        r[ROW_BITS-2:0] = r[ROW_BITS-2:0] + 1;
                                        end



                                end

                                flag = 0;

                        end


                    end

                64 : begin

                        if((count > 63)) begin

                                if((flag[0] == 1) || (flag[1] == 1)|| (flag[2] == 1)) begin

                                       // r[ROW_BITS-1:0] = r[ROW_BITS-1:0] + 1;

                                        if(BA == 1) begin
                                        r[ROW_BITS-2:0] = r[ROW_BITS-2:0] + 1;
                                        end

                                        else if(BA == 0) begin
                                        r[ROW_BITS-2:0] = r[ROW_BITS-2:0] + 1;
                                        end


                                end


                                flag = 0;

                        end

                    end

                endcase

           end

        end

    endtask


    task memory_write_H;
        input  [ROW_BITS-1:0] row;
        input  [COL_BITS-1:0] col;
        input  [DQ_BITS-1:0] data;

  input   ma;

        reg    [`MAX_BITS:0] addr;


        begin

        addr = {row, col};

  if(ma==0) begin

        mem_array1[addr]  <= data;
  end


        end
    endtask

    task memory_write_L;
        input  [ROW_BITS-1:0] row;
        input  [COL_BITS-1:0] col;
        input  [DQ_BITS-1:0] data;

  input       ma;

        reg    [`MAX_BITS:0] addr;


        begin

        addr = {row, col};

  if(ma==0) begin
        mem_array0[addr]  <= data;

  end


        end
    endtask


    task mem_init;

  begin

    for(memiadr = 0; memiadr < mem_sizes; memiadr = memiadr+1) begin

      mem_array1[memiadr] = 8'hxx;
      mem_array0[memiadr] = 8'hxx;

    end
  end

    endtask


    function [DQ_BITS-1:0] memory_read_H;

        input  [ROW_BITS-1:0] row;
        input  [COL_BITS-1:0] col;


        reg    [`MAX_BITS:0] addr;

        begin

                addr = {row, col};

                memory_read_H =  mem_array1[addr];


        end

   endfunction

    function [DQ_BITS-1:0] memory_read_L;

        input  [ROW_BITS-1:0] row;
        input  [COL_BITS-1:0] col;


        reg    [`MAX_BITS:0] addr;

        begin

                addr = {row, col};

                memory_read_L =  mem_array0[addr];

        end

   endfunction





   task config_reg_write;

  input [3:0] select;

  input [15:0]    opcode;

  input   comment;

  begin

  case (select)

    CR0 : begin

      //dpd = opcode[15];//DPD "0"
      dpd = 1'b1;

      out_imp = opcode[14:12];
      Inital_lat = opcode[7:4];
      Fcl_en  = opcode[3];
      HB_en  = opcode[2];
      Burst_len = opcode [1:0];

          end


    CR1 : begin

      dri = opcode[1:0];

          end

  endcase

  if(comment) begin

    if(select == CR0) begin

      //Rev0_4
      case (CA_in[35])

        1'b0 : begin
          $display($time, " Configuration Register 0 Die0 ");
          end

                                1'b1 : begin
          $display($time, " Configuration Register 0 Die1 ");
          end

                        endcase



      case (dpd)

      //  1'b0 : $display($time, " Writing 0 to CR[15] causeds the device to enter Deep Power Down");
        1'b0 : $display($time, " Reserved ");
        1'b1 : $display($time, " Normal Operation[default] ");

      endcase

      case (out_imp)

                          'b000 : $display($time, " 34 ohms [default]");
                          'b001 : $display($time, " 115 ohms ");
                          'b010 : $display($time, " 67 ohms ");
                          'b011 : $display($time, " 46 ohms ");
                          'b100 : $display($time, " 34 ohms ");
                          'b101 : $display($time, " 27 ohms ");
                          'b110 : $display($time, " 22 ohms ");
                          'b111 : $display($time, " 19 ohms ");

                        endcase

      case (Inital_lat)

                        'b0000 : begin
                                 $display($time, " 5 clock latency");
                                 CL = 5;
                                 end
                        'b0001 : begin
                                 $display($time, " 6 clock latency");
                                 CL = 6;
                                 end
                        'b0010 : begin
                               //  $display($time, " 7 clock latency");
                               //  CL = 7;
                                 $display($time, " Reserved ");
                                 end
                        'b0011 : begin
                               //  $display($time, " 8 clock latency");
                               //  CL = 8;
                                 $display($time, " Reserved ");
                                 end
                        'b1110 : begin
                                 $display($time, " 3 clock latency");
                                 CL = 3;
                                 end
                        'b1111 : begin
                                 $display($time, " 4 clock latency");
                                 CL = 4;
                                 end
                        default : $display($time, " Reserved ");

                  endcase

      case (Fcl_en)

                        'b0 : begin
//        $display($time, " Variable latency");
//        FL_EN = 0;

        $display($time, " Variable latency - Not Supported");
        FL_EN = 1;

            end
                        'b1 : begin
        $display($time, " Fixed latency");
        FL_EN = 1;
        end
                  endcase

      case (HB_en)

                        'b0 : begin
                                $display($time, " Wrapped burst Sequence to follow hybrid burst sequencing");
                                HB_EN = 0;
                              end

                        'b1 : begin
                                $display($time, " Wrapped burst Sequences in legacy wrapped burst manner[deault]");
                                HB_EN = 1;
                              end

                  endcase

      case (Burst_len)

                        'b00 : begin
                                $display($time, " 128byte");
                                BL = 64;
                                end
                        'b01 : begin
                                $display($time, " 64byte");
                                BL = 32;
                                end
                        'b10 : begin
                                $display($time, " 16byte");
                                BL = 8;
                                end
                        'b11 : begin
                                $display($time, " 32byte [deault]");
                                BL = 16;
                                end

              endcase

    end

    else if(select == CR1) begin

                        case (CA_in[35])

                                1'b0 : begin
                                        $display($time, " Configuration Register 1 Die0 ");
                                        end

                                1'b1 : begin
                                        $display($time, " Configuration Register 1 Die1 ");

                                        end

                        endcase

      case(dri)

      //'b00 : begin
      //       $display($time, " Distrbuted Refesh interval : 4us for industrial tmperature randge device \n");
      //       $display($time, " Distrbuted Refesh interval : 1us for industrial Plus tmperature randge device\n ");
      //       end
      //'b01 : $display($time, " Distrbuted Refesh interval : 1.5times default \n");
      //'b10 : $display($time, " Distrbuted Refesh interval : 2times default \n");
      //'b11 : $display($time, " Distrbuted Refesh interval : 3times default \n");

      'b00 : $display($time, " Distributed Refesh interval : 2times default \n");
      'b01 : $display($time, " Distributed Refesh interval : 4times default \n");
                        'b10 : begin
                               $display($time, " Distributed Refesh interval : 4us for industrial tmperature randge device \n");
                               $display($time, " Distributed Refesh interval : 1us for industrial Plus tmperature randge device\n ");
                               end
                        'b11 : $display($time, " Distributed Refesh interval : 1.5times default \n");




      endcase
    end

  end

      end

endtask


task config_reg_read;

  input [3:0] sel;

  input [15:0] opcode;

  begin


  case(sel)

  IDR0 : begin

    $display($time, " Identification Register 0 [Read-only]");

    case(opcode[15:14])

                        //'b00 : $display($time, " Die0 (Lowest address die or single die)");
                        //'b01 : $display($time, " Die1 ");
                        'b00 : $display($time, " Die0 (Lowest address Die, Bottom Die)");
                        'b01 : $display($time, " Die1 (Highest address Die, Top Die)");
                        'b10 : $display($time, " Die2 ");
                        'b11 : $display($time, " Die3 ");

                endcase


    case(opcode[12:8])

                        'b00000 : $display($time, " 1 Row address bit");
                        'b00001 : $display($time, " 2 Row address bit");
                        'b11111 : $display($time, " 32 Row address bit");
    endcase

    case(opcode[7:4])

                        'b0000 : $display($time, " 1 colum address bit");
                        'b0001 : $display($time, " 2 colum address bit");
                        'b1111 : $display($time, " 16 colum address bit");

                endcase

    case(opcode[3:0])

                        'b0000 : $display($time, " Reserved");
                        'b0001 : $display($time, " Spanison");
                        'b0011 : $display($time, " ISSI");

                endcase

    end

  IDR1 : begin


  $display($time, " Identification Register 1 [Read-only]");

    case(opcode[15:14])

                        //'b00 : $display($time, " Single Refresh");
      'b00 : $display($time, " Reserved ");
                        'b01 : $display($time, " Reserved ");
                        'b10 : $display($time, " Reserved ");
                        'b11 : $display($time, " Reserved ");

                endcase

    case(IDR_Off_st)

      'b0 : $display($time, " Reserved ");
                        //'b0 : $display($time, " Offeset Strobe disabled - PSC/PSC# ignored(defalt)");
                        //'b1 : $display($time, " Offeset strobe enabled - PSC/PSC# use to offeset RWDS during read ");

                endcase

    case(opcode[3:0])

                        'b0000 : $display($time, " HyperRAM-0");
                        default: $display($time, " Reserved ");

    endcase

    end

  DMIR0 : begin

        $display($time, " Die Manufactue Information Register 0 [Read-only]");

    case(opcode[15:0])

                        default : $display($time, " Reserved");

    endcase

    end

  DMIR1 : begin

        $display($time, " Die Manufactue Information Register 1 [Read-only]");

    case(opcode[15:0])

                        default : $display($time, " Reserved");

                endcase

                end

  DMIR2 : begin

        $display($time, " Die Manufactue Information Register 2 [Read-only]");

    case(opcode[15:0])

                        default : $display($time, " Reserved");

                endcase

                end

  endcase

  end

endtask




 `endprotect


  specify

        `ifdef S10

        specparam tsIS  = 1.0;
        specparam tsIH  = 1.0;

        `endif

        `ifdef S75

        specparam tsIS  = 0.9;
        specparam tsIH  = 0.9;

        `endif

        `ifdef S60

        specparam tsIS  = 0.8;
        specparam tsIH  = 0.8;

        `endif







  endspecify


endmodule

