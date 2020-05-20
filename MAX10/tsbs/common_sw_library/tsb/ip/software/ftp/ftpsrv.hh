/*
 * FILENAME: FTPSRV.H
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

/* ftpsrv.h FTP server for WebPort HTTP server. 
 * 1/12/97 - Created. John Bartas 
 */
#ifndef FTPSVR_H
#define  FTPSVR_H 1
extern "C" {
  #include "ipport.h"
  #include "chan_fatfs/ff.h"
}
#include "ftpport.hh"
#include <string>

#define dbgftp(args...) do { if (linnux_ftp_debug) { printf(args); } } while (0)

//#define my_dtrap() do { safe_print(std::cout << "dtrap error in: file: [" << __FILE__ << "] function: [" << __FUNCTION__ << "] line: [" << __LINE__ << std::endl);  } while (0)
#define my_dtrap() do { printf("dtrap error in: file: [%s] function: [%s] line: [%d]\n",__FILE__,__FUNCTION__,__LINE__);  } while (0)

#define  vfopen(file,   mode) f_open(file, mode)
#define  vfread(buf, ct,   size, fp)   f_read(buf,  ct,   size, fp)
#define  vfwrite(buf,   ct,   size, fp)   f_write(buf, ct,   size, fp)
#define  vgetc(fp)   f_getc(fp)
#define  vfclose(fp) f_close(fp)
#define  vunlink(fp) f_unlink(fp)
#define  VFILE FIL

#define  FTP_PORT 21 /* standard FTP command port */

class userinfo {
public:
   std::string  username;
   std::string  password;
   std::string  home;  /* user's "home" directory */
   void *   group;   /* for use by port */
   userinfo() {
	   username = "";
	   password = "";
	   home = "";
	   group = NULL;
   }
};

int ftp_add_user(std::string username, std::string password);

#ifndef ip_addr
#define  ip_addr     u_long
#endif

class ftpsvr {
public:
   int      file_is_open;
   ftpsvr*  next; /* list link */
   int      inuse;      /* re-entry semaphore */
   SOCKTYPE sock;    /* client command socket */
   SOCKTYPE datasock;/* client   data  socket */
   int      state;      /* one of FTPS_ defines below */
   u_long   lasttime;   /* ftptick when last action occured */
   userinfo user;   //TODO: BUG here if ftpsvrs is used with memset or calloc
   int      logtries;   /* retry count of logins */
   int      type;       /* ASCII or BINARY */
   VFILE    filep;      /* pointer to open file during IO */
   ip_addr  host;       /* FTP client */
   u_short  dataport;   /* client data TCP port */
   unsigned int   passive_state; /* state info for PASV command */
   u_long         passive_cmd;   /* file XFER command in passive state */
   u_short        server_dataport;  /* data port we listen on in passive mode */
   char  cwd[FTPMAXPATH+1];   /* current directory, e.g. "/" or "/tmp/foo/" */
   char  RNFR_Path[FTPMAXPATH+1];   /* current directory, e.g. "/" or "/tmp/foo/" */
   char  RNTO_Path[FTPMAXPATH+1];   /* current directory, e.g. "/" or "/tmp/foo/" */

   char  filename[FTPMAXPATH+FTPMAXFILE];
   char  cmdbuf[CMDBUFSIZE];  /* buffer for comamnds from client */
   unsigned    cmdbuflen;     /* number of bytes currently receieved in cmdbuf */
   char  filebuf[FILEBUFSIZE];   /* file buffer for data socket & file IO */
   unsigned    filebuflen;    /* amount of data actually in filebuf */
   int   wFlag;            /* flags for write blocked, et. al. */
   int   domain;           /* AF_INET or AF_INET6 */
   ftpsvr() {
	      file_is_open = 0;
	      next         = NULL;
	      inuse        = 0;
	      sock         = 0;
	      datasock     = 0;
	      state        = 0;
	      lasttime     = 0;
	      logtries     = 0;
	      type         = 0;
	      host         = 0;
	      dataport     = 0;
	      passive_state= 0;
	      passive_cmd  = 0;
	      server_dataport = 0;
              for (int i = 0; i < FTPMAXPATH+1; i++ ) 
	      {
	         cwd[i] = '\0'; 
	         RNFR_Path[i] = '\0';
	         RNTO_Path[i] = '\0';
          }
              for (int i = 0; i < FTPMAXPATH+FTPMAXFILE; i++ ) 
	      {
	         filename[i] = '\0';  
              }

	      for (int i = 0; i < CMDBUFSIZE; i++ ) 
	      {
	         cmdbuf[i] = '\0';  
              }
	      
	      cmdbuflen = 0;   
	      
	      for (int i = 0; i < FILEBUFSIZE; i++ ) 
	      {
	         filebuf[i] = '\0'; 
              }
	      filebuflen = 0;   
	      	  
	      wFlag = 0;
	      domain = 0;
   }
};

extern   ftpsvr * my_ftplist; /* master list of FTP connections */

extern   u_long   my_ftps_connects;
extern   u_long   my_ftps_txfiles;
extern   u_long   my_ftps_rxfiles;
extern   u_long   my_ftps_txbytes;
extern   u_long   my_ftps_rxbytes;
extern   u_long   my_ftps_dirs;


/* ftpsvr.states: */
#define  FTPS_CONNECTING   1     /* connected, no USER info yet */
#define  FTPS_NEEDPASS     2     /* user OK, need password */
#define  FTPS_LOGGEDIN     3     /* ready to rock */
#define  FTPS_SENDING      4     /* sending a data file in progress */
#define  FTPS_RECEIVING    5     /* receiveing a data file in progress */
#define  FTPS_CLOSING      9     /* closing */

#define  FTPTYPE_ASCII     1
#define  FTPTYPE_IMAGE     2

/* ftpsvr.passive_state bits */
#define  FTPS_PASSIVE_MODE 0x01  /* session is in passive mode */
#define  FTPS_PASSIVE_CONNECTED  0x02  /* client has connected to data port */

/* FTP server internal commands */
char *   my_ftp_cmdpath(ftpsvr * ftp); /* extract path from cmd text */
char *   uslash(char * path);       /* make path into UNIX slashes */

/* required OS dependant routines */
int      fs_dodir(ftpsvr * ftp, u_long ftpcmd);
void     lslash(char * path);       /* make path into local slashes */
int      fs_dir(ftpsvr * ftp);      /* verify drive:/path exists */
int      fs_permit(ftpsvr * ftp);   /* verify user permission */
int      fs_lookupuser(ftpsvr * ftp, std::string username);

/* macro to insert optional drive letter in sprintfs */
#define  DRIVE_PTR(ftp) ""

/* prototype server exported routines */
ftpsvr * my_ftps_connection(SOCKTYPE);   /* new connection */
void     my_ftp_leave_passive_state(ftpsvr * ftp);
void     my_ftps_loop(void);    /* periodic loop (tick) */
int      my_ftps_v4pasv(ftpsvr * ftp);
int      ftps_v6pasv(ftpsvr * ftp);
void     ftps_eprt(ftpsvr * ftp);
void     ftps_epsv(ftpsvr * ftp);
void     my_delftp(ftpsvr *ftp);
/* define the macro/routine FTP_TCPOPEN() based on version ifdefs */

SOCKTYPE my_ftp4open(ftpsvr * ftp);
#define FTP_TCPOPEN(ftp) my_ftp4open(ftp)
#endif   /* FTPSVR_H */

/* end of file ftpsrv.h */


