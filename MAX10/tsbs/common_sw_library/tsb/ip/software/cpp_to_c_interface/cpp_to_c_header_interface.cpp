/*
 * cpp_to_c_header_interface.cpp
 *
 *  Created on: Nov 9, 2011
 *      Author: linnyair
 */

#include "cpp_to_c_header_interface.h"
#include "ucos_cpp_utils.h"
#include "basedef.h"
#include "rgmii_config_defines.h"
#include "linnux_main.h"
#include "linnux_utils.h"
#include <sstream>
#include <string>
#include <stdio.h>
#include "sys/alt_alarm.h" // time tick function (alt_nticks(), alt_ticks_per_second())
#include "sys/alt_timestamp.h"
extern "C" {
#include "ipport.h"
#include "netbuf.h"
#include "includes.h"
#include "ucos_ii.h"
}
#include "global_stream_defs.hpp"

using namespace std;

#ifdef NPDEBUG
    extern   PACKET   pktlog[MAXPACKETS];
#endif

#define NEW_MAX(a, b) ((a) > (b) ? (a) : (b))

int get_rgmii_phy_tx_delay_disable() {return LINNUX_RGMII_PHY_TX_DELAY_DISABLE;};
int get_rgmii_phy_rx_delay_disable() {return LINNUX_RGMII_PHY_RX_DELAY_DISABLE;};
int get_rgmii_disable_1gbit_mode()   {return LINNUX_RGMII_DISABLE_1GBIT_MODE  ;};
int get_rgmii_disable_100mbps_mode()   {return LINNUX_RGMII_DISABLE_100MBPS_MODE  ;};


void c_print_out_to_all_streams(const char* the_str) {
	out_to_all_streams(the_str);
}


void c_write_decimal_to_7seg_encapsulator(unsigned int the_decimal)
{
	//write_decimal_to_7seg_encapsulator(the_decimal);
}

void disrupt_tcpip() {

}

void undisrupt_tcpip() {
}

void print_ucosdiag() {
	std::string str = raw_print_ucosdiag();
	safe_print(printf(str.c_str()));
}


std::string raw_print_ucosdiag() {
    int i = 0;

    OS_TCB task_data;
    INT8U err;
    INT16U OSEventCnt;
    INT8U OSEventType;
    INT8U* OSEventName;
    std::ostringstream ostr;

    int local_OSLockNesting = OSLockNesting;
    int local_OSIntNesting = OSIntNesting;
    int local_OSPrioHighRdy = OSPrioHighRdy;
    char str[255];
    std::string tempstr;

    ostr << "\n\nUCOS_STATISTICS\n========================================================================\n";
	ostr << "[" << get_current_time_and_date_as_string_trimmed() << "][low_level_timestamp =" << low_level_system_timestamp() << "]\n";
    ostr << "Ticks/sec:" << alt_ticks_per_second() << " OSLockNesting: " << (int) local_OSLockNesting << " OSIntNesting: " <<  (int) local_OSIntNesting << " OSPrioHighRdy: " << local_OSPrioHighRdy << " Calling Proc: " << (int) OSTCBCur->OSTCBPrio << "\n";
    ostr << "---------------------------------------------------------------------------------------------------\n";
    for (i=0; i<= OS_LOWEST_PRIO; i++)
    {
    	err = OSTaskQuery(i,&task_data);
    	if (err == OS_NO_ERR)
    	{
    		if (task_data.OSTCBEventPtr) {
    			OSEventCnt = task_data.OSTCBEventPtr->OSEventCnt;
    			OSEventType = task_data.OSTCBEventPtr->OSEventType;
    			OSEventName = task_data.OSTCBEventPtr->OSEventName;
    		} else {
    			OSEventCnt = 0;
    			OSEventType = 0;
    			OSEventName = NULL;
    		}
    		snprintf(str,200,"%3d|%-18s|Sts:%4X|EPtr:%8X|-%32s|Type:%2X|ECNT:%2X|StsPEND:%2X|Tout:%6d|Ctr:%05u|Exe:%6u|TotE:%8ld",
    				(int) task_data.OSTCBPrio,
    				TaskUserData[i].TaskName,
    				(int)task_data.OSTCBStat,
    				(unsigned) task_data.OSTCBEventPtr,
    				(char *) OSEventName,
    				(unsigned) OSEventType,
    				(unsigned) OSEventCnt,
    				(int) task_data.OSTCBStatPend,
    				(int) task_data.OSTCBDly,
    				TaskUserData[i].TaskCtr,
		            TaskUserData[i].TaskExecTime,
		            TaskUserData[i].TaskTotExecTime
		            );
    		ostr << str;
    		ostr << "\n";
    		//convert_ull_to_string(TaskUserData[i].last_time_called,str);
    		//ostr<<"|LTC:"<<str;
    		ostr<<"|LTC:"<<TaskUserData[i].last_time_called;
    		//convert_ull_to_string(TaskUserData[i].last_time_exited,str);
    		//ostr<<"|LTE:"<<str<<"\n";
    		ostr<<"|LTE:"<<TaskUserData[i].last_time_exited;
    		ostr<<"|LTY:"<<TaskUserData[i].last_time_yielded;
    		ostr<<"|LTS:"<<TaskUserData[i].last_time_suspended;
    		ostr<<"|SP:"<<TaskUserData[i].suspending_proc;
    		ostr<<"\n";
    		if (TaskUserData[i].sem_last_op != SEM_LAST_OP_WAS_NONE) {

    		tempstr = std::string(TaskUserData[i].source_code_filename);
    		tempstr = tempstr.substr((size_t)(NEW_MAX(0,(int)(tempstr.length()-40))),std::string::npos);

    		ostr <<"|Semname:" << TaskUserData[i].semaphore_name;
    		ostr <<"|Tstamp: "  << TaskUserData[i].semop_timestamp;
    		ostr <<"|Filename:"<< tempstr;
    	    ostr <<"|Linenum: "<< TaskUserData[i].source_code_line_num;

			  if (TaskUserData[i].sem_last_op == SEM_LAST_OP_WAS_PEND)
			  {
			   ostr << "|PEND";
			  } else
			  {
				ostr <<"|POST";
			  }

			  ostr <<"|Callfunc:"<< TaskUserData[i].calling_func;

    		}
			  ostr << "\n";
			  ostr << "---------------------------------------------------------------------------------------------------\n";
    	}
    }
    ostr << "========================================================================\n";
    return (ostr.str());
}

void print_pktlog() {
	std::string str = raw_print_pktlog();
	safe_print(printf(str.c_str()));
}

std::string raw_print_pktlog() {
     std::ostringstream ostr;
     char str[255];
	 int num_big_used = 0;
	 int num_sml_used = 0;
	 char *alloc_procname = NULL;

	 int local_OSLockNesting = OSLockNesting;
     int local_OSIntNesting = OSIntNesting;
	 int local_OSPrioHighRdy = OSPrioHighRdy;

	 ostr <<"\n=========================================================================================\n";
	 ostr << get_current_time_and_date_as_string() << "\n";
#ifdef NPDEBUG
	 for (int i = 0; i < MAXPACKETS; i++) {
	   if (pktlog[i]->inuse != 0) {
	     if (i < NUMBIGBUFS) {
	     	 num_big_used++;
	      } else {
	     	 num_sml_used++;
	      }
	   }
	 }
#else
	 ostr <<"Warning: NPDEBUG not enabled, packet log stats cannot be gathered\n";
#endif

#ifdef NPDEBUG

	 snprintf(str,160,"Total: %4d/%4d BIGBUFS used, %4d/%4d LILBUFS\n",num_big_used,(int) NUMBIGBUFS,num_sml_used,(int) NUMLILBUFS);
     ostr<<str;
	 ostr << "Ticks/sec:" << alt_ticks_per_second() << " OSLockNesting: " << (int) local_OSLockNesting << "OSIntNesting: " <<  (int) local_OSIntNesting << " OSPrioHighRdy: " << local_OSPrioHighRdy << " Calling Proc: " << (int) OSTCBCur->OSTCBPrio << "\n";

	 if (enable_deep_packet_stats) {
			 for (int i = 0; i < MAXPACKETS; i++) {
				 if (pktlog[i]->inuse) {
					 alloc_procname =  TaskUserData[pktlog[i]->allocating_process].TaskName;
				 } else {
					 alloc_procname = NULL;
				 }
				 snprintf(str,160,"Packet[%4d]|Type:%s|NumUsers:%3d|AllocProc:%3u|Name:%-18s|TimeAlloc:%12d\n", i, (i < NUMBIGBUFS) ? "BIG": "SML", (int) (pktlog[i]->inuse), pktlog[i]->allocating_process, alloc_procname, pktlog[i]->time_allocated);
				 ostr << str;
			 }
			 ostr<<"------------------------------------------------------------------------------------------\n";
		     snprintf(str,160,"Total: %4d/%4d BIGBUFS used, %4d/%4d LILBUFS\n",num_big_used,(int) NUMBIGBUFS,num_sml_used,(int) NUMLILBUFS);
		     ostr<<str;
	 }
#endif
     ostr<<"=========================================================================================\n";
     return (ostr.str());
}


INT8U register_os_event_name(OS_EVENT* eptr,const char *the_name)
{
    INT8U error_code;
	char name[OS_EVENT_NAME_SIZE];
	snprintf(name,OS_EVENT_NAME_SIZE-5,"%s",the_name);
    OSEventNameSet(eptr,(INT8U *)name,&error_code);
    if (error_code != OS_NO_ERR) {
		safe_print(printf("Error in initializing Event name: [%s], error is [%d]\n",the_name,(int)error_code));
	}
    return error_code;
}



std::string  sstring_TaskStat_print (INT8U id, INT8U pct)
{
    char s[200];
    snprintf(s,195,"%2d %-18s %3d%%  %05u      %8u          %10ld  %10ld  %10ld %p\n",
            (int)id,
            TaskUserData[id].TaskName,
            (int) pct,
            TaskUserData[id].TaskCtr,
            TaskUserData[id].TaskExecTime,
            TaskUserData[id].TaskTotExecTime,
            OSTCBPrioTbl[id]->OSTCBStkSize,
            OSTCBPrioTbl[id]->OSTCBStkUsed,
            OSTCBPrioTbl[id]->OSTCBStkPtr
            );
   return string(s);
}

std::string get_task_stat_str()
{
	  INT8U  i;
	  INT32U total;
	  INT8U  pct;
      std::ostringstream ostr;

	 ostr << "\nProcess Statistics Table\n";
	 ostr << "========================================================================================================\n";
	      //19 Statistics          63 %   26960          2              164870
	  ostr<< "ID Name                %%   #time called  Last Duration    Total Duration  StkSize    StkUsed    StkPtr\n";
	  total = 0L;                                          /* Totalize TOT. EXEC. TIME for each task */
	  for (i = 0; i <= OS_LOWEST_PRIO; i++) {
	      total += TaskUserData[i].TaskTotExecTime;
	  }
	  ostr << "\n"; //newline for nice printing
	  if (total > 0) {
	      for (i = 0; i <= OS_LOWEST_PRIO; i++) {                        /* Derive percentage of each task         */
	          pct = 100 * TaskUserData[i].TaskTotExecTime / total;
	             ostr << sstring_TaskStat_print(i,pct);                                 /* Display task data                      */
	      }
	  }
	  ostr<<"\n";
	  ostr << get_memory_usage_stats();
	  ostr << "========================================================================================================\n";
	  return ostr.str();

}
