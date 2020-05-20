/*
 * FILENAME: ftpssock.c
 *
 * Copyright  2000 - 2002 By InterNiche Technologies Inc. All rights reserved
 *
 *    Sockets specific code for FTP. FTP Implementations on APIs 
 * other than sockets need to replace these.
 *
 * MODULE: FTP
 *
 * ROUTINES: ftp_cmdcb(), ftp_datacb(), t_tcplisten(), 
 * ROUTINES: FTP_TCPOPEN(), ftp4open(), ftp6open(), SO_GET_FPORT(), 
 * ROUTINES: SO_GET_LPORT(), ftps_v4pasv(), ftps_eprt(), ftps_epsv(), 
 *
 * PORTABLE: yes
 */

/* Additional Copyrights: */

/* ftpssock.c 
 * Portions Copyright 1996 by NetPort Software. All rights reserved. 
 * The Sockets-dependant portion of the FTP Server code. 
 * 11/24/96 - Created by John Bartas 
 */
#include "ftpport.hh"    /* TCP/IP, sockets, system info */
#include "ftpsrv.hh"
#include "basedef.h"
#include <string>
#include "linnux_utils.h"
SOCKTYPE my_t_tcplisten(u_short * lport, int domain)
{
   int   e;
   int errornum;
   SOCKTYPE sock;

   sock = t_socket(domain, SOCK_STREAM, 0);
   if (sock == SYS_SOCKETNULL)
      return sock;

	int reuse= 1;
	if ((errornum = (int) t_setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &reuse,  1))== -1)
	{
		safe_print(printf("[FTP: my_t_tcplisten] setsockopt() to REUSE failed\n"));
	}

   switch(domain)
   {
      case AF_INET:
      {
         struct sockaddr_in   ftpsin;
         int addrlen = sizeof(ftpsin);

         ftpsin.sin_family = AF_INET;
         ftpsin.sin_addr.s_addr = INADDR_ANY;
         ftpsin.sin_port = htons(*lport);
         e = t_bind(sock, (struct sockaddr*)&ftpsin, addrlen);
         if (e != 0)
         {
            e = t_errno(sock);
            my_dtrap();
            safe_print(dprintf("error %d binding tcp listen on port %d\n",
             e, htons(*lport)));
            return SYS_SOCKETNULL;
         }
         if(*lport == 0)   /* was it wildcard port? */
            *lport = htons(ftpsin.sin_port); /* return it to caller */
      }
      break;
      default:
         my_dtrap();    /* bad domain parameter */
         return SYS_SOCKETNULL;
   } /* end switch(domain) */

   /* For FTP, put socket in non-block mode */
   t_setsockopt(sock, SOL_SOCKET, SO_NBIO, NULL, 0);
   
   e = t_listen(sock, 5);
   if (e != 0)
   {
      e = t_errno(sock);
      safe_print(dprintf("error %d starting listen on ftp server\n", e));
      return SYS_SOCKETNULL;
   }

   return sock;   /* return listen sock to caller */
}


SOCKTYPE my_ftp4open(ftpsvr * ftp)
{
   int   e; /* error holder */
   SOCKTYPE sock;
   struct sockaddr_in   ftpsin;
   dbgftp("my_ftp4open 1\n");
   sock = t_socket(AF_INET, SOCK_STREAM, 0);
   if (sock == SYS_SOCKETNULL)
      return sock;

   /* Change the socket options to allow address re-use. A customer 
    * requested this to ease implementing an FTP client with multiple 
    * connections.
    */
   dbgftp("my_ftp4open 2\n");

   if (ftp->server_dataport)
   {
	   dbgftp("my_ftp4open 3\n");
      int  opt = 1;	/* boolean option value holder */

      e = t_setsockopt(sock, 0, SO_REUSEADDR, &opt, sizeof(opt));
      if (e != 0)
      {
    	   dbgftp("my_ftp4open 4\n");

         e = t_errno(sock);
         my_dtrap();
         safe_print(dprintf("error %d setting SO_REUSEADDR on port %d\n",
               e, ftp->server_dataport));
         dbgftp("my_ftp4open 5\n");

         return SYS_SOCKETNULL;

      }
      dbgftp("my_ftp4open 6\n");

      /* Bind local port to the socket we just created */
      ftpsin.sin_family = AF_INET;
      ftpsin.sin_addr.s_addr = INADDR_ANY;
      ftpsin.sin_port = htons(ftp->server_dataport);

      e = t_bind(sock, (struct sockaddr*)&ftpsin, sizeof(ftpsin));
      if (e != 0)
      {
    	   dbgftp("my_ftp4open 7\n");

         e = t_errno(sock);
         my_dtrap();
         dbgftp("my_ftp4open 8\n");

         safe_print(dprintf("error %d binding tcp listen on port %d\n",
            e, ftp->server_dataport));
         return SYS_SOCKETNULL;
      }
   }
   dbgftp("my_ftp4open 9\n");

   ftpsin.sin_addr.s_addr = htonl(ftp->host);
   ftpsin.sin_port = htons(ftp->dataport);

   ftpsin.sin_family = AF_INET;
   e = t_connect(sock, (struct sockaddr*)&ftpsin, sizeof(ftpsin));
   dbgftp("my_ftp4open 10\n");

   if (e != 0)
   {
	   dbgftp("my_ftp4open 11\n");

      my_dtrap();
      return SYS_SOCKETNULL;
   }

   /* FTP data socket can be in blocking or non-blocking mode */

   t_setsockopt(sock, 0, SO_NBIO, NULL, 0);
   
   return sock;
}


/* FUNCTION: SO_GET_FPORT()
 * 
 * Return the foreign port of a socket. No error checking is done. It's
 * up to the caller to make sure this socket is connected before calling.
 *
 * PARAM1: the socket
 *
 * RETURNS: Returns the foreign port of the passed socket. 
 */

unshort my_SO_GET_FPORT(SOCKTYPE sock)
{
	   dbgftp("my_SO_GET_FPORT 1\n");

   struct sockaddr   client;
   int      clientsize;
   unshort port;

   clientsize = sizeof(client);
   t_getpeername(sock, &client, &clientsize);
   port = ((struct sockaddr_in *)(&client))->sin_port;
   dbgftp("my_SO_GET_FPORT 2\n");
   return (ntohs(port));
}

/* FUNCTION: SO_GET_LPORT()
 * 
 * Return the foreign port of a socket. No error checking is done. It's
 * up to the caller to make sure this socket is connected before calling.
 *
 * PARAM1: the socket
 *
 * RETURNS: Returns the foreign port of the passed socket. 
 */

unshort SO_GET_LPORT(WP_SOCKTYPE sock)
{
   struct sockaddr_in   client;
   int      clientsize;
   unshort port;

   clientsize = sizeof(client);
   t_getsockname(sock, (struct sockaddr *) &client, &clientsize);
   port = ((struct sockaddr_in *)(&client))->sin_port;
   return (ntohs(port));
}



/* error reporting mechanism for open sessions. "text" should start
 * with an FTP code (e.g. "425 " since it will be sent to client
 * on the command connection.
 */
extern int ftpputs(ftpsvr * ftp, char * text);

static  char *   err   = "425 Can't open data connection\r\n";


int my_ftps_v4pasv(ftpsvr * ftp)
{
   SOCKTYPE sock;
   u_short  port;
   unsigned long addr;
   char  responseBuf[80];

   /* create a TCP socket to listen on, it will be the data socket.
    * First set port to 0 so sockets will pick one for us
    */
   dbgftp("my_ftps_v4pasv 1\n");


   port = 0;
   dbgftp("my_ftps_v4pasv 1a\n");
   sock = my_t_tcplisten(&port, AF_INET); /* call API to start listen */
   dbgftp("my_ftps_v4pasv 1b\n");
   if (sock == SYS_SOCKETNULL)   /* if socket creation failed */
   {
	   dbgftp("my_ftps_v4pasv 2\n");
      ftpputs(ftp, err);
      return EIEIO;
   }

   /* get our address and data port so we can tell the client
    * what address to connect to.
    */

{
   struct sockaddr_in   our_addr;
   int   sa_len = sizeof(our_addr);
   dbgftp("my_ftps_v4pasv 3\n");
   if (t_getsockname(ftp->sock,(struct sockaddr *) &our_addr, &sa_len))
   {
      /* tell client pasv failed */
      ftpputs(ftp,err);
      return t_errno(sock);
   }
   dbgftp("my_ftps_v4pasv 4\n");
   /* extract and convert to local endian our command socket address */
   addr = ntohl(our_addr.sin_addr.s_addr);
   dbgftp("my_ftps_v4pasv 5\n");
   /* get our port on the data socket */
   if (t_getsockname(sock,(struct sockaddr *) &our_addr, &sa_len))
   {
	   dbgftp("my_ftps_v4pasv 6\n");
      /* close the socket we just opened */
      t_socketclose(sock);
      dbgftp("my_ftps_v4pasv 6b\n");
      /* tell client pasv failed */
      ftpputs(ftp,err);
      dbgftp("my_ftps_v4pasv 7\n");
      return t_errno(sock);
   }

   /* extract and convert to local endian our data socket port */
   port = ntohs(our_addr.sin_port);
}

    /* create our response which tells the client what address and
    * port to connect to
    */
dbgftp("my_ftps_v4pasv 8\n");
   sprintf(responseBuf,
    "227 Entering Passive Mode (%d,%d,%d,%d,%d,%d)\r\n",
    (int) (addr >> 24), (int) ((addr >> 16) & 0xff),
    (int) ((addr >> 8) & 0xff), (int) (addr & 0xff),
    (int) (port >> 8),(int) (port & 0xff));
   ftpputs(ftp,responseBuf);
   dbgftp("my_ftps_v4pasv 9\n");
   ftp->server_dataport = port;
   ftp->datasock = sock;
   int tcp_nodelay = LINNUX_TELNET_USE_TCP_NODELAY;
   			int errornum;

   			if ((errornum = (int) t_setsockopt(ftp->datasock, IPPROTO_TCP, TCP_NODELAY, &tcp_nodelay,  1))== -1)
   			{
   				std::string timestamp_str = get_current_time_and_date_as_string_trimmed();

   				printf("[%s] ftpsock: setsockopt error - socket option TCP_NODELAY = [%d] for socket [%d], result = [%d] errno = [%d]\n",timestamp_str.c_str(),tcp_nodelay, (int) ftp->datasock, errornum, t_errno(ftp->datasock));
   			} else {
   				dbgftp("Set tcp data socket nodelay");
   			}
   return 0;
}



