/*
 * FILENAME: ftpsrv.c
 *
 * Copyright 1997- 2000 By InterNiche Technologies Inc. All rights reserved
 *
 *
 * MODULE: FTPSERVER
 *
 * ROUTINES: ftps_connection(), ftpputs(), ftp_getcmd(), 
 * ROUTINES: ftp_flushcmd(), ftps_loop(), newftp(), delftp(), ftps_user(), 
 * ROUTINES: ftps_password(), ftp_cmdpath(), ftp_make_filename()
 * ROUTINES: ftp_leave_passive_state(), ftps_do_pasv(), ftps_cmd(),
 *
 * PORTABLE: yes
 */
#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <stdio.h>
#include "linnux_utils.h"

#include "ftpport.hh"    /* TCP/IP, sockets, system info */
#include "ftpsrv.hh"     /* FTP server includes */
extern "C" {
#include "target_clock.h"
}
#include "chan_fatfs/diskio.h"
#include "basedef.h"

ftpsvr *my_ftps_alloc() {
	return new ftpsvr;
}

void my_ftps_free(ftpsvr *p) {
	delete p;
}


/* FUNCTION: uslash()
 *
 * uslash() - turn DOS slashes("\") into UNIX slashs ("/"). That's
 * not to imple that UNIX slashes are right or better, just to be
 * consistent.
 *
 *
 * PARAM1: char * path
 *
 * RETURNS:  pointer to formatted text
 */

char *
uslash(char * path)
{
	char *   cp;

	for (cp = path; *cp; cp++)
		if (*cp == '\\')
			*cp = '/';
	return path;
}


/* FUNCTION: lslash()
 *
 * lslash() - format universal (UNIX) slashes '/' into local type.
 * PC-DOS version.
 *
 * PARAM1: char * path
 *
 * RETURNS:
 */

void
lslash(char * path)
{
	char *   cp;

	for (cp = path; *cp; cp++)
		if (*cp == '\\')     /* DOS slash? */
			*cp = '/';     /* convert to normal slash */
}

//#define dbgftp(args...)

static u_long   max_ftps_conn = MAX_FTPS_SESS;

u_long   my_ftps_connects  =  0; /* TCP connections tocmd port */
u_long   my_ftps_sessions  =  0; /* user & password OK */
u_long   my_ftps_badauth   =  0; /* user or password badK */
u_long   my_ftps_txfiles   =  0; /* total data files sent */
u_long   my_ftps_rxfiles   =  0; /* total data files received */
u_long   my_ftps_txbytes   =  0; /* total data bytes received */
u_long   my_ftps_rxbytes   =  0; /* total data bytes sent */
u_long   my_ftps_dirs      =  0; /* total directory operations done */

/* ftp server internal routines: */
static int  ftp_getcmd(ftpsvr * ftp);
static void ftp_flushcmd(ftpsvr * ftp);

ftpsvr * newftp(void);
void  my_delftp(ftpsvr * ftp);
int   ftps_user(ftpsvr * ftp);
int   ftps_password(ftpsvr * ftp);
int   ftps_cmd(ftpsvr * ftp);
int   ftp_sendfile(ftpsvr * ftp);
int   ftp_getfile(ftpsvr * ftp);
void  ftp_xfercleanup(ftpsvr * ftp);

/* common FTP server reply tokens */
char *my_ftp_cmdok   = "200 Command OK\r\n";
char *my_ftp_ready   = "220 Service ready\r\n";
char *my_ftp_needpass= "331 User name ok, need password\r\n";
char *my_ftp_loggedin= "230 User logged in\r\n";
char *my_ftp_fileok  = "150 File status okay; about to open data connection\r\n";
char *my_ftp_closing = "226 Closing data connection, file transfer successful\r\n";
char *my_ftp_badcmd  = "500 Unsupported command\r\n";
char *my_ftp_noaccess= "550 Access denied\r\n";

ftpsvr * my_ftplist   = NULL;   /* master list of FTP connections */

int    my_notfatal    = 0;      /* unfatal error handling */

/* ftp server timeouts, left as globals for app overrides: */
int    my_ftps_iotmo  =  1200;  /* Idle timeout during IO activity */
int    my_ftps_lotmo  =  600;   /* Idle timeout during logins */

/* if x is an upper case letter, this evaluates to x,
 *  if x is a lower case letter, this evaluates to the upper case.
 */
#define  upper_case(x)  ((x)  &  ~0x20)

u_short  my_listcmds =  0; /* number of LIST or DIR commands */
extern   TK_OBJECT(to_ftpsrv);
int my_fs_dodir(ftpsvr * ftp, u_long ftpcmd);

/* FUNCTION: ftps_connection()
 * 
 * ftps_connection() - Called whenever we have accepted a connection 
 * on the FTP server listener socket. The socket passed will stay 
 * open until we close it. 
 *
 * PARAM1: WP_SOCKTYPE sock
 *
 * RETURNS: Returns ftpsvr pointer if OK, else NULL
 */

ftpsvr *my_ftps_connection(SOCKTYPE sock)
{
	ftpsvr * ftp;
	int   e;

	my_ftps_connects++;           /* count connections */
	dbgftp("195\n");
	/* check if we have exceeded the maximum number of connections */
	if ((max_ftps_conn > 0) && (my_ftps_connects > max_ftps_conn))
	{
		my_ftps_connects--;
		dbgftp("196\n");
		//t_shutdown(sock,2); //shut down both read and write
		t_shutdown(sock,0); //shut down both read and write
		t_socketclose(sock);
		dbgftp("197\n");
		return NULL;
	}
	dbgftp("199\n");
	/* create new FTP connection */
	if ((ftp = newftp()) == (ftpsvr *)NULL)
	{
		dbgftp("199a\n");
		my_ftps_connects--;
		dbgftp("199b\n");
		//t_shutdown(sock,2); //shut down both read and write
		t_shutdown(sock,0); //shut down both read and write
		t_socketclose(sock);
		return NULL;
	}
	dbgftp("200\n");
	/* set the default data port we will connect to for data transfers
	 * to be the same as the port that the client connected with just
	 * in case we connect to a client that doesn't send PORT commands.
	 * see section 3.2 ESTABLISHING DATA CONNECTIONS in RFC 959 for a
	 * description of this, keeping in mind that what we are doing
	 * here is setting the default "user-process data port".
	 *
	 * note that t_getpeername() can in theory fail, but its not clear
	 * what we could do at this point to recover if it did and it only
	 * makes a difference if we connect to clients that don't send
	 * PORT commands anyway, so just use whatever port that we get back
	 */
	ftp->dataport = my_SO_GET_FPORT(sock);

	ftp->sock = sock;    /* remember client socket */
	ftp->state = FTPS_CONNECTING;
	dbgftp("201\n");
	e = t_send(ftp->sock, my_ftp_ready, strlen(my_ftp_ready), 0);
	dbgftp("202\n");
	if (e == -1)   /* did connection die already? */
	{
		my_dtrap();
		dbgftp("204\n");
		my_delftp(ftp);
		dbgftp("205\n");
		return NULL;
	}

	return ftp;
}



/* FUNCTION: ftpputs()
 * 
 * ftpputs() - put a string to an ftp command socket. 
 *
 * PARAM1: ftpsvr * ftp
 * PARAM2: char * text
 *
 * RETURNS: Retuns 0 if OK -1 if error. ftpsvr is deleted on error. 
 */

int ftpputs(ftpsvr * ftp, char * text)
{
	int   bytes_to_send;
	int   bytes_sent;
	int   rc;
	dbgftp("%s\n",text);

	bytes_to_send = strlen(text);
	for (bytes_sent = 0; bytes_to_send > 0; )
	{
		rc = t_send(ftp->sock, text + bytes_sent, bytes_to_send, 0);
		if (rc < 0)
		{
			rc = t_errno(ftp->sock);
			my_dtrap();       /* show errors to programmer */
			ftp->state = FTPS_CLOSING;
			return -1;
		}
		bytes_to_send -= rc;
		bytes_sent += rc;
		if (bytes_to_send > 0)
		{

			tk_yield();

		}
	}
	/* bytes_to_send should end up 0 */
	if (bytes_to_send < 0)
	{
		my_dtrap();
	}
	return 0;
}

#define  FTP_HASCMD     1
#define  FTP_NOCMD      2
#define  FTP_ERROR      3



/* FUNCTION: ftp_getcmd()
 * 
 * ftp_getcmd() - Get a command from the ftp command stream. Trys to 
 * read more data from a ftp client sock until a command is buffered. 
 *
 * PARAM1: ftpsvr * ftp
 *
 * RETURNS: FTP_HASCMD if a command is ready at ftp->cmdbuf, else 
 * FTP_NOCMD if a command is not ready, or FTP_ERROR if there's a 
 * serious data problem. If FTP_HASCMD is returned and the caller 
 * processes the command, he should call ftp_flushcmd() so the 
 * command doen't get processed again. 
 */

static int
ftp_getcmd(ftpsvr * ftp)
{
	int   readval;
	int   e;
	char *   cp;

	/* if we filled up the input buffer on the last pass and there was
      no CRLF terminating a command in any of it */
	if (ftp->cmdbuflen >= (CMDBUFSIZE - 1))
	{
		/* the input is bogus so discard it */
		ftp->cmdbuflen = 0;
	}

	/* read as much data as will fit into the command buffer, leaving
	 * room for the NULL that we are going to insert following the
	 * first CRLF, below
	 */

	readval = t_recv(ftp->sock, (ftp->cmdbuf + ftp->cmdbuflen),
			(CMDBUFSIZE - ftp->cmdbuflen - 1), 0);

	if (readval == 0)
		ftp->state = FTPS_CLOSING;

	if (readval < 0)  /* error on socket? */
	{
		e = t_errno(ftp->sock);
		if (e != EWOULDBLOCK)
		{
			/* let programmer see errors */
			dprintf("\nftpsvr cmd socket error %d - Closing FTP connection\n", e);
			my_delftp(ftp);   /* thats the end of this connection... */
			return FTP_ERROR; /* error return */
		}
		else     /* no command ready */
			return FTP_NOCMD;
	}
	ftp->cmdbuflen += readval;    /* add read data to hp */

	if (ftp->cmdbuflen == 0)   /* nothing in buffer? */
		return FTP_NOCMD;

	ftp->lasttime = ftpticks;     /* this is activity; rest timeout */

	cp = strstr(ftp->cmdbuf, "\r\n");   /* look for trailing CRLF */
	if (cp)  /* look for trailing CRLF */
	{
		char *   src;
		char *   dst;

		/* point to first byte following the CRLF */
		cp += 2;
		/* if there's not already a null there */
		if (*cp)
		{
			/* move all the characters following the CRLF up one so we got
            room to insert a null to terminate the command after the CRLF */
			/* note we do this here because some of the later code paths
            treat the command like an ASCIIZ string */
			dst = ftp->cmdbuf + ftp->cmdbuflen;
			src = dst - 1;
			while (src >= cp)
				*dst-- = *src--;
			/* increment the number of characters in the command buffer to
            account for the NULL */
			ftp->cmdbuflen++;
			/* NULL terminate the command */
			*cp = 0;
		}

		/* now, flip the characters at the beginning of the buffer that
		 * could be an FTP command from lower to upper case since
		 * the protocol's supposed to be case insensitive *
		 *
		 * we look at at most the first 4 bytes since no commands
		 * are more than 4 bytes long
		 */

		for (dst = ftp->cmdbuf; dst < (ftp->cmdbuf + 4); ++dst)
		{
			/* upper case, leave as is */
			if ((*dst >= 'A') && (*dst <= 'Z'))
				continue;
			/* lower case gets flipped to upper */
			if ((*dst >= 'a') && (*dst <= 'z'))
			{
				*dst = (char) (*dst + (char) ('A' - 'a'));
				continue;
			}
			/* anthing else means we got to end of command so break */
			break;
		}
		return FTP_HASCMD;   /* Got command */
	}
	else
		return FTP_NOCMD;    /* NO command */
}



/* FUNCTION: ftp_flushcmd()
 * 
 * PARAM1: ftpsvr * ftp
 *
 * RETURNS: 
 */

static void
ftp_flushcmd(ftpsvr * ftp)
{
	char *   cp;
	int   old_cmd_len;
	int   rest_of_cmds_len;

	/* find command terminating CRLF */
	ff_again:
	cp = strstr(ftp->cmdbuf, "\r\n");
	if (!cp)
	{
		/* might be clobbered CR at end of path (see CWD code) */
		if ( (unsigned)strlen(ftp->cmdbuf) < ftp->cmdbuflen)
		{
			ftp->cmdbuf[strlen(ftp->cmdbuf)] = '\r';     /* put back CR */
			goto ff_again;
		}
		my_dtrap();    /* prog error */
		return;
	}

	/* cp now points to a CRLF followed by the NULL we inserted in
	 * ftp_getcmd(), so if theres data in the buffer following the
	 * NULL, then its the beginning of the next command
	 */
	/* point to where next comamnd will be if its there */
	cp += 3;
	/* compute the length of the old command */
	old_cmd_len = cp - ftp->cmdbuf - 1;

	/* compute the length of the rest of the commands in the buffer */
	/* that's the number of bytes that had been read into the buffer,
	 * less the length of the old command less 1 for the NULL that
	 * we inserted to null terminate the old command
	 */
	rest_of_cmds_len = ftp->cmdbuflen - old_cmd_len - 1;

	/* this will happen if we didn't insert a null after the command
	 * because there was one there already, which will be the case
	 * when the old command is the only data that's been read so far,
	 * in which case the length of the rest of the commands is 0
	 */

	if (rest_of_cmds_len < 0)
		rest_of_cmds_len = 0;

	/* if there are any other commands left in the buffer */
	if (rest_of_cmds_len)
	{
		/* move them to the front of the buffer */
		memmove(ftp->cmdbuf,cp,rest_of_cmds_len);
	}

	/* zero the data following rest of the commands for the length of
	 * the old command or else you risk finding command termination
	 * sequences when none have been received
	 */
	/* if there are no other commands, this zeroes the old command
      from the buffer */
	MEMSET(ftp->cmdbuf + rest_of_cmds_len,0,old_cmd_len + 1);

	ftp->cmdbuflen = rest_of_cmds_len;
}




/* FUNCTION: ftps_loop()
 * 
 * PARAM1: 
 *
 * RETURNS: 
 */

void my_ftps_loop()
{
	ftpsvr * ftp;
	ftpsvr * ftpnext;
	int   cmdready;
	int   e;    /* error holder */

	struct sockaddr   client;  /* for BSDish accept() call */
	int               clientsize;
	SOCKTYPE data_sock;        /* socket for passive accept */

	ftpnext = my_ftplist;   /* will be set to ftp at top of loop */
	dbgftp("500\n");
	/* loop throught connection list */
	while (ftpnext)
	{
		//MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_SHORT_PROCESS_DLY_MS);
		dbgftp("501\n");
		ftp = ftpnext;
		ftpnext = ftp->next;    /* remember next in case ftp is deleted */
		if (ftp->inuse)   /* if we are blocked in guts, quit */
			continue;
		dbgftp("502\n");
		ftp->inuse++;  /* set reentry flag */
		e = 0;         /* clear error holder */
		/* see if a command is ready */
		dbgftp("503\n");
		cmdready = ftp_getcmd(ftp);
		dbgftp("504\n");
		if (cmdready == FTP_ERROR)
			continue;

		switch (ftp->state)
		{
		dbgftp("ftp->state = %d\n",(int) ftp->state);
		case FTPS_CONNECTING: dbgftp("505\n");
		case FTPS_NEEDPASS:
			dbgftp("506\n");
			/* check for shorter session timeout in these states */
			if (ftp->lasttime + ((unsigned long)my_ftps_lotmo * FTPTPS) < ftpticks)
			{
				dbgftp("507\n");
				e = -1;  /* set flag to force deletion of ftps */
				break;
			}
			dbgftp("508\n");
			if (cmdready != FTP_HASCMD)
				break;
			dbgftp("509\n");
			if (ftp->state == FTPS_CONNECTING)
			{
				e = ftps_user(ftp);
				dbgftp("510\n");
			}
			else
			{
				e = ftps_password(ftp);
				dbgftp("511\n");
			}
			break;
		case FTPS_LOGGEDIN:
			dbgftp("512\n");
			/* connection timeouts like this are really obnoxious and should
			 * be disabled usless there is some compling reason your target
			 * should do otherwise (like dialup charges).
			 */
			dbgftp("513\n");
			if (cmdready == FTP_HASCMD)
			{
				dbgftp("514\n");
				e = ftps_cmd(ftp);
				MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS);
			}
			dbgftp("515\n");
			/* if we are in passive mode and the client hasn't connected yet */
			if (ftp->passive_state == FTPS_PASSIVE_MODE)
			{
				dbgftp("516\n");
				/* check to see if the client connected */

				if (LONG2SO(ftp->datasock)->so_domain == AF_INET)
				{
					dbgftp("518\n");
					clientsize = sizeof(struct sockaddr_in);
					data_sock = t_accept(ftp->datasock, &client, &clientsize);
					dbgftp("519\n");
				}
				dbgftp("520\n");
				/* if client didn't connect, break to continue */
				if (data_sock == SYS_SOCKETNULL)
				{
					dbgftp("521\n");
					break;
				}
				/* client connected, so close listening socket so we wont take
				 * any more connections to it.
				 */
				dbgftp("522\n");
				//t_shutdown(ftp->datasock,2); //shut down both read and write
				t_shutdown(ftp->datasock,0); //shut down both read and write
				t_socketclose(ftp->datasock);
				dbgftp("523\n");
				/* the data socket we care about is now the actual connection
				 * to the client.
				 */
				ftp->datasock = data_sock;

				/* change our passive state so that we know we are connected
               to the client on the data socket */
				dbgftp("525\n");
				ftp->passive_state |= FTPS_PASSIVE_CONNECTED;
				/* if we have already received our data transfer command */
				if (ftp->passive_cmd)
				{
					dbgftp("527\n");
					/* then do the command */
					IN_PROFILER(PF_FTP, PF_ENTRY);
					switch (ftp->passive_cmd)
					{
					dbgftp("528\n");
					case 0x4c495354:  dbgftp("529\n");   /* "LIST" */
					case 0x4e4c5354:  dbgftp("530\n");   /* "NLST" */
					if (my_fs_dodir(ftp, ftp->passive_cmd))
					{
						dbgftp("531\n");
						ftpputs(ftp, "451 exec error\r\n");
					}
					dbgftp("532\n");
					break;
					case 0x52455452:     /* "RETR" */
						dbgftp("533\n");

						ftp_sendfile(ftp);
						break;
					case 0x53544f52:     /* "STOR" */
						dbgftp("534\n");

						ftp_getfile(ftp);
						break;
						/* there is a serious logic error someplace */
					default :
						dprintf("invalid passive_cmd\n");
						my_dtrap();
					}
					IN_PROFILER(PF_FTP, PF_EXIT);
					dbgftp("535\n");

				}
				dbgftp("536\n");

			}
			dbgftp("537\n");

			break;
		case FTPS_RECEIVING: dbgftp("538\n");   /* task suspended while doing IO */
		case FTPS_SENDING: dbgftp("539\n");
		/* check for shorter session timeout in these states */
		if (ftp->lasttime + ((unsigned long)my_ftps_iotmo * FTPTPS) < ftpticks)
		{
			dbgftp("540\n");
			e = -1;  /* set flag to force deletion of ftps */
			break;
		}
		dbgftp("541\n");
		IN_PROFILER(PF_FTP, PF_ENTRY);
		dbgftp("100\n");
		if (ftp->state == FTPS_SENDING)
			e = ftp_sendfile(ftp);
		else     /* must be receiving */
			e = ftp_getfile(ftp);
		dbgftp("101\n");
		IN_PROFILER(PF_FTP, PF_EXIT);

		/* If not superloop and there is still more data to move,
		 * then make sure ftp server will wake up to finish the
		 * send/receive later. The the transfer finished, the ftps
		 * state will have returned to LOGGEDIN.
		 */
		dbgftp("102\n");
		if(ftp->state != FTPS_LOGGEDIN)
		{

			TK_WAKE(&to_ftpsrv);     /* make sure we come back later */

		}
		dbgftp("103\n");
		break;
		dbgftp("104\n");
		case FTPS_CLOSING:
			dbgftp("104a\n");
			break;
		default:    /* bad state? */
			my_dtrap();
			break;
		}
		/* if fatal error or connection closed */
		/* if (e == 452)
      {      
         ftp->state = FTPS_LOGGEDIN;
         ftp_flushcmd(ftp); 
         ftp->inuse--;
      } */
		dbgftp("105\n");
		if (e || (ftp->state == FTPS_CLOSING))
		{
			dbgftp("106\n");
			my_delftp(ftp);
		}
		else
		{
			dbgftp("107\n");
			ftp->inuse--;     /* set reentry flag */
		}
		dbgftp("107a\n");
	}
	dbgftp("107b\n");
}



/* FUNCTION: newftp()
 * 
 * newftp() - create a new ftpsvr structure. Put in master queue. 
 *
 * PARAM1: 
 *
 * RETURNS: 
 */

ftpsvr *
newftp()
{
	ftpsvr * ftp;

	ftp = (ftpsvr *)FTPSALLOC(sizeof(ftpsvr));
	if (!ftp)
		return NULL;
	ftp->next = my_ftplist;
	ftp->lasttime = ftpticks;
	my_ftplist = ftp;

	/* make sure we have a valid domain */
	ftp->domain = AF_INET;  /* default to IPv4 */
	return(ftp);
}



/* FUNCTION: my_delftp()
 * 
 * PARAM1: ftpsvr * ftp
 *
 * RETURNS: 
 */

void
my_delftp(ftpsvr *ftp)
{
	ftpsvr *list;
	ftpsvr *last;
	dbgftp("108\n");
	last = NULL;
	for (list = my_ftplist; list; list = list->next)
	{
		dbgftp("109\n");
		if (list == ftp)
		{
			dbgftp("110\n");
			/* found server to kill, unlink: */
			if (last)
				last->next = list->next;
			else
				my_ftplist = list->next;
			dbgftp("111\n");
			if (ftp->sock)
			{
				dbgftp("112\n");
				//t_shutdown(ftp->sock,2); //shut down both read and write
				t_shutdown(ftp->sock,0); //shut down both read and write
				t_socketclose(ftp->sock);
				dbgftp("113\n");
				ftp->sock = 0;
			}
			if (ftp->datasock)
			{
				dbgftp("114\n");
				//t_shutdown(ftp->datasock,2); //shut down both read and write
				t_shutdown(ftp->datasock,0); //shut down both read and write
				t_socketclose(ftp->datasock);
				dbgftp("115\n");
				ftp->datasock = 0;
			}

			dbgftp("116\n");
			FTPSFREE(ftp);
			dbgftp("117\n");
			my_ftps_connects--;     /* decrement connection count */
			break;
		}
		last = list;
	}
}



/* the ftps_ server command handler routines. These are called when a 
 * command is received in the ftp->cmdbuf. Which one is called 
 * depends in the session state. These all process a command, maybe 
 * change the state, (or kill the session) and flush the command. All 
 * return 0 if OK (which may mean pending work) or negative error 
 * code if a fatal error was detected. 
 */



/* FUNCTION: ftps_user()
 * 
 * ftps_user() - called when we get a command in the initial state 
 *
 * PARAM1: ftpsvr * ftp
 *
 * RETURNS: 
 */

int ftps_user(ftpsvr * ftp)
{
	char *   cp;
	int   e;

	/* make sure client's telling me about a user */
	if (MEMCMP(ftp->cmdbuf, "USER", 4) != 0)
	{
		ftpputs(ftp, my_ftp_badcmd);
		return -1;  /* signal main loop to kill session */
	}
	cp = strstr(ftp->cmdbuf, "\r\n");
	if (!cp)
	{
		my_dtrap();
		return -1;  /* signal main loop to kill session */
	}
	*cp = 0;    /* NULL terminate user name */

	/* search user list */
	e = fs_lookupuser(ftp, &ftp->cmdbuf[5]);
	*cp = '\r';    /* put back buffer char we clobbered */
	if (e)
	{
		ftp->state = FTPS_CONNECTING;
		ftpputs(ftp, "530 Invalid user\r\n");
		ftp_flushcmd(ftp);
		return 0;   /* user not valid */
	}

	ftp->cwd[0] = FTP_SLASH;
	ftp->cwd[1] = 0;
	ftp->type = FTPTYPE_ASCII; /* RFC says make text the defaul type */


	if (ftp->user.password.at(0) == '\0')  /* no password required? */
	{
		ftpputs(ftp, my_ftp_loggedin);
		ftp->state = FTPS_LOGGEDIN;
		my_ftps_sessions++;
	}
	else  /* require a password */
	{
		ftpputs(ftp, my_ftp_needpass);   /* message to client */
		ftp->state = FTPS_NEEDPASS;   /* set proper state */
	}
	ftp_flushcmd(ftp);
	return 0;
}



/* FUNCTION: ftps_password()
 * 
 * ftps_password() - called when we get a command in the 
 * FTPS_NEEDPASS state. 
 *
 * PARAM1: ftpsvr * ftp
 *
 * RETURNS: Returns 0 if OK (which may mean pending work) 
 * or negative error code if a fatal error was detected. 
 */

int ftps_password(ftpsvr * ftp)
{
	std::string   password;
	size_t  cp;

	if (MEMCMP(ftp->cmdbuf, "PASS", 4) != 0)
	{
		ftpputs(ftp, my_ftp_badcmd);
		return -1;  /* signal main loop to kill session */
	}
	password = std::string((ftp->cmdbuf+5));
	cp = password.find_first_of("\r\n");   /* find end of command */
	if (cp == std::string::npos) /* require whole command to be in buffer */
		return -1;  /* signal main loop to kill session */

	//password = password.substr(0,cp);
	TrimSpaces(password);

	/* password '*' means we accept any password, so don't even compare */
	if ((ftp->user.password == "") || ftp->user.password.at(0) != '*')
	{
		if (password != ftp->user.password)
		{
			ftp->state = FTPS_CONNECTING;
			ftpputs(ftp, "530 Invalid password\r\n");
			if (ftp->logtries++ > 2)
				return -1;  /* too many failed logins, kill session */
			else
			{
				ftp_flushcmd(ftp);
				return 0;   /* wait for another user/pass try */
			}
		}
	}
	ftpputs(ftp, my_ftp_loggedin);   /* login OK, set up session */
	ftp->state = FTPS_LOGGEDIN;
	my_ftps_sessions++;
	ftp_flushcmd(ftp);
	return 0;
}



/* FUNCTION: ftp_cmdpath()
 * 
 * ftp_getpath() - extract path from an FTP command in C string form. 
 * The returned pointer is to the ftp->cmdbuf area. 
 *
 * PARAM1: ftpsvr * ftp
 *
 * RETURNS: Returns NULL on any error after sending complain 
 * string to client. 
 */

char *my_ftp_cmdpath(ftpsvr * ftp)
{
	char *   cp;

	cp = strchr(&ftp->cmdbuf[4], '\r');
	if (!cp)
	{
		ftpputs(ftp, "501 garbled path\r\n");
		return NULL;
	}
	*cp = 0;    /* null terminate path in buffer */
	cp = &ftp->cmdbuf[4];
	while (*cp == ' ') cp++;   /* bump past spaces */
	if (strlen(cp) > FTPMAXPATH)
	{
		ftpputs(ftp, "553 path too long\r\n");
		safe_print(printf("553 path [%s] too long\r\n",cp));
		return NULL;
	}
	return cp;
}



/* FUNCTION: ftp_make_filename()
 * 
 * create a complete file name and path from the file specification 
 * in the command buffer and the cwd associated with the current ftp 
 * session. allow_empty_filespec specifies whether a file 
 * specification is required (as is the case with RETR and STOR) or 
 * whether it is optional (as is the case with NLST and LIST). 
 *
 * PARAM1: ftpsvr *ftp
 * PARAM2: int allow_empty_filespec
 *
 * RETURNS: TRUE if success, FALSE if some error occurred 
 */

int ftp_make_filename(ftpsvr *ftp,int allow_empty_filespec)
{
	char *cp;
	char *cp1;
	int relative_path;

	cp = my_ftp_cmdpath(ftp);
	if(!cp)   return FALSE;   /* ftp_cmdpath() already sent error */

	/* if there is no file spec in the command buffer and one is
      required, xmit error response and fail function */
	if(!(*cp) && !allow_empty_filespec)
	{
		ftpputs(ftp, "501 bad path\r\n");
		return FALSE;
	}

	/* if the file spec is too long, xmit error response and fail */
	if(strlen(cp) > FTPMAXPATH)
	{
		ftpputs(ftp, "552 Path/name too long\r\n");
		safe_print(printf("552 path [%s] too long\r\n",cp));
		return FALSE;
	}
	lslash(cp);

	/* assume the path specified is not a relative path */
	relative_path = FALSE;

	/* working pointer to file name */
	cp1 = ftp->filename;

	/* if this target system deals with DOS drive letters */
	/* target system is fortunate enough to not have to deal
      with DOS drive letters */

	/* if client path does not start at root */
	if (*cp != FTP_SLASH)
	{
		/* else its a relative path */
		relative_path = TRUE;
	}

	/* if the client specified path is not relative */
	if (!relative_path)
	{
		/* in this case, cp now points to past any drive info in
         the path provided by the client and cp1 now points to past
         any drive info in the constructed file name */
		/* if the path provided by the client isn't absolute, append
         a slash to the constructed file name. note this can happen
         if the client specified a drive other than the default */
		if (*cp != FTP_SLASH)
			*cp1++ = FTP_SLASH;
		/* append client path to our constructed file name */
		//strncpy(cp1,cp,FTPMAXPATH-2);
		snprintf(cp1,FTPMAXPATH-2,"%s",cp);
	}
	/* the client specified path was relative */
	else
	{
		/* copy current working directory to file name (following
         any drive letter stuff that might have been added above) */
		//strncpy(cp1, ftp->cwd,FTPMAXPATH-2);
		snprintf(cp1, FTPMAXPATH-2, "%s",ftp->cwd);

		cp1 = &ftp->filename[strlen(ftp->filename)-1]; /* point to end */

		/* if ftp->cwd is not terminated with a slash and the file spec
         is not empty, append a slash */
		if ((*cp1 != FTP_SLASH) && *cp)
		{
			++cp1;  /* increment ptr past last character to NULL */
			*cp1++ = FTP_SLASH;
			*cp1 = 0;
		}

		/* make sure the concatenation of the specified file name to
         the current working directory wont be too big for the
         file name field */
		if ((strlen(ftp->filename) + strlen(cp)) >= sizeof(ftp->filename))
		{
			ftpputs(ftp,"501 file name too long\r\n");
			safe_print(printf("501 file name [%s] too long\r\n",cp));
			return FALSE;
		}

		/* concatenate the file spec from the command line to the
         current working directory */
		strncat(ftp->filename,cp,FTPMAXPATH-2);
		//snprintf(ftp->filename,FTPMAXPATH,"%s%s",ftp->filename,cp);
	}

	return TRUE; /* function succeeded */
}


/* FUNCTION: ftp_leave_passive_state()
 * 
 * this function is called to make the session leave passive state
 *
 * PARAM1: ftpsvr *ftp
 *
 * RETURNS: 
 */

void my_ftp_leave_passive_state(ftpsvr * ftp)
{
	/* there's a little confusion about whether this field is 0 or
	 *  -1 when the socket is unactive, so check for both
	 */
	if ((ftp->datasock != SYS_SOCKETNULL) && (ftp->datasock != 0))
	{
		//t_shutdown(ftp->datasock,2); //shut down both read and write
		t_shutdown(ftp->datasock,0); //shut down both read and write
		t_socketclose(ftp->datasock);
	}
	ftp->datasock = 0;
	/* we aren't in passive mode anymore */
	ftp->passive_state = 0;
	/* no data transfer command received while in passive state */
	ftp->passive_cmd = 0;
	ftp->server_dataport = 0;
}



/* FUNCTION: ftps_do_pasv()
 *
 * handle IPv4 PASV command
 *
 * Called when the client requests a transfer in "passive" mode.
 *
 * PARAM1: ftpsvr *ftp
 *
 * RETURNS: 
 */

void ftps_do_pasv(ftpsvr * ftp)
{
	int      error;

	/* do_pasv() may re-enter if the client sends us a PASV while we
	 * are transfering a file. This is an error on the client's part.
	 * Its not clear that this can happen given the way the
	 * main state machine works, but check for it just in case
	 */
	dbgftp("PASV1");
	if (ftp->passive_state & FTPS_PASSIVE_CONNECTED)
	{
		dbgftp("PASV2");
		ftpputs(ftp,"425 Data transfer already in progress\r\n");
		return;
	}
	dbgftp("PASV3");
	/* This will happen if the client had sent us a PASV and then sent
	 * us another one without an intervening data transfer command.
	 */
	if (ftp->passive_state & FTPS_PASSIVE_MODE)
	{
		dbgftp("PASV4");
		my_ftp_leave_passive_state(ftp);
	}
	dbgftp("PASV5");
	/* call sockets routine to do passive open */
	error = my_ftps_v4pasv(ftp);
	dbgftp("PASV6");
	/* we are now in passive mode, but the client hasn't connected yet */
	ftp->passive_state = FTPS_PASSIVE_MODE;
	dbgftp("PASV7");
	/* we haven't received a data transfer command from the client yet */
	ftp->passive_cmd = 0;
	dbgftp("PASV8");
}

FRESULT my_f_stat (
		const TCHAR *path,	/* Pointer to the file path */
		FILINFO *fno		/* Pointer to file information to return */
)
{
	FRESULT result = f_stat(path,fno);
	int res;

	if (result != FR_OK) {
		safe_print(printf("[%s][FTP][my_f_stat] Error [%d] in fstat with filename [%s], trying again!\n",get_current_time_and_date_as_string_trimmed().c_str(),(int) result, path));
		OSTimeDly(LINNUX_TICKS_TO_DELAY_AFTER_FSTAT_ERR);
		result = f_stat(path,fno);
		if (result != FR_OK) {
			OSTimeDly(LINNUX_TICKS_TO_DELAY_AFTER_FSTAT_ERR);
			safe_print(printf("[%s][FTP][my_f_stat] Error [%d] in fstat with filename [%s], trying again!\n",get_current_time_and_date_as_string_trimmed().c_str(),(int) result, path));
			res = disk_initialize(0);
			safe_print(printf("[%s][FTP][my_f_stat] Result of disk_initialize is: [%d]\n",get_current_time_and_date_as_string_trimmed().c_str(),(int) res));
			OSTimeDly(LINNUX_TICKS_TO_DELAY_AFTER_FSTAT_ERR);
			result = f_stat(path,fno);
			safe_print(printf("[%s][FTP][my_f_stat] Result of Second fstat is [%d] for filename [%s], trying again!\n",get_current_time_and_date_as_string_trimmed().c_str(),(int) result, path));
		} else {
			safe_print(printf("[%s][FTP][my_f_stat] Success! Result of Second fstat is [%d] for filename [%s]\n",get_current_time_and_date_as_string_trimmed().c_str(),(int) result, path));
		}
	}
	return result;
}



int check_if_directory_path_exists(const char* current_path, const char *dirpath)
{

	if (!strcmp(dirpath,"/")) {
		return 1; //"/" is always a good directory, this is a special case
	}

	if (strlen(dirpath)==0) {
		return 0; //null string is an error
	}

	std::string actual_dirpath;
	actual_dirpath = dirpath;
	if (actual_dirpath.at(actual_dirpath.length()-1)=='/') {
		actual_dirpath.erase(actual_dirpath.length()-1); //remove slash at the end, to avoid problems with fastfs
	}

	FILINFO finfo;
	FRESULT res;
#if _USE_LFN
	char lfn[_MAX_LFN * 2 + 1];
	finfo.lfname = lfn;
	finfo.lfsize = sizeof(lfn);
#endif

	res = my_f_stat(actual_dirpath.c_str(),&finfo);
	if (res != FR_OK) {
		safe_print(printf("Error [%d] while trying to validate existence of [%s]\n",(int)res, actual_dirpath.c_str()));
		return 0;
	}

	if (finfo.fattrib && AM_DIR) {
		return 1;
	} else {
		return 0;
	}
}

int
my_fs_permit(ftpsvr * ftp, u_long ftpcmd)
{
	if (ftp->user.username ==FTP_ADMIN_USER_NAME) {
		return TRUE;
	}
	std::string s;
	s = "";
	switch (ftpcmd) {
	case 0x52455452:   /* "RETR" */  //always allow read
		return TRUE;
	case 0x53544f52:   /* "STOR" */
	case 0x44454c45:   /* "DELE" */
		s.append(FTP_USER_PATH_PREFIX).append("/").append(ftp->user.username);
		if (s.find_first_of(ftp->cwd) == 0) {
			return TRUE;
		} else {
			safe_print(printf("Access denied of user: [%s] to path [%s] when looking for prefix [%s]\n",ftp->user.username.c_str(),ftp->cwd,s.c_str()));
			return FALSE;
		}
	default: return TRUE; //in case we ask for something that we don't care about
	}
	return FALSE; //shouldn't get here, but if we do...
}


int
ftps_cmd(ftpsvr * ftp)
{
	dbgftp("1\n");
	int   i;    /* scratch for command processing */
	char *   cp;
	char *   cp1;
	u_long   lparm;   /* scratch, for parameter extraction */
	u_short  sparm;   /* "" */
	u_long   ftpcmd;  /* 4 char command as number for fast switching */
	int   relative_path;

	ftpcmd = 0L;
	/* copy 4 bytes of ftp cmd text into local long value, replacing
   unprintable chars with blanks */
	for (i = 0; i < 4; i++)
	{
		if (ftp->cmdbuf[i] >= ' ')
			ftpcmd = (ftpcmd << 8) | ftp->cmdbuf[i];
		else     /* space over unprintable characters */
			ftpcmd = (ftpcmd << 8) | ' ';
	}
	dbgftp("2\n");
	dbgftp("Command = %lX\n",ftpcmd);
	/* switch on command */
	switch (ftpcmd)
	{
	case 0x53595354:     /* "SYST" */
		/* see what Netscape does with this */
		ftpputs(ftp, "215 UNIX system type\r\n");
		break;
	case 0x54595045:     /* "TYPE" */
		if ((ftp->cmdbuf[5] == 'A') || (ftp->cmdbuf[5] == 'a'))
			ftp->type = FTPTYPE_ASCII;
		else  /* we default all other types to binary */
			ftp->type = FTPTYPE_IMAGE;
		ftpputs(ftp, my_ftp_cmdok);
		break;
	case 0x50574420:     /* "PWD " */
		snprintf(ftp->filebuf, FILEBUFSIZE/2, "257 \"%s\"\r\n", uslash(ftp->cwd));
		lslash(ftp->cwd);
		ftpputs(ftp, ftp->filebuf);
		break;
	case 0x58505744:     /* "XPWD" */
		snprintf(ftp->filebuf, FILEBUFSIZE/2, "257 \"%s%s\"\r\n", DRIVE_PTR(ftp), ftp->cwd);
		ftpputs(ftp, ftp->filebuf);
		break;
	case 0x55534552:     /* "USER" */
		return(ftps_user(ftp));
	case 0x504f5254:     /* PORT */
		cp = &ftp->cmdbuf[5];   /* point to IP address text */
		lparm = 0L;
		for (i = 3; i >= 0; i--)   /* extract 4 digit IP address */
		{
			lparm |= (((u_long)atoi(cp)) << (i*8));
			cp = strchr(cp, ',');   /* bump through number to comma */
			if (!cp)    /* must be comma delimited */
			{
				ftpputs(ftp,"501 invalid PORT command\r\n");
				break;
			}
			cp++;    /* point to next digit */
		}
		dbgftp("3\n");
		/* the C break key word really needs a parameter so constructs
		 * like this aren't necessary, anyway, if this is true, its
		 * because we broke out of the above for on an error and we
		 */
		if (!cp)
			break;
		sparm = (u_short)atoi(cp) << 8;
		while (*cp >= '0')cp++; /* bump through number */
		if (*cp != ',')   /* must be comma delimited */
		{
			ftpputs(ftp,"501 invalid PORT command\r\n");
			break;
		}
		cp++;    /* point to next digit */
		sparm |= atoi(cp);

		/* this will happen if the client sends us a PORT while we are
		 * transfering a file. this is an error on the client's part,
		 */
		/* actually, its not clear that this can happen given the way the
         main state machine works, but check for it just in case */
		if (ftp->passive_state & FTPS_PASSIVE_CONNECTED)
		{
			ftpputs(ftp,"425 Data transfer already in progress\r\n");
			break;
		}
		dbgftp("4\n");
		/* this will happen if the client had sent us a PASV and then
		 * sent us a PORT without an intervening data transfer command.
		 */
		if (ftp->passive_state & FTPS_PASSIVE_MODE)
		{
			my_ftp_leave_passive_state(ftp);
		}

		ftp->host = lparm;
		ftp->dataport = sparm;
		ftpputs(ftp, my_ftp_cmdok);
		break;
	case 0x51554954:     /* QUIT" */
		dbgftp("5\n");
		/* if we don't have a file transfer going, kill sess now */
		if ((ftp->state != FTPS_SENDING) && (ftp->state != FTPS_RECEIVING))
		{
			ftpputs(ftp, "221 Bye\r\n");     /* session terminating */
			ftp->state = FTPS_CLOSING;
			/*         my_delftp(ftp);  */
			return -1;  /* signal main loop to kill session */
		}
		else
			return 0;   /* return without flushing QUIT */
	case 0x43574420:  /* "CWD " */
	case 0x4d4b4420:  /* "MKD " */
	case 0x524d4420:  /* "RMD " */
	case 0x524E4652:  /* "RNFR" */
	case 0x524E544F:  /* "RNTO" */
		dbgftp("6\n");
		/* note the intent here is to end up with the client supplied
		 * drive string (as in "c:") in the drive field, and the client
		 * supplied current working directory, without any drive spec,
		 * in the cwd field. to this end we construct the fully
		 * qualified path, including the drive in the filename field
		 * which will
		 */
		cp = my_ftp_cmdpath(ftp);
		if (!cp) break;
		lslash(cp);    /* convert slashes to local */

		/* assume the path specified is not a relative path */
		relative_path = FALSE;

		/* point to beginning of file name */
		cp1 = ftp->filename;

		/* target system is fortunate enough to not have to deal
         with DOS drive letters */
		/* if client path does not start at root */
		if (*cp != FTP_SLASH)
		{
			/* else its a relative path */
			relative_path = TRUE;
		}

		/* if the client specified path is not relative */
		if (!relative_path)
		{
			/* in this case, cp now points to past any drive info in the
			 * path provided by the client and cp1 now points to past
			 *
			 * if the path provided by the client isn't absolute, append
			 * a slash to the constructed file name. note this can
			 * happen
			 */
			if (*cp != FTP_SLASH)
				*cp1++ = FTP_SLASH;

			//strncpy(cp1,cp,FTPMAXPATH-2);
			snprintf(cp1,FTPMAXPATH-2,"%s",cp);
		}
		/* the client specified path was relative */
		else
		{
			/* copy current working directory to file name (following
            any drive letter stuff that might have been added above) */
			//strncpy(cp1, ftp->cwd, FTPMAXPATH-2);     /* copy cwd for change */
			snprintf(cp1, FTPMAXPATH-2, "%s", ftp->cwd);     /* copy cwd for change */
			cp1 = ftp->filename + strlen(ftp->filename); /* start at end */
			while (*cp)
			{
				if (*cp == '.' && *(cp+1) == '.')   /* double dot? */
				{  /* back up 1 level */
					if (strlen(ftp->cwd) < 2)  /* make sure we have room */
					{
						ftpputs(ftp, "550 Bad path\r\n");
						ftp_flushcmd(ftp);
						return 0;   /* not a fatal error */
					}
					/* null out last directory level */
					while (*cp1 != FTP_SLASH && cp1 > ftp->filename)
						*cp1-- = 0;
					if(cp1 > ftp->filename)   /* if not at root... */
						*cp1 = 0;   /* null over trailing slash */
					cp += 2; /* bump past double dot */
				}
				else if(*cp == FTP_SLASH) /* embedded slash */
					cp++;    /* just skip past it */
				else  /* got a dir name, append to new path */
				{
					if(*(cp1-1) != FTP_SLASH) /* if not at top... */
						*cp1++ = FTP_SLASH;    /* add the slash to new path */
					while(*cp && *cp != FTP_SLASH)  /* copy directory name */
					{
						*cp1++ = *cp++;
						if(cp1 >= &ftp->filename[FTPMAXPATH+2]) /* check length */
						{
							ftpputs(ftp, "550 Path too long\r\n");
							ftp_flushcmd(ftp);
							return 0;   /* not a fatal error */
						}
					}
				}
			} /* end of 'while(*cp)' loop */

			if(cp1 == ftp->filename)   /* if at root... */
				cp1++;   /* bump past slash */
			*cp1 = 0;   /* null terminate new path */
		}


		if (ftpcmd == 0x43574420) /* CWD */
		{
			/* new drive and/or directory is now in ftp->filename */
			/* verify path exists */
			//if (!fs_dir(ftp))
			/*FRESULT chdir_result;
       if (( chdir_result =  f_chdir(ftp->filename)) != FR_OK)*/
			if (!check_if_directory_path_exists(ftp->cwd,ftp->filename))
			{
				safe_print(printf("FTP: Error: 550 Unable to find [%s] or it is not a directory\r\n",ftp->filename));
				snprintf(ftp->filebuf, FILEBUFSIZE/2, "550 Unable to find [%s] or it is not a directory\r\n",ftp->filename);
				ftpputs(ftp, ftp->filebuf);
				break;
			}

			dbgftp("7\n");
			/* store the file name in the cwd field */
			//strncpy(ftp->cwd, ftp->filename,FTPMAXPATH-2);
			snprintf(ftp->cwd, FTPMAXPATH-2, "%s", ftp->filename);

			snprintf(ftp->filebuf, FILEBUFSIZE/2,
					"200 directory changed to %s%s\r\n", DRIVE_PTR(ftp), ftp->cwd);
			ftpputs(ftp, ftp->filebuf);      /* send reply to client */
		} else if (ftpcmd == 0x4d4b4420) /* MKD command */
		{

			/* MKD command */
			FRESULT mkdir_result;
			if (( mkdir_result =  f_mkdir(ftp->filename)) != FR_OK)
			{
				safe_print(printf("FTP: Error: MKD: Error code is: [%d] for path [%s]\n",(int) mkdir_result,ftp->filename));
				snprintf(ftp->filebuf,FILEBUFSIZE/2, "550 Unable to make directory %s\r\n",ftp->filename);
				ftpputs(ftp, ftp->filebuf);
				break;
			}
			snprintf(ftp->filebuf, FILEBUFSIZE/2, "200 made directory %s%s\r\n", DRIVE_PTR(ftp), ftp->filename);
			ftpputs(ftp, ftp->filebuf);      /* send reply to client */
		}
		else if (ftpcmd == 0x524E4652) /* RNFR */ {
			snprintf(ftp->RNFR_Path,FTPMAXPATH-2, "%s", ftp->filename);
			snprintf(ftp->filebuf, FILEBUFSIZE/2, "200 Rename From File %s%s\r\n", DRIVE_PTR(ftp), ftp->filename);
			ftpputs(ftp, ftp->filebuf);      /* send reply to client */
		} else  if (ftpcmd == 0x524E544F) /* RNTO */ {
			if (ftp->RNFR_Path[0] == '\0') {
				safe_print(printf("FTP: Error: RNTO %s Not Preceded by RNFR command\n",ftp->filename));
				snprintf(ftp->filebuf,FILEBUFSIZE/2, "550 RNTO %s not preceded by RNFR command\r\n",ftp->filename);
				ftpputs(ftp, ftp->filebuf);
				break;
			}
			FRESULT rename_result;
			if (( rename_result =  f_rename(ftp->RNFR_Path,ftp->filename)) != FR_OK)
			{

				safe_print(printf("FTP: Error: RNTO: Error code is: [%d] for source path: [%s] for dest path: [%s]\n",(int) rename_result,ftp->RNFR_Path,ftp->filename));
				snprintf(ftp->filebuf,FILEBUFSIZE/2, "550 Unable to rename file %s to %s, Error is [%d]\r\n",ftp->RNFR_Path, ftp->filename, (int) rename_result);
				ftpputs(ftp, ftp->filebuf);
				ftp->RNFR_Path[0] = '\0';
				break;
			}
			snprintf(ftp->filebuf, FILEBUFSIZE/2, "200 renamed file  %s%s to %s%s\r\n", DRIVE_PTR(ftp), ftp->RNFR_Path, DRIVE_PTR(ftp), ftp->filename);
			ftp->RNFR_Path[0] = '\0';
			ftpputs(ftp, ftp->filebuf);      /* send reply to client */
		}
		else {
			/* RMD command */
			FRESULT rmdir_result;
			if (( rmdir_result =  f_unlink(ftp->filename)) != FR_OK)
			{
				safe_print(printf("FTP: Error: RMD: Error code is: [%d] for path: [%s]\n",(int) rmdir_result,ftp->filename));
				snprintf(ftp->filebuf,FILEBUFSIZE/2, "550 Unable to remove directory %s, Error is [%d]\r\n",ftp->filename, (int) rmdir_result);
				ftpputs(ftp, ftp->filebuf);
				break;
			}
			snprintf(ftp->filebuf, FILEBUFSIZE/2, "200 removed directory %s%s\r\n", DRIVE_PTR(ftp), ftp->filename);
			ftpputs(ftp, ftp->filebuf);      /* send reply to client */
		}
		break;
	case 0x4c495354:   /* "LIST" */
	case 0x4e4c5354:   /* "NLST" */
		dbgftp("L1");
		my_listcmds++;
		/* attempt to create a complete path from the current working
         directory and the file spec in the command buffer. */
		if (!ftp_make_filename(ftp,TRUE))
		{
			dbgftp("L2");
			break;
		}
		dbgftp("L3");
		/* if we are in passive mode but the client hasn't connected to
         data socket yet, just store the command so it will get executed
         when the client connects */
		if (ftp->passive_state == FTPS_PASSIVE_MODE)

		{
			dbgftp("L4");
			ftp->passive_cmd = ftpcmd;
			break;
		}

		dbgftp("L5");

		/* generate the listing, if the function fails,
         send an error message back to the client */
		if (my_fs_dodir(ftp, ftpcmd))
		{
			dbgftp("L6");
			ftpputs(ftp, "451 exec error\r\n");
			dbgftp("L7");
		}
		dbgftp("L8");
		break;

	case 0x50415356:   /* "PASV" */
		ftps_do_pasv(ftp);
		break;


		/* some commands we know about and just don't do: */
	case 0x4d414342:   /* "MACB" - ??? Netscape 3.0 for Win95 sends this */
	case 0x53495a45:   /* "SIZE" - Netscape again. */
	case 0x4f505453:   /* "OPTS" - IE 5.50 */
		ftpputs(ftp, my_ftp_badcmd);
		break;
	case 0x52455452:   /* "RETR" */
	case 0x53544f52:   /* "STOR" */
		/* attempt to create a complete path from the current working
         directory and the file spec in the command buffer. */
		if (!ftp_make_filename(ftp,FALSE))
			break;

		/* ftp->filename now has drive:path/name of file to try for */

		/* check for user permission */
		if(my_fs_permit(ftp,ftpcmd) == FALSE)
		{
			ftpputs(ftp, my_ftp_noaccess);
			ftp_xfercleanup(ftp);
			break;
		}

		/* verify that the name of the file we are trying to put or
         get does not exist as a directory */
		DIR tmpdir;
		//if(fs_dir(ftp))
		if (f_opendir(&tmpdir,ftp->filename) == FR_OK) //if it is FR_OK, then this is a directory, this is bad
		{
			ftpputs(ftp, "501 bad path\r\n");
			ftp_xfercleanup(ftp);
			break;
		}

		/* if we are in passive mode but the client hasn't connected to
         data socket yet, just store the command so it will get executed
         when the client connects */
		if (ftp->passive_state == FTPS_PASSIVE_MODE)
		{
			ftp->passive_cmd = ftpcmd;
			break;
		}

		IN_PROFILER(PF_FTP, PF_ENTRY);
		if(ftpcmd == 0x52455452)   /* RETR */
			ftp_sendfile(ftp);
		else   /* must be STOR */
			ftp_getfile(ftp);
		IN_PROFILER(PF_FTP, PF_EXIT);
		dbgftp("8\n");
		break;
	case 0x44454c45:   /* "DELE" */
		/* attempt to create a complete path from the current working
         directory and the file spec in the command buffer. */
		if (!ftp_make_filename(ftp,FALSE))
		{
			snprintf(ftp->filebuf, FILEBUFSIZE/2, "550 Unable to parse filename  %s\r\n", \
					ftp->filename);

			ftpputs(ftp, ftp->filebuf);
			break;
		}
		dbgftp("9\n");
		lslash(ftp->filename);

		/* ftp->filename now has drive:path/name of file to try for */
		FRESULT fopen_result;
		/* check if the file that the client wants to delete exists */
		if (ftp->type == FTPTYPE_ASCII)
		{
			fopen_result = f_open(&ftp->filep, ftp->filename, FA_OPEN_EXISTING | FA_READ);
			ftp->file_is_open=1;
			//printf("FTP: File open result: %d  Filename: %s\n", fopen_result, ftp->filename);
			//ftp->filep = vfopen(ftp->filename, "r");  /* ANSI translated mode */
		} else
		{
			fopen_result = f_open(&ftp->filep, ftp->filename, FA_OPEN_EXISTING | FA_READ);
			ftp->file_is_open=1;
			//printf("FTP: File open result: %d  Filename: %s\n", fopen_result, ftp->filename);

			//        ftp->filep = vfopen(ftp->filename, "rb"); /* ANSI binary mode */
		}
		if (fopen_result != FR_OK)
		{
			/* if we appended VFS path to our constructed file name dont say so */
			if (*(ftp->filename) == FTP_SLASH)
				cp = ftp->filename + 1;
			else
				cp = ftp->filename;

			snprintf(ftp->filebuf, FILEBUFSIZE/2, "550 No such file %s\r\n", cp);
			ftpputs(ftp, ftp->filebuf);
			ftp->file_is_open=0;
			break;
		}
		else
		{
			f_close(&ftp->filep);
			ftp->file_is_open=0;
		}
		dbgftp("10\n");
		/* check for user permission */
		if(my_fs_permit(ftp,ftpcmd) == FALSE)
		{
			ftpputs(ftp, my_ftp_noaccess);
			break;
		}

		if (f_unlink(ftp->filename) != FR_OK)
		{
			/* if we appended VFS path to our constructed file name dont say so */
			if (*(ftp->filename) == FTP_SLASH)
				cp = ftp->filename + 1;
			else
				cp = ftp->filename;

			snprintf(ftp->filebuf,FILEBUFSIZE/2, "550 Unable to delete file %s\r\n", cp);
			ftpputs(ftp, ftp->filebuf);
			break;
		}
		else
		{
			dbgftp("11\n");
			ftpputs(ftp, "250 DELE command successful\r\n");
			break;
		}
	case 0x4e4f4f50:   /* "NOOP" */
		ftpputs(ftp, my_ftp_cmdok);
		break;
	default:
		dbgftp("12\n");
		snprintf(ftp->filebuf, FILEBUFSIZE/2, "500 Unknown cmd %s", ftp->cmdbuf);
		ftpputs(ftp, ftp->filebuf);
	}
	ftp_flushcmd(ftp);
	return 0;
}


/* FUNCTION: ftp_xfercleanup()
 * 
 * Called after a file transfer to clean up session structure and 
 * handle replys.
 *
 * PARAM1: ftpsvr * ftp
 *
 * RETURNS: void
 */

void
ftp_xfercleanup(ftpsvr * ftp)
{
	/* close any open file */
	dbgftp("13\n");
	if (ftp->file_is_open)
	{
		f_close(&ftp->filep);
		ftp->file_is_open = 0;
		dbgftp("14\n");
	}
	/* close any open socket */
	if (ftp->datasock != SYS_SOCKETNULL)
	{
		dbgftp("15\n");
		//t_shutdown(ftp->datasock,2); //shut down both read and write
		t_shutdown(ftp->datasock,0); //shut down both read and write
		t_socketclose(ftp->datasock);
		ftp->datasock = SYS_SOCKETNULL;
		dbgftp("16\n");
	}
	ftp->state = FTPS_LOGGEDIN;
	dbgftp("15b\n");
	/* we aren't in passive mode anymore */
	my_ftp_leave_passive_state(ftp);
	dbgftp("16b\n");
}



/* FUNCTION: ftp_sendfile()
 *
 * Send a file. Filename, Port, type, and IP address are all 
 * set in ftp structure. Returns 0 if OK, else ftp error. 
 *
 * 
 * PARAM1: ftpsvr * ftp
 *
 * RETURNS:  Returns 0 if OK, else ftp error. 
 */

int ftp_sendfile(ftpsvr * ftp)
{
	int   e;
	int   reterr = 0;
	u_long   put_timer;  /* timer for max time to loop in this routine */
	int   bytes = 0;
	dbgftp("17\n");
	/* See if this is start of send */
	if (ftp->state != FTPS_SENDING)
	{
		dbgftp("18\n");
		FRESULT fopen_result;
		lslash(ftp->filename);
		if (ftp->type == FTPTYPE_ASCII)
		{
			fopen_result = f_open(&ftp->filep, ftp->filename, FA_OPEN_EXISTING | FA_READ);
			ftp->file_is_open=1;
			//printf("FTP: File open result: %d  Filename: %s\n", fopen_result, ftp->filename);
			//ftp->filep = vfopen(ftp->filename, "r");  /* ANSI translated mode */
		} else
		{
			fopen_result = f_open(&ftp->filep, ftp->filename, FA_OPEN_EXISTING | FA_READ);
			ftp->file_is_open=1;
			//printf("FTP: File open result: %d  Filename: %s\n", fopen_result, ftp->filename);

			//        ftp->filep = vfopen(ftp->filename, "rb"); /* ANSI binary mode */
		}
		dbgftp("19\n");
		if (fopen_result != FR_OK)
		{
			dbgftp("20\n");
			ftp->file_is_open=0;
			ftpputs(ftp, "451 aborted, can't open file\r\n");

			/* if we are already connected to the client because we were
			 * in passive mode, close the connection to client and exit
			 */
			if (ftp->passive_state & FTPS_PASSIVE_MODE)
				my_ftp_leave_passive_state(ftp);
			return 451;
		}
		dbgftp("21\n");
		ftpputs(ftp, "150 Here it comes...\r\n");
		/* if we are not already connected from a previous PASV */
		dbgftp("22\n");
		if (!(ftp->passive_state & FTPS_PASSIVE_CONNECTED))
		{
			dbgftp("23\n");
			/* connect to client */
			ftp->datasock = FTP_TCPOPEN(ftp);
			dbgftp("24\n");
			if (ftp->datasock == SYS_SOCKETNULL)
			{
				dbgftp("25\n");
				ftpputs(ftp, "425 Can't open data connection\r\n");
				dbgftp("26\n");
				reterr = 425;
				goto ftsnd_exit;
			}
		}

		dbgftp("31\n");
		ftp->state = FTPS_SENDING;
		ftp->filebuflen = 0;
	}

	/*
	 * loop below while sending, quit when we reach MAX number of
	 * ftpticks we're allowed. The ftps_loop() routine will call us
	 * again later
	 */
	put_timer = (ftpticks + FTPTPS);    /* set timeout tick */

	for (;;)
	{
		dbgftp("32\n");
		if (ftp->filebuflen == 0)  /* need to read more file data */
		{
			dbgftp("33\n");
			/* if its an ASCII type transfer */
			if (ftp->type == FTPTYPE_ASCII)
			{
				/* then we need to insert a CR before any LF that is not
				 * already preceeded by an LF.
				 * Since the last character we read before filling up the
				 * file transfer buffer could be a lonely LF and in that
				 * case we'd have no room to insert the CR before it and
				 * it would be a righteous pain to keep track of this one
				 * boundary condition in the state machine, we will
				 * terminate the loop when there is still 1 byte left
				 */
				while (ftp->filebuflen < FILEBUFSIZE - 1)
				{
					dbgftp("34\n");
					char   next_char;
					char   prev_char   =  0;
					UINT num_bytes_read;
					FRESULT fread_result=f_read(&ftp->filep, (void *) &next_char, 1, &num_bytes_read);
					/* read next character from file */
					//next_char = f_getc(ftp->filep);
					/* break on end of file */
					dbgftp("34a\n");
					//dbgftp("fread_result = %d next_char_code = %d num_bytes_read=%d\n",(int) fread_result, (int) next_char, (int) num_bytes_read)
					if ((fread_result != FR_OK) || (num_bytes_read == 0))
						break;
					/* if we read an LF */
					dbgftp("34b\n");
					if (next_char == '\n')
					{
						/* and the previous char wasn't a CR */
						if (prev_char != '\r')
						{
							/* insert a CR ahead of the LF */
							ftp->filebuf[ftp->filebuflen] = '\r';
							ftp->filebuflen++;
						}
					}
					dbgftp("34c\n");
					ftp->filebuf[ftp->filebuflen] = (char) next_char;
					ftp->filebuflen++;
					/* if we just read a LF, break. why? you ask. well
					 * what happens if the last byte we read before
					 * filling up the transfer buffer is a CR. when we
					 * come back in here again and read the LF, that LF
					 * looks like a lonely LF, so we'd end up inserting
					 * another CR, which wouldn't be right. so to protect
					 * against that and allow us to avoid storing the last
					 * character read in the ftpsrv structure in order to
					 * support this archaic feature, we just terminate the
					 * read when we get to the end of a line on the
					 * assumption that theres not going to be too many
					 * people moving text
					 */
					dbgftp("34d\n");
					if (next_char == '\n')
						break;
					dbgftp("34e\n");
					prev_char = next_char;
				}

				MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_SHORT_PROCESS_DLY_MS);

				dbgftp("35\n");
			}
			else  /* its a binary transfer so just read the data */
			{
				dbgftp("36\n");
				UINT num_bytes_read;
				FRESULT fread_result=f_read(&ftp->filep, (void *) ftp->filebuf, FILEBUFSIZE, &num_bytes_read);

				MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_SHORT_PROCESS_DLY_MS);

				//e = vfread(ftp->filebuf, 1, FILEBUFSIZE, ftp->filep);
				dbgftp("37\n");
				if (fread_result  != FR_OK)
				{
					safe_print(printf("FTP:451 aborted, file read error: Error code is: [%d]\n",(int) fread_result));
					ftpputs(ftp, "451 aborted, file read error\r\n");
					reterr = 451;
					break;
				}
				ftp->filebuflen = (unsigned)num_bytes_read;
			}
		}
		dbgftp("38\n");
		bytes = (int)ftp->filebuflen;
		if (bytes)
		{
			dbgftp("39\n");
			e = t_send(ftp->datasock, ftp->filebuf, bytes, 0);
			if (e < 0)
			{
				/* See what kind of error it is. If we're out of sockbuf
				 * space or buffers then
				 * return 0 to try again later. If its anything else then
				 * it's serious and we should abort with an error
				 */
				dbgftp("40\n");
				e = t_errno(ftp->datasock);
				if((e == EWOULDBLOCK) || (e == ENOBUFS))
				{
					return 0;   /* out of socket space, try layer */
				}
				ftpputs(ftp, "426 aborted, data send error\r\n");
				reterr = 426;
				break;
			}
			else  /* no send error */
			{
#ifdef NPDEBUG /* sanity test socket return values */
				dbgftp("41\n");
				if (e > FILEBUFSIZE)
				{
					dbgftp("42\n");
					my_dtrap(); /* serious logic problem here */
					return 0;
				}
#endif   /* NPDEBUG */
				ftp->filebuflen -= e;
#ifdef NPDEBUG
				if ((int)ftp->filebuflen < 0)
				{
					dbgftp("43\n");
					my_dtrap();
					return 0;
				}
#endif
				if (e != bytes)   /* partial send on NBIO socket */
				{
					dbgftp("44\n");
					if (e != 0) /* sent some data, but not all - move buffer */
					{
						dbgftp("45\n");
						MEMMOVE(ftp->filebuf, ftp->filebuf+e, ftp->filebuflen);
						dbgftp("46\n");
					}
					return 0;      /* try again later */
				}
			}

			ftp->lasttime = ftpticks;     /* reset timeout */

			/*
			 * force return to let other FTP sessions run if we have had CPU
			 * continuously for a longish while
			 */
			if (ftpticks > put_timer)
			{
				dbgftp("47\n");
				//printf("FTP: Returning control of CPU to other processes\n");
				return 0;
			}
		}
		else  /* end of file & all bytes sent */
			break;   /* fall to send termination logic */
	}

	ftsnd_exit:    /* get here if EOF or fatal error */

#ifdef NPDEBUG
	dbgftp("28\n");
	if (reterr == 0 && ftp->filebuflen != 0)  /* buffer should be empty */
	{  dbgftp("29\n"); my_dtrap();   }
#endif

	/* first reply to user if xfer was OK */
	if (!reterr)
		ftpputs(ftp, "226 Transfer OK, Closing connection\r\n");

	ftp_xfercleanup(ftp);
	return reterr;
}


/* FUNCTION: ftp_getfile()
 * 
 * Get a file from client. We open a connection to the client
 * and he will send it to us. Filename, Port, type, and IP 
 * address are all set in ftp structure. 
 *
 * PARAM1: ftpsvr * ftp
 *
 * RETURNS: Returns 0 if OK, else ftp error. 
 */

int
ftp_getfile(ftpsvr * ftp)
{
	int   bytes;
	int   e;
	int   reterr   =  0;
	u_long   get_timer;  /* ctick to force a return */

	/* See if this is start of receive operation */
	dbgftp("48\n");
	if (ftp->state != FTPS_RECEIVING)
	{
		lslash(ftp->filename);
		dbgftp("49\n");


		FRESULT fopen_result;
		if (!ftp->file_is_open) {
			//Only open the file if it is not open already
			if (ftp->type == FTPTYPE_ASCII)
			{
				dbgftp("50\n");
				fopen_result = f_open(&ftp->filep, ftp->filename, FA_CREATE_ALWAYS | FA_WRITE);
				ftp->file_is_open=1;
				//printf("FTP: File open for write result: %d  Filename: %s\n", fopen_result, ftp->filename);
				//  ftp->filep = vfopen(ftp->filename, "w");
			} else
			{
				dbgftp("51\n");
				fopen_result = f_open(&ftp->filep, ftp->filename, FA_CREATE_ALWAYS | FA_WRITE);
				ftp->file_is_open=1;
				//printf("FTP: File open for write result: %d  Filename: %s\n", fopen_result, ftp->filename);

				//        ftp->filep = vfopen(ftp->filename, "wb");
			}
		} else
		{
			fopen_result = FR_OK; //if we are already open, we are OK
		}

		dbgftp("52\n");
		if (fopen_result != FR_OK)
		{
			dbgftp("53\n");
			ftp->file_is_open=0;
			ftpputs(ftp, "451 aborted, can't open file\r\n");
			dbgftp("54\n");
			/* if we are already connected to the client because we were
			 * in passive mode, close the connection to client and exit
			 */
			if (ftp->passive_state & FTPS_PASSIVE_MODE)
				my_ftp_leave_passive_state(ftp);
			dbgftp("55\n");
			return 550;
		}
		dbgftp("56\n");
		/* if we are not already connected from a previous PASV */
		if (!(ftp->passive_state & FTPS_PASSIVE_CONNECTED))
		{
			dbgftp("57\n");
			ftp->datasock = FTP_TCPOPEN(ftp);
			dbgftp("58\n");
			if (ftp->datasock == SYS_SOCKETNULL)
			{
				dbgftp("59\n");
				ftpputs(ftp, "425 Can't open data connection\r\n");
				dbgftp("60\n");
				reterr = 425;
				goto ftget_exit;
			}
		}
		dbgftp("61\n");
		ftpputs(ftp, "150 Connecting for STOR\r\n");
		dbgftp("62\n");
		ftp->state = FTPS_RECEIVING;
	}

	get_timer = ftpticks + FTPTPS;   /* set tick to timeout this loop */

	dbgftp("63\n");
	static int total_bytes = 0;
	static int prev_total_bytes = 0;
	for (;;)
	{
		dbgftp("64\n");
		bytes = t_recv(ftp->datasock, ftp->filebuf, 1024, 0);
		dbgftp("65\n");
		if (bytes > 0)
		{
			total_bytes = total_bytes + bytes;

			UINT bytes_written;
			FRESULT fwrite_result;
			dbgftp("66\n");
			//e = vfwrite(ftp->filebuf, 1, bytes, ftp->filep);
			fwrite_result = f_write(&ftp->filep, ftp->filebuf, bytes, &bytes_written);
			if ((total_bytes-prev_total_bytes) > 100000) {
				safe_print(printf("[%s]FTP: wrote total of: %d bytes\n",get_current_time_and_date_as_string_trimmed().c_str(),total_bytes));
				prev_total_bytes = total_bytes;
			}

			MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_SHORT_PROCESS_DLY_MS);

			dbgftp("67\n");
			e = (unsigned) bytes_written;
			if ((fwrite_result != FR_OK) || (e == 0)) /* memory allocation failed, not enough space to write a file on the server */
			{
				dbgftp("68\n");
				ftpputs(ftp, "452 Insufficient storage space, file write error\r\n");
				dbgftp("69\n");
				reterr = 0; /* not a fatal error to abort */
				my_notfatal = 1;
				break;
			}
			dbgftp("70\n");
			if (e != bytes)
			{
				dbgftp("71\n");
				my_dtrap();
				dbgftp("72\n");
				ftpputs(ftp, "450 File unavailable, file write error\r\n");
				dbgftp("73\n");
				reterr = 0; /* not a fatal error to abort */
				my_notfatal = 1;
				break;
			}
			dbgftp("74\n");
			ftp->lasttime = ftpticks;     /* reset timeout */
		}
		dbgftp("75\n");
		if (bytes < 0) /* error, no data (EWOULDBLOCK) or finished */
		{
			dbgftp("76\n");
			e = t_errno(ftp->datasock);
			dbgftp("77\n");
			if (e == EWOULDBLOCK)
				return 0;      /* no work right now, let other things run */
			else  /* probably socket cloesed due to end of file */
			{
				dbgftp("78\n");
				bytes = 0;
				break;   /* break our of read loop to exit code */
			}
		}
		else if(bytes == 0)     /* another form of broken? */
		{
			dbgftp("79\n");
			/*         bytes = -1; */
			ftp->state = FTPS_CLOSING;
			break;
		}
		/*
		 * force return to let other FTP sessions run if we have had CPU
		 * continuously for a longish while.
		 */
		if (ftpticks > get_timer)
			return 0;
	}     /* end of forever loop */
	dbgftp("80\n");
	if (bytes < 0)
	{
		dbgftp("81\n");
		ftpputs(ftp, "426 aborted, data recv error\r\n");
		reterr = 426;
	}
	dbgftp("82\n");
	ftget_exit:
	dbgftp("83\n");
	/* first reply to user if xfer was OK */
	if (!reterr && !my_notfatal)
		ftpputs(ftp, "226 Transfer OK, Closing connection\r\n");
	dbgftp("84\n");
	ftp_xfercleanup(ftp);
	dbgftp("85\n");
	return reterr;
}

std::string format_fat_time( WORD ThisTime )
{
	char msg[100];
	std::string retstr;
	int Hour, Minute, Second;

	Hour = ThisTime >> 11;        // bits 15 through 11 hold Hour...
	Minute = ThisTime & 0x07E0;   // bits 10 through 5 hold Minute... 0000 0111 1110 0000
	Minute = Minute >> 5;
	Second = ThisTime & 0x001F;   //bits 4 through 0 hold Second...   0000 0000 0001 1111

	snprintf( msg, 20, "%02d:%02d", Hour, Minute);

	retstr = msg;
	return(retstr);
}

std::vector<std::string> month_names(12);

std::string format_fat_date( WORD ThisDate, WORD ThisTime, char* filename)
{
	static int first_time = 1;

	if (first_time) {
		first_time = 0;
		month_names.at( 0) = "Jan";
		month_names.at( 1) = "Feb";
		month_names.at( 2) = "Mar";
		month_names.at( 3) = "Apr";
		month_names.at( 4) = "May";
		month_names.at( 5) = "Jun";
		month_names.at( 6) = "Jul";
		month_names.at( 7) = "Aug";
		month_names.at( 8) = "Sep";
		month_names.at( 9) = "Oct";
		month_names.at(10) = "Nov";
		month_names.at(11) = "Dec";
	}

	std::string fattime_str;
	std::ostringstream outstr;

	char msg[100];
	set_rtc_clk();
	int Year, Month, Day;

	Year = ThisDate >> 9;         // bits 15 through 9 hold year...
	Month = ThisDate & 0x01E0;    // bits 8 through 5 hold month... 0000 0001 1110 0000
	Month = Month >> 5;
	Day = ThisDate & 0x001F;      //bits 4 through 0 hold day...    0000 0000 0001 1111
	fattime_str = format_fat_time(ThisTime);
	if (fattime_str=="")
	{
		safe_print(printf("[%s]FTP: Error: could not get fat time for file!\n",get_current_time_and_date_as_string_trimmed().c_str()));
		return fattime_str;
	}

	if ((Month <=0) || (Month > 12)) {
#ifdef LINNUX_FTP_FAT_CORRUPTION_WARNINGS
		printf("[FTP] Warning: Possibly corrupt file entry [%s] - Month (%d) is out of range - Setting month to January\n",filename,(int) (Month));
#endif
		Month = 1;
	}

	if ((Day <=0) || (Day > 31)) {
#ifdef LINNUX_FTP_FAT_CORRUPTION_WARNINGS
		printf("[FTP] Warning: Possibly corrupt file entry [%s] - Day (%d) is out of range - Setting Day to 1\n",filename,(int) (Day));
#endif
		Day = 1;
	}

	if (Year <0) {
#ifdef LINNUX_FTP_FAT_CORRUPTION_WARNINGS
		printf("[FTP] Warning: Possibly corrupt file entry [%s] - Year (%d) is out of range - Setting Year to 1980\n",filename,(int) (Year));
#endif
		Year = 0;
	}

	if (((Year-20+100) - rtcYear) > 1)
	{
		//old file
		snprintf( msg, 20, "%s %2d %4d", month_names.at(Month-1).c_str(), Day, Year+1980);
	} else
	{
		//new file
		snprintf( msg, 20, "%s %2d %s", month_names.at(Month-1).c_str(), Day, fattime_str.c_str());
	}
	fattime_str = msg;
	return(fattime_str);
}

int
my_fs_dodir(ftpsvr * ftp, u_long ftpcmd)
{
	char *   cp;
	int   bytes_to_send;
	int   bytes_sent;
	int   rc;
	int   blocked;
	int   was_an_error;
	std::string fattime_str;
	DIR dirs;
	char *fn;   /* This function is assuming non-Unicode cfg. */
	FILINFO finfo;
#if _USE_LFN
	char lfn[_MAX_LFN * 2 + 1];
	finfo.lfname = lfn;
	finfo.lfsize = sizeof(lfn);
#endif
	was_an_error = 0;

	std::string actual_dirpath = TrimSpacesFromString(std::string(ftp->cwd));

	if (actual_dirpath == "/") {
		//do nothing, "/" is always a good directory, this is a special case
	} else {
		if (actual_dirpath.length()==0) {
			safe_print(printf("[%s]FTP:Error: Got null directory in my_fs_dodir\n",get_current_time_and_date_as_string_trimmed().c_str())); //null string is an error
		} else {
			while ((actual_dirpath.length() != 0) && (actual_dirpath != "/") && (actual_dirpath.at(actual_dirpath.length()-1)=='/')) {
				actual_dirpath.erase(actual_dirpath.length()-1); //remove slash at the end, to avoid problems with fastfs
			}
		}
	}


	dbgftp("300\n");
	ftpputs(ftp, "150 Here it comes...\r\n");
	safe_print(printf("[FTP]: Listing directory: [%s]\n",actual_dirpath.c_str()));
	dbgftp("301\n");
	/* if we are already connected to the client because we are in
      passive mode, don't create connection to client */
	if (!(ftp->passive_state & FTPS_PASSIVE_CONNECTED))
	{
		dbgftp("302\n");
		/* create a data connection back to the client */
		ftp->datasock = FTP_TCPOPEN(ftp);
		dbgftp("303\n");
		if (ftp->datasock == SYS_SOCKETNULL)
		{
			dbgftp("304\n");
			ftpputs(ftp, "425 Can't open data connection\r\n");
			dbgftp("305\n");
			return 0;   /* not actually OK, but we handled error */
		}
	}
	dbgftp("306\n");
	FRESULT file_result;
	if( (file_result=f_opendir(&dirs, actual_dirpath.c_str())) != FR_OK )
	{
		dbgftp("307\n");
		safe_print(printf("\n[%s][FTP]my_fs_dodir: Error: could not open path [%s], error is [%d]", get_current_time_and_date_as_string_trimmed().c_str(),ftp->cwd, (int) file_result));
		dbgftp("308\n");
		ftpputs(ftp, "450 Invalid Path\r\n");
		return 0;
	}

	/* lock the VFS */
	//vfs_lock();
	dbgftp("309\n");
	/* for each file in the file list */
	while ((f_readdir(&dirs, &finfo) == FR_OK) && finfo.fname[0])
	{
		MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_SHORT_PROCESS_DLY_MS);

#if _USE_LFN
		fn = *finfo.lfname ? finfo.lfname : finfo.fname;
		if (linnux_ftp_debug)
		{
			safe_print(printf("FTP: before List: fn pointer   = [%u], value = [%-100s]\n",(unsigned int)fn, fn));
			safe_print(printf("FTP: before List: finfo.fname  = addr: [%u] val: [%-100s]\n",(unsigned int) finfo.fname, finfo.fname));
			safe_print(printf("FTP: before List: finfo.lfname = addr: [%u] val: [%-100s]\n",(unsigned int) finfo.lfname, finfo.lfname));
		}

#else
		fn = finfo.fname;
#endif
		dbgftp("310\n");

		if (!strcmp(fn,".") || !strcmp(fn,".."))
		{
			//skip "." and ".."
			continue;
		}
		/* if client asked for long version of file listing */
		if (ftpcmd == 0x4c495354)  /* "LIST" */
		{
			/* print month, day, hour and minute, as in :
         -rw-r--r--   1 jharan   jharan  11772 Jan 19 13:31 install.log */
			/* since we don't have time stamps in the VFS, we lie about
			 * the date and time. if the VF_WRITE bit is set, the file
			 * is read/write so we display the roughly analogous
			 * Unix file mask corresponding to 666 else 444
			 */
			dbgftp("311\n");

			fattime_str = format_fat_date(finfo.fdate,finfo.ftime,fn);
			if (fattime_str=="")
			{
				safe_print(printf("[%s]FTP: Error: could not get fat time for file[%s]!\n",get_current_time_and_date_as_string_trimmed().c_str(),finfo.fname));
				continue;
			}
			snprintf(ftp->filebuf,FILEBUFSIZE/2,
					"%s 0 root root %11ld %s %s",
					((finfo.fattrib & AM_DIR)? "drwxrwxrwx" : "-rw-rw-rw-"),(long) finfo.fsize,fattime_str.c_str(),fn);
			if (linnux_ftp_debug)
			{
				safe_print(printf("FTP: List: fn pointer   = [%u], value = [%-100s]\n",(unsigned int)fn, fn));
				safe_print(printf("FTP: List: ftp->filebuf = addr: [%u] val: [%-100s]\n",(unsigned int) (ftp->filebuf), ftp->filebuf));
				safe_print(printf("FTP: List: finfo.fname  = addr: [%u] val: [%-100s]\n",(unsigned int) finfo.fname, finfo.fname));
				safe_print(printf("FTP: List: finfo.lfname = addr: [%u] val: [%-100s]\n",(unsigned int) finfo.lfname, finfo.lfname));
			}
			dbgftp("312\n");

		}
		else
		{
			dbgftp("313\n");
			/* else just give the client the file name */
			//strncpy(ftp->filebuf,fn,FILEBUFSIZE-2);
			snprintf(ftp->filebuf,FILEBUFSIZE-2,"%s",fn);
		}
		/* append a newline sequence to the end of the file listing */
		cp = ftp->filebuf + strlen(ftp->filebuf);
		*cp++ = '\r';
		*cp++ = '\n';
		*cp = 0;
		dbgftp("314\n");
		/* get number of bytes to transmit */
		bytes_to_send = cp - ftp->filebuf;

		blocked = 0;
		/* while there are bytes left to transmit */
		for (bytes_sent = 0; bytes_to_send > 0; )
		{
			dbgftp("315\n");
			/* try to send as much as is left to transmit */
			rc = t_send(ftp->datasock,ftp->filebuf + bytes_sent,bytes_to_send,0);
			dbgftp("316\n");
			/* this means some sort of error occurred */
			if (rc < 0)
			{
				/* get socket error. If it's s (hopefully) transient buffer shortage
				 * then just wait a bit and try again, up to a limit:
				 */
				dbgftp("317\n");
				rc = t_errno(ftp->datasock);
				dbgftp("318\n");
				if((rc == EWOULDBLOCK) || (rc == ENOBUFS))
				{
					dbgftp("319\n");
					if(blocked++ < 100)     /* don't loop here forever... */
					{
						dbgftp("320\n");

						tk_yield();    /* let system spin a bit */

						continue;
					}
					dbgftp("321\n");
				}
				dbgftp("322\n");
				ftpputs(ftp, "426 aborted, data send error\r\n");
				dbgftp("323\n");
				was_an_error = 1;
				break;
			}

			/* socket could be non-blocking, which means t_send() might have
            sent something less than what was requested */
			bytes_to_send -= rc;
			bytes_sent += rc;
			dbgftp("323a\n");
#ifndef BLOCKING_APP
			/* if the whole thing wasn't sent, it wont get any better
			 * if you don't yield to receive side
			 */
			if (bytes_to_send > 0)
			{
				dbgftp("324\n");

				tk_yield();

			}
#endif
		}
		dbgftp("325\n");
		/* if this happens, we broke in the loop above because of a
         socket error */
		if (bytes_to_send > 0)
		{
			dbgftp("326\n");
			was_an_error = 1;
			break;
		}
		dbgftp("327\n");
	}
	dbgftp("328\n");
	/* unlock the VFS */
	// vfs_unlock();

	/* if vfp is now NULL, then we exited the above loop without an
      error, so we can report that the transfer went ok */
	if (!was_an_error)
	{
		dbgftp("329\n");
		ftpputs(ftp, "226 Transfer OK, Closing connection\r\n");
	}

	/* close the data connection and leave passive state if we in it */
	my_ftp_leave_passive_state(ftp);

	return 0;   /* good return */
}



