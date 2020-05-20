/*
 * linnux_menu.cpp
 *
 *  Created on: Apr 26, 2011
 *      Author: linnyair
 */

#include "linnux_menu.h"

void Control_Menu_System_Initialize(linnux_menu_mapping_type& s_mapStringValues)
{
	s_mapStringValues["execyl"]                           = enSVExec;
	s_mapStringValues["time_delay_msec"]                  = enSVTimeDelayMsec;
	s_mapStringValues["help"]                             = enSVHelp;
    s_mapStringValues["disrupt_tcpip"]                    = enSVDisruptTCPIP;
    s_mapStringValues["undisrupt_tcpip"]                  = enSVUndisruptTCPIP;
    s_mapStringValues["macstats"]                         = enSVMacStats;
    s_mapStringValues["ftp_debug_enable"]                         = enSVFTPDebug;
    s_mapStringValues["ftp_debug_disable"]                         = enSVFTPNoDebug;
    s_mapStringValues["ucos_stats_autoprint_enable"]                = enSVEnableUCOSStatPrint;
    s_mapStringValues["ucos_stats_autoprint_disable"]               = enSVDisableUCOSStatPrint;

    s_mapStringValues["ucos_stats_gathering_enable"] =         enableUCOSStatisticsGathering;
    s_mapStringValues["ucos_stats_gathering_disable"]=         disableUCOSStatisticsGathering;
    s_mapStringValues["print_pktlog"]                   = enSVPrintPktlog;
    s_mapStringValues["ucos_stats"] = enSVPrintUCOSStatsNow;
    s_mapStringValues["enable_deep_packet_stats"]        =   enSVEnableDeepPacketStats;
    s_mapStringValues["disable_deep_packet_stats"]       =   enSVDisableDeepPacketStats;
    s_mapStringValues["get_low_level_timestamp"]       =   enSVGetLowLevelTimestamp;
    s_mapStringValues["get_low_level_timestamp_secs"]       =  enSVGetLowLevelTimestampSecs;
    s_mapStringValues["dut_proc_cmd"]                       = enSVExecuteDUTProcCommand;
    s_mapStringValues["write_dut_proc_cmd"]                 = enSVWriteDUTProcCmd;
    s_mapStringValues["read_dut_proc_cmd"]                 = enSVReadDUTProcCmd;
    s_mapStringValues["set_serious_net_event"] = enSVSetSeriousNetEvent;
    s_mapStringValues["clear_serious_net_event"] =  enSVClearSeriousNetEvent;
    s_mapStringValues["set_packet_print"] = enSVSetPrintPkt;
    s_mapStringValues["clear_packet_print"] = enSVClearPrintPkt;
    s_mapStringValues["ucos_print"] =enSVPrintUCOSStats;
    s_mapStringValues["set_ucos_print"] =enSVSetPrintUCOSStats;
    s_mapStringValues["clear_ucos_print"] =enSVClearPrintUCOSStats;

    s_mapStringValues["os_task_del"]                      = enSVOSTaskDel;
	s_mapStringValues["read_reg"]                         = enSVReadRegister;
	s_mapStringValues["write_reg"]                        = enSVWriteRegister;
	s_mapStringValues["enter_test_mode"]                  = enSVEnterTestMode;
	s_mapStringValues["exit_test_mode"]                   = enSVExitTestMode;
	s_mapStringValues["read_pcbi_reg"]                    = enSVReadPCBI;
	s_mapStringValues["write_pcbi_reg"]                   = enSVWritePCBI;
	s_mapStringValues["write_dut_gp_control"]             = enSVWriteDUT_GP_Control;
	s_mapStringValues["read_dut_gp_control"]              = enSVReadDUT_GP_Control;
	s_mapStringValues["read_dut_gp_status"]               = enSVReadDUT_GP_Status;
	s_mapStringValues["usleep"]                           = enSVusleep;
	s_mapStringValues["select_dac_output"]                = enSVSelectDACOutput;
	s_mapStringValues["select_sma_output"]                = enSVSelectSMAOutput;
	s_mapStringValues["write_patgen_ram"]                 = enSVWritePatgenRAM;
	s_mapStringValues["write_berc_patgen_ram"]            = enSVWriteBERCPatgenRAM;
	s_mapStringValues["write_filter_bypass_ram"]          = enSVWriteFilterBypassRAM;
	s_mapStringValues["read_patgen_ram"]                  = enSVReadPatgenRAM;
	s_mapStringValues["read_berc_patgen_ram"]             = enSVReadBERCPatgenRAM;
	s_mapStringValues["read_dut_gp_ram0"]                 = enSVReadDUTGPRAM0;
	s_mapStringValues["write_dut_gp_ram0"]                = enSVWriteDUTGPRAM0;
	s_mapStringValues["enable_semaphore_logging"]         = enSVEnableSemaphoreLogging;
	s_mapStringValues["disable_semaphore_logging"]                = enSVDisableSemaphoreLogging;
	s_mapStringValues["mem_check"]                =enSVMemCheck;
	s_mapStringValues["mem_display"]                = enSVMemDisplay;
	s_mapStringValues["ipconfig"]                = enSVIPConfig;
	s_mapStringValues["read_filter_bypass_ram"]           = enSVReadFilterBypassRAM;

	s_mapStringValues["load_user_bit_pattern"]     = enSVLoadUserPatternFromSDCard;
	s_mapStringValues["load_pattern_to_dut_gp_ram0"]     =enSVLoadUserPatternToDUTGPRAM0;
	s_mapStringValues["mem"] = enSVMem;
    s_mapStringValues["rm"]     =  enSVRM;
	s_mapStringValues["erase"]     =  enSVRM;
	s_mapStringValues["rename"]     = enSVRename;
	s_mapStringValues["mv"]     = enSVRename;
	s_mapStringValues["mountsd"]     =  enSVMountSD;
	s_mapStringValues["unmountsd"]     =  enSVUnMountSD;
	s_mapStringValues["mkdir"]     =  enSVMkdir;
	s_mapStringValues["chdir"]     =  enSVChdir;
	s_mapStringValues["cd"]     =  enSVChdir;
	s_mapStringValues["pwd"]     =    enSVPwd;
	s_mapStringValues["ls"]     = enSVlsSDCard;
	s_mapStringValues["dir"]     = enSVlsSDCard;
	s_mapStringValues["cp"]     =  enSVCopyFile;
	s_mapStringValues["copy"]     =  enSVCopyFile;
	s_mapStringValues["noop"]     =  enSVNOOP;
	s_mapStringValues["write_str_to_file"]     = enSVWriteStrToFile;
	s_mapStringValues["read_str_from_file"]     = enSVReadStrFromFile;
	s_mapStringValues["open_file_for_read"]     = enSVOpenFileForRead;
	s_mapStringValues["open_file_for_write"]     = enSVOpenFileForWrite;
	s_mapStringValues["open_file_for_overwrite"]  = enSVOpenFileForOverWrite;
	s_mapStringValues["close_file"]     =enSVCloseFile;
	s_mapStringValues["close_all_files"] = enSVCloseAllFiles;
    s_mapStringValues["tcla"] = enSVPicolExec;
    s_mapStringValues["identify"]  =  enSVIdentify;
    s_mapStringValues["enter_deep_debug_mode"] =  enSVEnterDeepDebugMode;
    s_mapStringValues["exit_deep_debug_mode"] = enSVExitDeepDebugMode;
    s_mapStringValues["enter_ethernet_quiet_mode"] = enSVEnterEthernetQuietMode;
    s_mapStringValues["exit_ethernet_quiet_mode"] =  enSVExitEthernetQuietMode;
    s_mapStringValues["time"] = enSVTime;
	s_mapStringValues["cat"] = enSVCatSDFile;
	s_mapStringValues["pcbi_status_dump"] = enSVPCBIStatusDump;
	s_mapStringValues["enter_eyed_test_mode"] =  enSVEnterEyeDTestMode,
	s_mapStringValues["exit_eyed_test_mode"] =   enSVExitEyeDTestMode,
	s_mapStringValues["reconnect_jtag"] = 	  enSVReconnectJTAG;
	s_mapStringValues["set_led_mask"] =     enSVSetLEDMask;

	s_mapStringValues["write_led"] = enSVWriteLED;
	s_mapStringValues["read_led"] = enSVReadLED;

	s_mapStringValues["read_switch"] = enSVReadSwitches;
    s_mapStringValues["set_led_mask"] =

	s_mapStringValues["exprtk"] = enSVExprtk;
	s_mapStringValues["exprtk_test"] = enSVExprtkTest;

	s_mapStringValues["udpstream"] = enSVUDPStreamCmd;
	   s_mapStringValues["is_master"]  =                      enSVIsMaster;
	   s_mapStringValues["is_slave"]  =                       enSVIsSlave;
	   s_mapStringValues["get_card_assigned_num"]  =          enSVGetCardAssignedNum;
	   s_mapStringValues["get_card_hw_revision"]  =           enSVGetCardRevision;
	   s_mapStringValues["enter_control_extra_verbose_mode"]  =   enSVEnterControlExtraVerboseMode;
	   s_mapStringValues["exit_control_extra_verbose_mode"]  =    enSVExitControlExtraVerboseMode;
	   s_mapStringValues["set_stored_command"]  =    enSVSetStoredCommand;
	   s_mapStringValues["exec_stored_command"]  =    enSVExecStoredCommand;
	   s_mapStringValues["print_stored_command"]  =    enSVPrintStoredCommand;
	   s_mapStringValues["enable_profiling"]  =  enSVEnableLINNUXProfiling;
	   s_mapStringValues["disable_profiling"]  = enSVDisableLINNUXProfiling;
	   s_mapStringValues["store_dma_descriptor"]  = enSVStoreDMADescriptor;
	   s_mapStringValues["relative_store_dma_descriptor"]  = enSVRelativeStoreDMADescriptor;
	   s_mapStringValues["get_dma_descriptor"]  =          enSVReadDMADescriptor;
	   s_mapStringValues["reset_hw_dma_to_udp"]  =  enSVResetHWDMAtoUDP;
	   s_mapStringValues["reset_sw_dma_to_udp"]  =  enSVResetSWDMAtoUDP;
	   s_mapStringValues["clear_fmc_zl9101m_faults"]  =  enSVClearzl9101mFault;
	   s_mapStringValues["clear_main_board_zl9101m_faults"]  =  enSVClearMainzl9101mFault;
	   s_mapStringValues["custom_command"]  = enSVDoCustomCommand;
	   s_mapStringValues["get_indexed_mem_params"] = enSVGetIndexedMemParams;

}

void Menu_System_Initialize(linnux_menu_mapping_type& s_mapStringValues)
{

	Control_Menu_System_Initialize (s_mapStringValues); //safeguard

	s_mapStringValues["write_led"] = enSVWriteLED;
	s_mapStringValues["read_led"] = enSVReadLED;

	s_mapStringValues["read_switch"] = enSVReadSwitches;
	s_mapStringValues["ucos_stats_gathering_enable"] =         enableUCOSStatisticsGathering;
	s_mapStringValues["ucos_stats_gathering_disable"]=         disableUCOSStatisticsGathering;
	s_mapStringValues["time_delay_msec"]                  = enSVTimeDelayMsec;
	s_mapStringValues["exprtk"] = enSVExprtk;
	s_mapStringValues["exprtk_test"] = enSVExprtkTest;
	s_mapStringValues["execyl"]                            = enSVExec;
	s_mapStringValues["help"]                             = enSVHelp;
	s_mapStringValues["source_file"]                     = enSVSourceFile;
	s_mapStringValues["source_console"]                  = enSVSourceConsole;
	s_mapStringValues["test_sd_card"]                     = enSVTestSDCard;
	s_mapStringValues["ppm_sweep"]                        = enSVPPMSweep;
	s_mapStringValues["set_fixed_ppm_offset"]             = enSVSetFixedPPMOffset;
	s_mapStringValues["set_fixed_sj"]                     = enSVSetSJ;
	s_mapStringValues["set_fixed_ssc"]                    = enSVSetSSC;
	s_mapStringValues["find_sjtol_curve"]                 = enSVFindJTOL;
	s_mapStringValues["find_multiple_sjtol_curve"]        = enSVFindMultipleSJTOLCurves;
	s_mapStringValues["diag"]                             = enSVDiag;
	s_mapStringValues["eyed_print"]                       = enSVDisplayEyeDMatrix;
	s_mapStringValues["test_fifos"]                       = enSVTestFIFOs;
	s_mapStringValues["set_into_lock_thresh"]        = enSVSetBERCIntoLockThresh;
	s_mapStringValues["set_out_of_lock_thresh"]      = enSVSetBERCOutOfLockThresh;
	s_mapStringValues["set_aux_into_lock_thresh"]        = enSVSetBERCAuxIntoLockThresh;
    s_mapStringValues["set_aux_out_of_lock_thresh"]      = enSVSetBERCAuxOutOfLockThresh;
    s_mapStringValues["get_input_sequence_description"]  = enSVGetInputSeqDesc;
    s_mapStringValues["berc_enable_aux_corr"]             = enSVBERCEnableAuxCorr;
    s_mapStringValues["berc_disable_aux_corr"]            = enSVBERCDisableAuxCorr;
	s_mapStringValues["set_num_bits_to_measure"]          = enSVSetNumBitsToMeasure;
	s_mapStringValues["set_input_sequence"]               = enSVSetInputSequence;
	s_mapStringValues["set_channel_amp"]                  = enSVSetChannelAmplification;
	s_mapStringValues["set_interp_filt_amp"]              = enSVSetInterpFiltAmplification;
	s_mapStringValues["set_channel_interp_ratio"]         = enSVChannelFiltInterpRatio;
	s_mapStringValues["set_channel_fir_coeffs"]           = enSVSetChannelFIRCoeffs;
	s_mapStringValues["set_interp_fir_coeffs"]            = enSVSetInterpFiltCoeffs;
	s_mapStringValues["set_data_duty_cycle"]              = enSVSetDataDutyCycle;
	s_mapStringValues["report_data_duty_cycle"]              = enSVReportDataDutyCycle;
	s_mapStringValues["report_fir_coeffs"]                = enSVReportFIRCoeffs;
    s_mapStringValues["report_fir_description"]           = enSVReportFIRDesc;
    s_mapStringValues["get_testbench_description"]        = enSVGetTestbenchDescription;
    s_mapStringValues["shutdown_tcpip"]                   = enSVShutdownTCPIP;
    s_mapStringValues["disrupt_tcpip"]                    = enSVDisruptTCPIP;
    s_mapStringValues["undisrupt_tcpip"]                  = enSVUndisruptTCPIP;
    s_mapStringValues["macstats"]                         = enSVMacStats;
    s_mapStringValues["ftp_debug_enable"]                         = enSVFTPDebug;
    s_mapStringValues["ftp_debug_disable"]                         = enSVFTPNoDebug;
    s_mapStringValues["ucos_stats_enable"]                = enSVEnableUCOSStatPrint;
    s_mapStringValues["ucos_stats_disable"]               = enSVDisableUCOSStatPrint;
    s_mapStringValues["ucos_stats"] = enSVPrintUCOSStatsNow;

    s_mapStringValues["allow_packet_buff_add"]            = enSVAllowPacketBufAddition;
    s_mapStringValues["disallow_packet_buff_add"]          = enSVDisallowPacketBufAddition;
    s_mapStringValues["print_pktlog"]                   = enSVPrintPktlog;
    s_mapStringValues["enable_deep_packet_stats"]        =   enSVEnableDeepPacketStats;
    s_mapStringValues["disable_deep_packet_stats"]       =   enSVDisableDeepPacketStats;
    s_mapStringValues["get_low_level_timestamp"]       =   enSVGetLowLevelTimestamp;
    s_mapStringValues["get_low_level_timestamp_secs"]       =  enSVGetLowLevelTimestampSecs;
    s_mapStringValues["dut_proc_cmd"]                       = enSVExecuteDUTProcCommand;
    s_mapStringValues["write_dut_proc_cmd"]                 = enSVWriteDUTProcCmd;
    s_mapStringValues["read_dut_proc_cmd"]                 = enSVReadDUTProcCmd;
    s_mapStringValues["set_serious_net_event"] = enSVSetSeriousNetEvent;
    s_mapStringValues["clear_serious_net_event"] =  enSVClearSeriousNetEvent;
    s_mapStringValues["set_packet_print"] = enSVSetPrintPkt;
    s_mapStringValues["clear_packet_print"] = enSVClearPrintPkt;
    s_mapStringValues["ucos_print"] =enSVPrintUCOSStats;
    s_mapStringValues["set_ucos_print"] =enSVSetPrintUCOSStats;
    s_mapStringValues["clear_ucos_print"] =enSVClearPrintUCOSStats;
    s_mapStringValues["os_task_del"]                      = enSVOSTaskDel;
    s_mapStringValues["iniche_diag"]                      = enSVInicheDiag;
    s_mapStringValues["simulate_tcpip_rxbuf_error"]       = enSVTestTCPIPBufferRecovery;
	s_mapStringValues["set_internal_fir_mult"]            = enSVSetInternalFIRMult;
	s_mapStringValues["get_internal_fir_mult"]            = enSVGetInternalFIRMult;
	s_mapStringValues["enable_internal_fir_mult"]         = enSVEnableInternalFIRMult;
	s_mapStringValues["enable_external_fir_mult"]         = enSVEnableExternalFIRMult;
	s_mapStringValues["set_intentional_error_rate"]       = enSVSetIntentionalErrorRate;
	s_mapStringValues["set_global_slowdown"]              = enSVSetGlobalSlowdown;
	s_mapStringValues["read_reg"]                         = enSVReadRegister;
	s_mapStringValues["write_reg"]                        = enSVWriteRegister;
	s_mapStringValues["read_large_mux"]                   = enSVReadLargeMux;
	s_mapStringValues["enter_test_mode"]                  = enSVEnterTestMode;
	s_mapStringValues["exit_test_mode"]                   = enSVExitTestMode;
	s_mapStringValues["use_primary_berc"]                 = enSVSetBERCtoPrimary;
	s_mapStringValues["use_secondary_berc"]               = enSVSetBERCtoSEcondary;
	s_mapStringValues["set_berc_input_transpose"]         = enSetBERCInputTranspose;
	s_mapStringValues["set_xtalk0_freq"]                  = enSVSetXtalk0Freq;
	s_mapStringValues["set_xtalk0_amp" ]                  = enSVSetXtalk0Amp;
	s_mapStringValues["xtalk0_enable" ]                   = enSVXtalk0Enable;
	s_mapStringValues["xtalk0_disable" ]                  = enSVXtalk0Disable;

	s_mapStringValues["set_dut_mode"]                     = enSVSetDUTMode;
	s_mapStringValues["read_pcbi_reg"]                    = enSVReadPCBI;
	s_mapStringValues["write_pcbi_reg"]                   = enSVWritePCBI;
	s_mapStringValues["write_dut_gp_control"]             = enSVWriteDUT_GP_Control;
	s_mapStringValues["read_dut_gp_control"]              = enSVReadDUT_GP_Control;
	s_mapStringValues["read_dut_gp_status"]               = enSVReadDUT_GP_Status;
	s_mapStringValues["reset_circuit_element"]            = enSVResetCircuitElement;
	s_mapStringValues["wait_for_mdsp_to_recover"]         = enSVWaitForMDSPToRecover;
	s_mapStringValues["usleep"]                           = enSVusleep;
	s_mapStringValues["set_seq_for_seq_det"]              = enSVSetSeqForSeqDet;
	s_mapStringValues["set_eyed_trigger_clock"]           = enSVSetEyeDTriggerClk;
	s_mapStringValues["get_peak_to_peak_input_amp"]       = enSVGetEyeDPeaktoPeak;
	s_mapStringValues["set_pk_to_pk_amp"]                 = enSVAdjustEyeDPeakToPeak;
	s_mapStringValues["sel_reparallel_data"]              = enSVSelReparallelData;
	s_mapStringValues["select_dac_output"]                = enSVSelectDACOutput;
	s_mapStringValues["select_sma_output"]                = enSVSelectSMAOutput;
	s_mapStringValues["set_input_rj"]                     = enSVSetInputRJ;
	//s_mapStringValues["set_buj"]                          = enSVSetInputBUJ;
	s_mapStringValues["set_buj_pkpk"]                     = enSVSetInputBUJPkPk;
	s_mapStringValues["write_patgen_ram"]                 = enSVWritePatgenRAM;
	s_mapStringValues["write_berc_patgen_ram"]            = enSVWriteBERCPatgenRAM;
	s_mapStringValues["write_filter_bypass_ram"]          = enSVWriteFilterBypassRAM;
	s_mapStringValues["read_patgen_ram"]                  = enSVReadPatgenRAM;
	s_mapStringValues["read_berc_patgen_ram"]             = enSVReadBERCPatgenRAM;
	s_mapStringValues["read_dut_gp_ram0"]                 = enSVReadDUTGPRAM0;
	s_mapStringValues["write_dut_gp_ram0"]                = enSVWriteDUTGPRAM0;
	s_mapStringValues["ipconfig"]                = enSVIPConfig;

	s_mapStringValues["read_filter_bypass_ram"]           = enSVReadFilterBypassRAM;
	s_mapStringValues["get_fifo_data"]                    = enSVGetFIFO;
	s_mapStringValues["get_fifo_data_ulong"]                 =  enSVGetFIFOULong;
	s_mapStringValues["get_fifo_data_ulong_nowait"]                 =  enSVGetFIFOULongNoAquire;
	s_mapStringValues["get_simult_fifo_data_ulong"]                 =  enSVGetSimultFIFOULong;
	s_mapStringValues["multiple_get_fifo_data"]                    = enSVMultipleGetFIFO;
	s_mapStringValues["select_corr_fifo_input"]                    = enSVSelectCorrFIFOInput;
	s_mapStringValues["transpose_bit_order_from_dut_output"]  =  enSVTransposeBitOrderFromDUTOutput;

	s_mapStringValues["load_user_bit_pattern"]     = enSVLoadUserPatternFromSDCard;
	s_mapStringValues["load_pattern_to_dut_gp_ram0"]     =enSVLoadUserPatternToDUTGPRAM0;
	s_mapStringValues["disable_ber_meter_lock"] = enSVDisableBERMeterLock;
	s_mapStringValues["enable_ber_meter_lock"]   = enSVEnableBERMeterLock;
	s_mapStringValues["auto_set_pn_thresholds"]  =    enSVSetAutoPNThresholds;
	s_mapStringValues["auto_set_jtpat_thresholds"]  = enSVSetAutoJTPATThresholds;
    s_mapStringValues["mem"] = enSVMem;
    s_mapStringValues["enable_agc"] = enSVEnableAGC;
    s_mapStringValues["disable_agc"] = enSVDisableAGC;
    s_mapStringValues["set_agc_level"] = enSVSetAGCLevel;
    s_mapStringValues["simult_gp_fifo_capture"] = enSVSimultGPFIFOCapture;
    s_mapStringValues["simult_capture_of_uart_nios_dacs"] = enSVSimultUARTGPFIFOAcquire;
    s_mapStringValues["simult_capture_of_uart_nios_dacs_compressed"] = enSVSimultUARTGPFIFOAcquireCompressed;
    s_mapStringValues["simult_capture_of_hw_trig_uart_nios_dacs"]            = enSVSimultUARTGPFIFOAcquireHWTriggeredData;
    s_mapStringValues["simult_capture_of_hw_trig_uart_nios_dacs_compressed"] = enSVSimultUARTGPFIFOAcquireHWTriggeredDataCompressed;

    s_mapStringValues["simult_multi_packetizer_capture"]                            =  enSVSimultMultiPacketizerAcquire                         ;
    s_mapStringValues["simult_multi_packetizer_capture_compressed"]                 =  enSVSimultMultiPacketizerAcquireCompressed               ;
    s_mapStringValues["simult_multi_packetizer_capture_of_hw_trig_data"]            =  enSVSimultMultiPacketizerAcquireHWTriggeredData          ;
    s_mapStringValues["simult_multi_packetizer_capture_of_hw_trig_data_compressed"] =  enSVSimultMultiPacketizerAcquireHWTriggeredDataCompressed;


    s_mapStringValues["multiple_simult_gp_fifo_capture"] = enSVMultipleSimultGPFIFOCapture;

    s_mapStringValues["get_ber_stat"] = enSVGetBERStat;
	s_mapStringValues["enable_semaphore_logging"]          = enSVEnableSemaphoreLogging;
	s_mapStringValues["disable_semaphore_logging"]         = enSVDisableSemaphoreLogging;
	s_mapStringValues["mem_check"]                  = enSVMemCheck;
	s_mapStringValues["mem_display"]                = enSVMemDisplay;

    s_mapStringValues["enter_jtag_debug"] = enSVEnterJtagDebug;
    s_mapStringValues["exit_jtag_debug"] =  enSVExitJtagDebug;
    s_mapStringValues["rm"]     =  enSVRM;
	s_mapStringValues["erase"]     =  enSVRM;
	s_mapStringValues["rename"]     = enSVRename;
	s_mapStringValues["mv"]     = enSVRename;
	s_mapStringValues["mountsd"]     =  enSVMountSD;
	s_mapStringValues["unmountsd"]     =  enSVUnMountSD;
	s_mapStringValues["mkdir"]     =  enSVMkdir;
	s_mapStringValues["chdir"]     =  enSVChdir;
	s_mapStringValues["cd"]     =  enSVChdir;
	s_mapStringValues["pwd"]     =    enSVPwd;
	s_mapStringValues["ls"]     = enSVlsSDCard;
	s_mapStringValues["dir"]     = enSVlsSDCard;
	s_mapStringValues["cp"]     =  enSVCopyFile;
	s_mapStringValues["copy"]     =  enSVCopyFile;
	s_mapStringValues["start_logging_to_file"]     =  enSVOpenLogFile;
	s_mapStringValues["finish_logging_to_file"]     = enSVCloseLogFile;
	s_mapStringValues["enable_auto_logfile"]     = enSVEnableAutoLogFile;
	s_mapStringValues["disable_auto_logfile"]     = enSVDisableAutoLogFile;
	s_mapStringValues["noop"]     =  enSVNOOP;

	s_mapStringValues["write_str_to_file"]     = enSVWriteStrToFile;
	s_mapStringValues["read_str_from_file"]     = enSVReadStrFromFile;
	s_mapStringValues["open_file_for_read"]     = enSVOpenFileForRead;
	s_mapStringValues["open_file_for_write"]     = enSVOpenFileForWrite;
	s_mapStringValues["open_file_for_overwrite"]  = enSVOpenFileForOverWrite;
	s_mapStringValues["close_file"]     =enSVCloseFile;
	s_mapStringValues["close_all_files"] = enSVCloseAllFiles;
	s_mapStringValues["set_channel_model_coeffs"] = enSetChannelModelCoeffs;
    s_mapStringValues["tcla"] = enSVPicolExec;
    s_mapStringValues["tcl"]  = enSVPicolPersistentExec;
    s_mapStringValues["identify"]  =  enSVIdentify;
    s_mapStringValues["enter_deep_debug_mode"] =  enSVEnterDeepDebugMode;
    s_mapStringValues["exit_deep_debug_mode"] = enSVExitDeepDebugMode;
    s_mapStringValues["enter_ethernet_quiet_mode"] = enSVEnterEthernetQuietMode;
    s_mapStringValues["exit_ethernet_quiet_mode"] =  enSVExitEthernetQuietMode;


    s_mapStringValues["uparse"]  = enSVuParse;
    s_mapStringValues["time"] = enSVTime;
    s_mapStringValues["get_hw_timestamp"] = enSVHWTimeStamp;

	s_mapStringValues["cat"] = enSVCatSDFile;
	s_mapStringValues["pcbi_status_dump"] = enSVPCBIStatusDump;

	s_mapStringValues["enter_eyed_test_mode"] =  enSVEnterEyeDTestMode,
	s_mapStringValues["exit_eyed_test_mode"] =   enSVExitEyeDTestMode,
	s_mapStringValues["reconnect_jtag"] = 	  enSVReconnectJTAG;
	s_mapStringValues["set_led_mask"] =     enSVSetLEDMask;

	s_mapStringValues["enable_fifo_acquisition"]   = enSVEnableFIFOAcquisition;
	s_mapStringValues["complete_fifo_acquisition"] = enSVCompleteFIFOAcquisition;

	s_mapStringValues["enable_simult_fifo_acquisition"]   = enSVEnableSimultFIFOAcquisition;
	s_mapStringValues["complete_simult_fifo_acquisition"] = enSVCompleteSimultFIFOAcquisition;

	s_mapStringValues["enable_vme_fifo_flowthrough"]    = enSVEnableVMEFifoFlowthrough;
	s_mapStringValues["disable_vme_fifo_flowthrough"]   = enSVDisableVMEFifoFlowthrough;

	s_mapStringValues["enable_vme_fifo_wrclk"]          = enSVEnableVMEFifoWrclk;
	s_mapStringValues["disable_vme_fifo_wrclk"]          = enSVDisableVMEFifoWrclk;

	s_mapStringValues["trigger_adc_fifos"] = enSVTriggerVMEFIFOs;
	s_mapStringValues["release_adc_fifos_trigger"] =       enSVReleaseTriggerForVMEFIFOs;
	s_mapStringValues["clear_adc_fifos"] = enSVClearVMEFIFOs;
	s_mapStringValues["acquire_multiple_adc_fifos"] = enSVAcquireMultipleVMEFIFOs;
	s_mapStringValues["jsonp_acquire_multiple_adc_fifos"] = enSVJSONPAcquireMultipleVMEFIFOs;
	s_mapStringValues["get_json_string"] = enSVGetJSONString;
	s_mapStringValues["get_motherboard_json_string"] = enSVGetMotherboardJSONString;
	s_mapStringValues["spi_tx_byte"]     = enSVSPITXByte;
	s_mapStringValues["spi_rx_byte"]     = enSVSPIRXByte;
	s_mapStringValues["spi_get_tx_data"] = enSVSPIGetTXData;
	s_mapStringValues["spi_get_rx_data"] = enSVSPIGetRXData;
	s_mapStringValues["spi_get_test_slave_rx_data"] = enSVSPITestSlaveGetRXData;
	s_mapStringValues["spi_get_test_slave_tx_data"] = enSVSPITestSlaveGetTXData;

	s_mapStringValues["spi_tx_16bit"]=enSVSPITX16bit;
	s_mapStringValues["spi_rx_16bit"]=enSVSPIRX16bit;

	s_mapStringValues["adc_write_reg"] = enSVADCWriteReg;
	s_mapStringValues["adc_read_reg"]  = enSVADCReadReg;
	s_mapStringValues["adc_init"]      = enSVADCInit;
	s_mapStringValues["adc_sw_reset"]  = enSVADCSWReset;
	s_mapStringValues["hw_reset_all_adcs"]  = enSVHWResetAllADCs;

   s_mapStringValues["uart_write"]     = enSVUART_write;
   s_mapStringValues["uart_read"]      = enSVUART_read;

   s_mapStringValues["uart_regfile_ctrl_write"]     = enSVUART_reg_write;
   s_mapStringValues["uart_regfile_ctrl_read"]      = enSVUART_reg_read;
   s_mapStringValues["uart_regfile_info_read"]      = enSVUART_info_read;
   s_mapStringValues["uart_regfile_status_read"]    = enSVUART_status_read;
   s_mapStringValues["uart_regfile_get_params"]      = enSVUART_regfile_get_params;
   s_mapStringValues["uart_regfile_get_version"]     = enSVUART_regfile_get_version;
   s_mapStringValues["uart_regfile_status_desc"]      = enSVUART_regfile_get_status_desc;
   s_mapStringValues["uart_regfile_ctrl_desc"]        = enSVUART_regfile_get_control_desc;
   s_mapStringValues["uart_exec_internal_command"] = enSVExecUARTInternalCommand;
   s_mapStringValues["uart_exec_internal_command_ascii_response"] = enSVExecUARTInternalCommandASCII;
   s_mapStringValues["uart_get_included_status_regs"] = enSVGetUARTIncludedStatusRegs;
   s_mapStringValues["uart_get_included_ctrl_regs"] =   enSVGetUARTIncludedCtrlRegs;

   s_mapStringValues["get_sw_version"] = enSVGetSWVersion;
   s_mapStringValues["get_uart_enabled_vector"]  = enSVGetUARTEnabledVector;
   s_mapStringValues["udpstream"] = enSVUDPStreamCmd;
   s_mapStringValues["disable_prbs0"] = enSVDisablePRBSGen0;
   s_mapStringValues["enable_prbs0"]  = enSVEnablePRBSGen0;
   s_mapStringValues["udp_stream_start"] = enSVUDPStreamStart;
   s_mapStringValues["udp_stream_stop"]  = enSVUDPStreamStop;
   s_mapStringValues["get_active_devices"]  =   enSVGetActiveDevices;
   s_mapStringValues["is_master"]  =                      enSVIsMaster;
   s_mapStringValues["is_slave"]  =                       enSVIsSlave;
   s_mapStringValues["get_card_assigned_num"]  =          enSVGetCardAssignedNum;
   s_mapStringValues["get_card_hw_revision"]  =           enSVGetCardRevision;
   /*s_mapStringValues["program_spartan_hex_long_file"]  =   enSVProgramSpartanHexFile;*/
     s_mapStringValues["program_spartan_hex_file"]  =   enSVProgramSpartanHexFileAsBytes;
     s_mapStringValues["program_stratix_hex_file"]  =   enSVProgramStratixHexFileAsBytes;
     s_mapStringValues["program_flash"] = enSVProgramEPCQ;
     s_mapStringValues["program_spartan_pof_file_from_memory"]  =   enSVProgramSpartanPOFFile;
     s_mapStringValues["program_stratix_pof_file_from_memory"]  =   enSVProgramStratixPOFFile;
     s_mapStringValues["write_to_spartan_flash"]  =      enSVProgramWriteToSpartanFLASH;
     s_mapStringValues["write_to_stratix_flash"]  =       enSVProgramWriteToStratixFLASH;

     s_mapStringValues["disable_jtag_uart"]  =          enSVdisableJTAGUART;
     s_mapStringValues["enable_jtag_uart"]  =          enSVenableJTAGUART;
     s_mapStringValues["get_uart_primary_number"] = enSVGetUARTPrimaryNumberFromName;
     s_mapStringValues["get_uart_secondary_number"] = enSVGetUARTSecondaryNumberFromName;
     s_mapStringValues["malloc"] = enSVMalloc;
     s_mapStringValues["free"] = enSVFree;
     s_mapStringValues["printstr"] = enSVPrintStrfromPtr;
     s_mapStringValues["get_project_name"] = enSVGetProjectName;
     s_mapStringValues["get_logical_card_description"] = enSVGetLogicalCardDescription;
     s_mapStringValues["get_physical_card_description"] = enSVGetPhysicalCardDescription;
     s_mapStringValues["write_binary_data_to_memory"] =  enSVWriteBinaryDataToMemory;
     s_mapStringValues["read_binary_data_from_memory"] =  enSVReadBinaryDataFromMemory;

     s_mapStringValues["get_hw_version"] = enSVGetHWVersion;
     s_mapStringValues["get_mac_addr"] = enSVGetMACAddr;
     s_mapStringValues["get_all_uart_params"] = enSVGetAllUARTData;

               s_mapStringValues["request_fpga_reconfigure"]    =  enSVRequestPFLReconfigure;
               s_mapStringValues["request_elf_reload"]    =    enSVRequestSoftwareReload;
               s_mapStringValues["uart_read_all_ctrl"]    =     enSVUARTReadAllCtrl;
               s_mapStringValues["uart_read_all_ctrl_and_status"]    =     enSVUARTReadAllCtrlAndStatus;
               s_mapStringValues["uart_read_all_status"]    =    enSVUARTReadAllStatus;
               s_mapStringValues["uart_read_all_ctrl_desc"]    =     enSVUARTReadAllCtrlDesc;
               s_mapStringValues["uart_read_all_status_desc"]    =    enSVUARTReadAllStatusDesc;
               s_mapStringValues["uart_write_multiple_ctrl"]    =    enSVUARTWriteAllCtrl;
              s_mapStringValues["uart_read_all_ctrl_included"]    =     enSVGetAllUARTCtrlIncluded;
              s_mapStringValues["uart_read_all_status_included"]    =         enSVGetAllUARTStatusIncluded;
              s_mapStringValues["get_maxv_version_string"]    =     enSVGetMAXVVersionString;
              s_mapStringValues["smtp_hello_world"]    =  enSVSendSMTPHelloSWorld;
              s_mapStringValues["uart_multiple_read_all_ctrl_and_status"]    =     enSVReadMultipleUARTCtrlAndStatus;
              s_mapStringValues["get_random_string_with_crc"]    =     enSVGetRandomStringWithCRC;
              s_mapStringValues["calculate_crc"]    =     enSVCalculateCRC;
              s_mapStringValues["dma_to_ddr"] = enSVSendDMAMemorytoMemory;
              s_mapStringValues["async_dma_to_ddr"] = enSVAsyncSendDMAMemorytoMemory;
              s_mapStringValues["dma_to_udp"] = enSVSendMemoryAsUDP;

              s_mapStringValues["test_hw_dma_to_udp"] = enSVTestSendMemoryAsUDP;
              s_mapStringValues["test_sw_dma_to_udp"] = enSVTestSendMemoryAsUDP1;

              s_mapStringValues["dma_to_udp_via_ddr"] = enSVSendToUDPViaDDR;


              s_mapStringValues["relative_dma_to_udp_via_ddr"] = enSVRelativeSendToUDPViaDDR;

              s_mapStringValues["relative_dma_to_ddr"] = enSVRelativeSendDMAMemorytoMemory;
              s_mapStringValues["async_relative_dma_to_udp_via_ddr"] = enSVAsyncRelativeSendToUDPViaDDR;
              s_mapStringValues["async_dma_to_udp_via_ddr"] = enSVAsyncSendToUDPViaDDR;
              s_mapStringValues["async_test_dma_to_udp"] = enSVAsyncTestSendMemoryAsUDP;
              s_mapStringValues["async_test_dma_to_udp"] = enSVAsyncTestSendMemoryAsUDP1;
              s_mapStringValues["async_dma_to_udp"] = enSVAsyncSendMemoryAsUDP;
              s_mapStringValues["asyncx2_dma_to_udp_via_ddr"] = enSVAsyncX2SendToUDPViaDDR;
              s_mapStringValues["asyncx2_relative_dma_to_udp_via_ddr"] = enSVAsyncX2RelativeSendToUDPViaDDR;

	//cout   << "s_mapStringValues contains "
	//       << s_mapStringValues.size()
	//       << " entries." << endl;
}



