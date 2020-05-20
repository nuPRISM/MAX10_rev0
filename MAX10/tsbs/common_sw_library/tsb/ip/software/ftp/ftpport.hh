/*
 * FILENAME: FTPPORT.H
 *
 * Copyright 1997- 2000 By InterNiche Technologies Inc. All rights reserved
 *
 *
 * MODULE: FTP
 *
 * ROUTINES:
 *
 * PORTABLE: yes
 */

/* ftpport.h FTP server's per-port definitions. 
 * 1/12/97 - Created as part of cleanup. John Bartas 
 */

#ifndef _FTPPORT_H_
#define  _FTPPORT_H_    1
extern "C" {
#include <ctype.h>
  #include "ipport.h"
  #include "libport.h"
  #include "tcpapp.h"
  #include "userpass.h"
}


/* Implementation defines: */
#define  FTPMAXPATH     1024   /* max path length, excluding file name */
#define  FTPMAXFILE     1024    /* max file name length w/o path */
#define  CMDBUFSIZE     2050
/* #define  CMDBUFSIZE     1024  // Texas Imperial Sw's WFTD sends a BIG welcome str */

#ifndef FILEBUFSIZE     /* Allow override from ipport.h */
#define  FILEBUFSIZE    (6*1024)
#endif   /* FILEBUFSIZE */

#define  FTPMAXUSERNAME    MAX_USERLENGTH
#define  FTPMAXUSERPASS    MAX_USERLENGTH

/* default port for FTP data transfers. This can default to 20 (as 
 * some interpret the RFC as recommending) or default to 0 to let the 
 * sockets layer pick a port randomly. It could even point to a user 
 * provided routine which determines a port number alogrithmically.
 */
#define  FTP_DATAPORT      20

/* set up file system options for target system */

#define  FTP_SLASH   '/'   /* use UNIX style slash */

/* define clock tick info for DOS */
#define  FTPTPS   (TPS/4)      /* number of ftps_loop calls per second */
#define  ftpticks cticks


unshort  my_SO_GET_FPORT(WP_SOCKTYPE so);
unshort  my_SO_GET_LPORT(WP_SOCKTYPE so);

/* Added sys_ routines for FTP support */
SOCKTYPE my_t_tcplisten(u_short * lport, int doamin);
SOCKTYPE t_tcpopen(ip_addr host, u_short lport, u_short fport);

/* Configurable limit on max number of ftp sessions.  Setting this value to 0 or
 * -1 results in no limitation on number of sessions.  The default value is 32.
 */
#ifndef MAX_FTPS_SESS   /* allow tuning from ipport.h */
#define MAX_FTPS_SESS 32
#endif  /* MAX_FTPS_SESS */

/* map ftp's timer tick count to system's */
#define  ftp_ticks   cticks

/* map FTP server's alloc and free to local mem library */
#define  FTPSALLOC(size)   my_ftps_alloc()
#define  FTPSFREE(ptr)     my_ftps_free(ptr)

/* FTP Client related non-volatile parameters. Please see nvparms.h 
 * and nvparms.c regarding the usage of the following structure.
 */

#endif   /* _FTPPORT_H_ */

