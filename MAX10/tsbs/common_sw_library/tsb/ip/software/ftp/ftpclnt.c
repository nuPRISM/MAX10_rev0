/*
 * FILENAME: ftpclnt.c
 *
 * Copyright 1997- 2000 By InterNiche Technologies Inc. All rights reserved
 *
 *
 * MODULE: FTPCLIENT
 *
 * ROUTINES: fc_check(), fc_getreply(), fc_checklogin(), 
 * ROUTINES: fc_checkcmd(), fc_endxfer(), fc_clearf(), fc_sendmore(), 
 * ROUTINES: fc_getmore(), fc_dataconn(), fc_killsess(), fc_connect(), 
 * ROUTINES: fc_get(), fc_put(), fc_connopen(), fc_senduser(), fc_sendpass(), 
 * ROUTINES: fc_sendport(), fc_sendcmd(), fc_dir(), fc_pwd(), fc_chdir(), 
 * ROUTINES: fc_settype(), fc_quit(), fc_ready(), fc_usercmd(), 
 * ROUTINES: fc_hashmark(), fc_state(), fc_pasv(), 
 *
 * PORTABLE: yes
 */

/* ftpclnt.c Generic FTP client. This file contains the guts of the 
 * FTP client logic. There are several entry poins for user commands, 
 * include connect, send, and recv. These initiate a change in the 
 * connection's state machine which is should result in the 
 * performance of the desired task. These jobs are driven by periodic 
 * calls to fc_check, which can be made from a super loop, or a task 
 * which sleeps on ftp_clients == NULL. 
 * 1/12/97 - Created. John Bartas 
 */

#ifdef FTP_CLIENT

#endif /* FTP_CLIENT */
