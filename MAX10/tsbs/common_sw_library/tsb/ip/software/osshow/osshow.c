///*
// * osshow.c
// *
// *  Created on: Feb 13, 2012
// *      Author: linnyair
// */
//
//
//#include "osshow.h";
//
//extern uint OSMapTbl[];
//extern uint OSRdyGrp;
//extern uint OSRdyTbl[];
//
///*
//**  void uCOS_ShowAllTasks()
//**
//**  DESCRIPTION
//**
//**  RETURNS
//**      None.
//*/
//void uCOS_ShowAllTasks(void)
//{
//    int tid;
//
//    printf(" ---------------------------------------------------------------\n");
//    printf(" -- tid status   usage   event  tmo/eval\n");
//    printf(" ---------------------------------------------------------------\n");
//
//    for (tid = 0; tid < OS_MAX_TASKS; tid++)
//        uCOS_ShowTaskTCB(OSTCBPrioTbl[tid]);
//
//    printf(" ---------------------------------------------------------------\n");
//    printf(" -- CtxSwCtr: %08X IdleCtr: %08X OSTimer: %08X\n",
//        OSCtxSwCtr, OSIdleCtr, OSTime);
//#if 0
//    printf(" -- ShedLock: %08X\n", OSLockNesting);
//    uCOS_ShowReadyTaskList();
//#endif
//}
//
//
///*
//**  void uCOS_ShowAllTasks2(void)
//**
//**  DESCRIPTION
//**
//**  RETURNS
//**      None.
//*/
//void uCOS_ShowAllTasks2(void)
//{
//    OS_TCB* tcb = OSTCBList;
//
//    printf(" ---------------------------------------------------------\n");
//    printf(" -- tid status  event  tmo/eval\n");
//    printf(" ---------------------------------------------------------\n");
//
//    while(tcb->OSTCBPrio <= OS_LOWEST_PRIO)
//    {
//        uCOS_ShowTaskTCB(tcb);
//        tcb = tcb->OSTCBNext;
//    }
//
//    printf(" ---------------------------------------------------------\n");
//    printf(" -- CtxSwCtr: %08X IdleCtr: %08X OSTimer: %08X\n",
//        OSCtxSwCtr, OSIdleCtr, OSTime);
//#if 0
//    printf(" -- ShedLock: %08X\n", OSLockNesting);
//#endif
//}
//
///*
//**  void uCOS_ShowTaskTCB(OS_TCB* tcb)
//**
//**  DESCRIPTION
//**
//**  RETURNS
//**      None.
//*/
//void uCOS_ShowTaskTCB(OS_TCB* tcb)
//{
//    unsigned int eventValue = 0;
//    unsigned char* stkPtr;
//
//    if (tcb != 0)
//    {
//        /* task id, same as task priority */
//        if (tcb == OSTCBCur)
//            printf(" -- %02X* ", tcb->OSTCBPrio);  /* current running task */
//        else
//            printf(" -- %02X  ", tcb->OSTCBPrio);
//
//        /* task status */
//        switch(tcb->OSTCBStat)
//        {
//            case OS_STAT_RDY:
//                printf("ready ");   /* task ready to run */
//                eventValue = 0;
//                break;
//
//            case OS_STAT_SEM:
//                printf("sem   ");   /* wait for semaphore */
//                if (tcb->OSTCBEventPtr != 0)
//                    eventValue = (unsigned int)(tcb->OSTCBEventPtr->OSEventCnt);
//                break;
//
//            case OS_STAT_MBOX:
//                printf("mbox  ");   /* wait for mailbox */
//                if (tcb->OSTCBEventPtr != 0)
//                {
//                    /* This value has to be zero, otherwise we wouldn't wait here */
//                    eventValue = (unsigned int)(tcb->OSTCBEventPtr->OSEventPtr);
//                }
//                break;
//
//            case OS_STAT_Q:
//                printf("queue ");   /* wait for queue message */
//                if (tcb->OSTCBEventPtr != 0)
//                {
//                    /* This value has to be zero, otherwise we wouldn't wait here */
//                    eventValue = (unsigned int)(tcb->OSTCBEventPtr->OSEventPtr);
//                }
//                break;
//
//            case OS_STAT_SUSPEND:
//                printf("suspended ");   /* wait for queue message */
//                eventValue = tcb->OSTCBDly;
//                break;
//
//            default:
//                printf("error ");   /* error status */
//                eventValue = 0;
//                break;
//        }
//
//
//        /* event */
//        printf("%08X ", (int)(tcb->OSTCBEventPtr));
//
//        /* task sleep time */
//        printf("%08X", eventValue);
//
//    }
//}
//
//
///*
//**  void uCOS_ShowAllTaskDetail(void)
//**
//**  DESCRIPTION
//**
//**  RETURNS
//**      None.
//*/
//void uCOS_ShowAllTaskDetail(void)
//{
//    int tid;
//
//    for (tid = 0; tid < OS_MAX_TASKS; tid++)
//    {
//        if (OSTCBPrioTbl[tid] != 0)
//            uCOS_ShowTaskDetail(tid);
//    }
//}
//
//
///*
//**  void uCOS_ShowAllTaskDetail2(void)
//**
//**  DESCRIPTION
//**
//**  RETURNS
//**      None.
//*/
//void uCOS_ShowAllTaskDetail2(void)
//{
//    OS_TCB* tcb = OSTCBList;
//
//    while(tcb->OSTCBPrio <= OS_LOWEST_PRIO)
//    {
//        uCOS_ShowTaskDetailByTCB(tcb);
//        tcb = tcb->OSTCBNext;
//    }
//}
//
//
///*
//**  void uCOS_ShowTaskDetail(unsigned int tid)
//**
//**  DESCRIPTION
//**
//**  RETURNS
//**      None.
//*/
//void uCOS_ShowTaskDetail(unsigned int tid)
//{
//    if (tid >= OS_MAX_TASKS)
//        printf(" -- error: task id\n");
//
//    uCOS_ShowTaskDetailByTCB(OSTCBPrioTbl[tid]);
//}
//
//
///*
//**  void uCOS_ShowTaskDetailByTCB(OS_TCB* tcb)
//**
//**  DESCRIPTION
//**
//**  RETURNS
//**      None.
//*/
//void uCOS_ShowTaskDetailByTCB(OS_TCB* tcb)
//{
//    unsigned int* pStk;
//    pStk = (unsigned int*)tcb->OSTCBStkPtr;
//
//    if (tcb == OSTCBCur)
//        printf(" -- task: %02X* ---------------------------------------------\n",
//            tcb->OSTCBPrio);
//    else
//        printf(" -- task: %02X ----------------------------------------------\n",
//            tcb->OSTCBPrio);
//
//    printf(" -- r00: %08X r01: %08X r02: %08X r03: %08X\n",
//        pStk[2], pStk[3], pStk[4], pStk[5]);
//    printf(" -- r04: %08X r05: %08X r06: %08X r07: %08X\n",
//        pStk[6], pStk[7], pStk[8], pStk[9]);
//    printf(" -- r08: %08X r09: %08X r10: %08X r11: %08X\n",
//        pStk[10], pStk[11], pStk[12], pStk[13]);
//    printf(" -- r12: %08X cpsr:%08X spsr:%08X pc:  %08X\n",
//        pStk[14], pStk[0], pStk[1], pStk[15]);
//
//    /* event */
//    if (tcb->OSTCBEventPtr)
//    {
//        printf(" ----------------------------------------------------------\n");
//        uCOS_ShowEvent(tcb->OSTCBEventPtr);
//    }
//}
//
//
///*
//**  void uCOS_ShowEvent(OS_EVENT* pevent)
//**
//**  DESCRIPTION
//**
//**  RETURNS
//**      None.
//*/
//void uCOS_ShowEvent(OS_EVENT* pevent)
//{
//    if (pevent == 0)
//        return;
//
//    printf(" -- event: %08X count: %08X addr: %08X\n",
//        (int)pevent, pevent->OSEventCnt, (int)pevent->OSEventPtr);
//
//    uCOS_ShowTaskWaitList(pevent->OSEventGrp, pevent->OSEventTbl);
//}
//
//
///*
//**  void uCOS_ShowReadyTaskList(void)
//**
//**  DESCRIPTION
//**
//**  RETURNS
//**      None.
//*/
//void uCOS_ShowReadyTaskList(void)
//{
//    uCOS_ShowTaskWaitList(OSRdyGrp, OSRdyTbl);
//}
//
//
///*
//**  void uCOS_ShowTaskWaitList( unsigned int taskGroup,
//**                              unsigned int* taskTable)
//**
//**  DESCRIPTION
//**
//**  RETURNS
//**      None.
//*/
//
//
//void uCOS_ShowTaskWaitList( unsigned int taskGroup,
//                            unsigned int* taskTable)
//{
//    unsigned int tid;
//
//    printf(" -- Group: %02X Table: %02X %02X %02X %02X %02X %02X %02X %02X\n",
//        taskGroup & 0xff,
//        taskTable[7] & 0xff,
//        taskTable[6] & 0xff,
//        taskTable[5] & 0xff,
//        taskTable[4] & 0xff,
//        taskTable[3] & 0xff,
//        taskTable[2] & 0xff,
//        taskTable[1] & 0xff,
//        taskTable[0] & 0xff);
//
//    printf(" -- tid: ");
//    for (tid = 0; tid < OS_MAX_TASKS; tid++)
//    {
//        if ((taskGroup & OSMapTbl[tid >> 3]) &&
//            (taskTable[tid >> 3] & OSMapTbl[tid & 0x07]))
//        {
//            printf(" %02X", tid);
//        }
//    }
//
//    printf("\n");
//}
//
//
///* end of file */
