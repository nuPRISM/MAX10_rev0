/*
 * FILENAME: ftpsport.c
 *
 * Copyright  2000-2008 By InterNiche Technologies Inc. All rights reserved
 *
 *
 * MODULE: FTPSERVER
 *
 * ROUTINES: ftps_init(), ftps_check(), fs_lookupuser(), 
 * ROUTINES: ftps_cleanup(), 
 *
 * PORTABLE: no
 */

/* Additional Copyrights: */

/* ftpsport.c 
 * Portions Copyright 1996 by NetPort Software. All rights reserved. 
 * The Port-dependant portion of the FTP Server code. 11/24/96 - 
 * Created by John Bartas 
 */

#include "linnux_utils.h"
extern "C" {
#include "ipport.h"
#define  FTP_SERVER 1
}
#include "simple_socket_server.h"
#include "ftpport.hh"    /* TCP/IP, sockets, system info */
#include "ftpsrv.hh"


#include "basedef.h"
#include <string>
#include <vector>

#include OSPORT_H

struct sockaddr_in   ftpssin;

#ifdef IP_V4
SOCKTYPE ftps_sock = SYS_SOCKETNULL;
#endif   /* IP_V4 */

#ifdef FTP_SERVER
extern int  ftps_init(void);
extern void ftps_cleanup(void);

extern void ftps_check(void);
#endif

std::vector<userinfo> ftp_users(0);


int ftp_add_user(std::string username, std::string password)
{
   userinfo new_user_record;
   if (username == "") return FALSE;  /* don't allow null user */

   new_user_record.group = NULL;
   new_user_record.username = username;
   new_user_record.password = password;
   ftp_users.push_back(new_user_record);
   return TRUE;
}




/* FUNCTION: ftps_init()
 * 
 * ftps_init() - this is called by the ftp server demo package once 
 * at startup time. It initializes the vfs and opens a tcp socket to 
 * listen sfor web connections 
 *
 * If FTP_CLIENT and INCLUDE_NVPARMS are both enabled, then we need to
 * change a couple of FTP_CLIENT parameters to that in the NV file.
 *
 * PARAM1: 
 *
 * RETURNS: Returns 0 if OK, non-zero if error. 
 */

int
ftps_init()
{
   unshort  port;
   int      opens = 0;

   /* add default users for this port */
   /* anonymous makes you enter a password, we just don't care what it is */
   /*
   ftp_add_user("anonymous", "*");
   ftp_add_user("guest", "guest");
   ftp_add_user("linnux", "linnux");
   ftp_add_user("linnux_admin","linnuxrules");
   */
   port = FTP_PORT;

#ifdef IP_V4
   ftps_sock = my_t_tcplisten(&port, AF_INET);
   if (ftps_sock == SYS_SOCKETNULL)
      dprintf("[%s]FTP server: unable to start listen\n",get_current_time_and_date_as_string_trimmed().c_str());
   else
      opens++;
#endif   /* IP_V4 */


   if (opens == 0)
      return -1;

   return 0;
}

#ifndef MINI_TCP

/* Accept a new FTP command connection
 *
 * Returns 0 if OK, or ENP error code 
 */

int
ftp_accept(int domain, SOCKTYPE ftps_sock, int clientlen)
{
   SOCKTYPE socktmp;
   struct sockaddr client;
   int   err;
   ftpsvr * ftps;

   socktmp = t_accept(ftps_sock, &client, &clientlen);
   if (socktmp != SYS_SOCKETNULL)
   {
      ftps = my_ftps_connection(socktmp);
      if (ftps == NULL)
         return ENP_NOMEM;    /* most likely problem */
      ftps->domain = domain;
   }
   else
   {
      err = t_errno(ftps_sock);
      if (err != EWOULDBLOCK)
      {
         return err;
      }
   }
   return 0;
}
#endif   /* ndef MINI_TCP */


/* FUNCTION: ftps_check()
 * 
 * ftp server task loop. For the PC DOS demo, this is called once 
 * every main task loop. 
 *
 * PARAM1: 
 *
 * RETURNS: 
 */

static int in_ftps_check = 0;    /* reentry guard */

void
ftps_check()
{
   in_ftps_check++;
   if (in_ftps_check != 1)
   {
      in_ftps_check--;
      return;
   }

   {
      fd_set ftp_fdrecv;
      fd_set ftp_fdsend;
      ftpsvr *ftp;
      int events;             /* return from select() */

      FD_ZERO(&ftp_fdrecv);
      FD_ZERO(&ftp_fdsend);

      /* use the recv array to detect new connections */
      if (put_ftp_in_a_safe_state)
            {
    	      in_ftps_check--;
          	  return;
            }
      if (ftps_sock != SYS_SOCKETNULL)
      {
         FD_SET(ftps_sock, &ftp_fdrecv);
      }
      if (FD_COUNT(&ftp_fdrecv) == 0)
         return;

      /* loop through ftp structs building read/write arrays for select */
      for (ftp = my_ftplist; ftp; ftp = ftp->next)
      {
    	  if (put_ftp_in_a_safe_state)
    	        {
    		      in_ftps_check--;
    	      	  return;
    	        }
      /* add ftp server's open sockets to the FD lists based on
       * their state. The server thread will block until one of
       * these has activity.
       */

         FD_SET(ftp->sock, &ftp_fdrecv);
         if (ftp->datasock && (ftp->datasock != SYS_SOCKETNULL))
         {
            /* always add the data socket to the receive FD_SET */
            FD_SET(ftp->datasock, &ftp_fdrecv);
            /* only add the send socket if we are actively sending */
            if (ftp->state == FTPS_SENDING)
            {
               FD_SET(ftp->datasock, &ftp_fdsend);
            }
         }
      }  /* end of for(ftplist) loop */

      /* block until one of the sockets has activity */
      if (put_ftp_in_a_safe_state)
            {
    	      in_ftps_check--;
          	  return;
            }
      /*
      struct timeval timeout;
      timeout.tv_sec = 10;
      timeout.tv_usec = 0;
      */

      events = t_select(&ftp_fdrecv, &ftp_fdsend, (fd_set *)NULL, -1);
      /*
      do {
          events = t_select(&ftp_fdrecv, &ftp_fdsend, (fd_set *)NULL, 1);
      } while ((events == 0) && (!put_ftp_in_a_safe_state)); //repeat so long as timeout has been reached and no request to put in a safe state
      */
      if (put_ftp_in_a_safe_state)
      {
        in_ftps_check--;
        return;
      }

      if (FD_ISSET(ftps_sock, &ftp_fdrecv))  /* got a connect to server listen? */
      {
         ftp_accept(AF_INET, ftps_sock, sizeof(struct sockaddr_in));
         events--;
      }

      if (events <= 0)  /* connect was only socket */
      {
         in_ftps_check--;
         return;
      }
   }

   /* work on existing conections - data or command */
   my_ftps_loop();

   in_ftps_check--;
   return;
}




/* FUNCTION: fs_lookupuser()
 * 
 * fs_lookupuser() lookup a user based on the name. Fill in user 
 * struct in ftp, including password. If no password required, fill 
 * in null string. Filled in data is in unencrypted form. This 
 * particular port is for the user database in ..\misclib\userpass.c 
 * 
 * PARAM1: ftpsvr * ftp
 * PARAM2: char * username
 *
 * RETURNS: Returns 0 if user found, else -1 if user invalid. 
 */

int
fs_lookupuser(ftpsvr * ftp, std::string username)
{
   size_t   current_user_index;
   TrimSpaces(username);

   bool found = false;

   for (current_user_index = 0; current_user_index < ftp_users.size(); current_user_index++)
   {
      if (ftp_users.at(current_user_index).username == username)
      {
    	 found = true;
         break;
      }
   }

   if (!found) {
      return -1;
   }
   /* extract username from command  */
   ftp->user.username = username;
   ftp->user.password = ftp_users.at(current_user_index).password;
   ftp->user.home = "c:\\";  /* default for DOS port */
   return 0;
}

void  my_delftp(ftpsvr * ftp);


/* FUNCTION: ftps_cleanup()
 * 
 * Close down all the connections to FTP Server. Then close the
 * socket used for FTP Server listen 
 *
 * PARAM1: void
 *
 * RETURNS: 
 */

void 
ftps_cleanup(void)
{
   ftpsvr * ftp;
   ftpsvr * ftpnext;

   ftpnext = my_ftplist;   /* will be set to ftp at top of loop */

   /* loop throught connection list */
   while (ftpnext)
   {
      ftp = ftpnext;
      ftpnext = ftp->next;   
      my_delftp(ftp);   /* kill the connection */
      MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_LONG_PROCESS_DLY_MS);
   }

   if ( ftps_sock != INVALID_SOCKET )
   {
      sys_closesocket(ftps_sock);
      ftps_sock = INVALID_SOCKET ;     
   }

}


long ftpsrv_wakes   =  0;


/* The application thread works on a "controlled polling" basis:
 * it wakes up periodically and polls for work. If there is outstanding
 * work, the next wake is accellerated to give better performance under
 * heavy loads.
 *
 * The FTP task could aternativly be set up to use blocking sockets,
 * in which case the loops below would only call the "xxx_check()"
 * routines - suspending would be handled by the TCP code.
 */

/* FUNCTION: tk_ftpsrv()
 * 
 * PARAM1: n/a
 *
 * RETURNS: n/a
 */
int    ftp_is_in_a_safe_state = 0;

TK_ENTRY(tk_ftpsrv)
{
   int e;
   int network_event_is_ocurring = 0;

   static int already_registered_exit_hook = 0;

   while (!iniche_net_ready)
      TK_SLEEP(1);


   re_init_ftp:
   ftp_is_in_a_safe_state = 1;

   if (put_ftp_in_a_safe_state) {
       network_event_is_ocurring = 1;
       safe_print(printf("[%s][FTP]FTP performing cleanup!\n",get_current_time_and_date_as_string_trimmed().c_str()));
       ftps_cleanup();
       safe_print(printf("[%s][FTP]FTP after cleanup!\n",get_current_time_and_date_as_string_trimmed().c_str()));
   	   safe_print(printf("[%s][FTP]FTP is in a safe state!\n",get_current_time_and_date_as_string_trimmed().c_str()));
   }

   while (put_ftp_in_a_safe_state) {
	   safe_print(printf("[%s][FTP]FTP is in a safe state!\n",get_current_time_and_date_as_string_trimmed().c_str()));
   		MyOSTimeDlyHMSM(0,0,LINNUX_NETWORK_SAFE_STATE_DELAY_IN_SECONDS,0);
   }

   ftp_is_in_a_safe_state = 0;

   if (network_event_is_ocurring) {
	    network_event_is_ocurring = 0;
        safe_print(printf("[%s][FTP]FTP is functional\n",get_current_time_and_date_as_string_trimmed().c_str()));
   }

   safe_print(printf("[%s][FTP]FTP before ftps_init\n",get_current_time_and_date_as_string_trimmed().c_str()));
   do {
	   e = ftps_init();
	   safe_print(printf("[%s][FTP]FTP after ftps_init, returned [%d]\n",get_current_time_and_date_as_string_trimmed().c_str(),e));
	   if (e !=0)
	   {
		   safe_print(printf("[%s][FTP]Error in ftps_init, sleeping and trying again in %d seconds\n",get_current_time_and_date_as_string_trimmed().c_str(),LINNUX_NETWORK_RECUPERATION_DELAY_IN_SECONDS));
		   MyOSTimeDlyHMSM(0,0,LINNUX_NETWORK_RECUPERATION_DELAY_IN_SECONDS,0);
	   }
   } while (e!=0);

   if (!already_registered_exit_hook)
   {
	   safe_print(printf("[%s][FTP]Registering FTP exit hook\n",get_current_time_and_date_as_string_trimmed().c_str()));
	   already_registered_exit_hook = 1;
	   exit_hook(ftps_cleanup);
   }

   for (;;)
   {
       MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);

	   if (put_ftp_in_a_safe_state) {
		   goto re_init_ftp;
	   }

      ftps_check();     /* may block on select */

      if (put_ftp_in_a_safe_state) {
         goto re_init_ftp;
      }

      ftpsrv_wakes++;   /* count wakeups */
      if (net_system_exit)
         break;
   }
   TK_RETURN_OK();
}

