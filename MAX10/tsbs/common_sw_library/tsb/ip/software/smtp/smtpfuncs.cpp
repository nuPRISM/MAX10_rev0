/*
 * Copyright (c) 2003, Mayukh Bose
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of Mayukh Bose nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */
/* 2003-11-17 - Reply-To Mod added by Chris Lacy-Hulbert */
/* 2003-12-26 - Added snprintf fix for WIN32. Thanks Wingman! */
/* 2004-09-09 - Changed the header/body of message to RFC 822 format (section 3.1)
                Thanks to Luke T. Gilbert (Luke.Gilbert@Nav-international.com) for
                the suggestion. */

//TODO  make more reliable SMTP call to socket (make sure that there is a timeout and that if SMTP is not responding, to retry and then abort)
//TODO  make socket calls more reliable so that a stuck socket doesn't stick the process
//TODO  check stack size via a task checking task (unnecessary due to large memory present)


#include <stdio.h>
#include <string>
#include <iostream>
#include <time.h>
//#include "linnux_server_dns_utils.h"
#include "cpp_linnux_dns_tools.h"
#include "linnux_utils.h"
extern "C" {
 //
 #include "my_mem_defs.h"
 #include "mem.h"
}
#include "smtpfuncs.h"
#include "trio/trio.h"
int send_mail(const char *smtpserver, const char *from, const char *to, 
					const char *subject, const char *replyto, const char *msg)
{
    int n_socket;
    int n_retval = 0;
    std::string linnux_board_name;

    linnux_board_name = std::string(" ").append(cpp_get_current_linnux_board_hostname_no_postfix()).append("linnux.ca.\r\n");

    #define SMTPWAITTIME 5000

    std::string timestamp_str = get_current_time_and_date_as_string();
    TrimSpaces(timestamp_str);
	safe_print(std::cout << "[" << timestamp_str << "] Connecting to SMTP server [ " << linnux_board_name << "]" << std::endl);

	/* First connect the socket to the SMTP server */
	if ((n_socket = connect_to_server(smtpserver)) == ERROR) 
		n_retval = E_NO_SOCKET_CONN;

	  int nonblock = 0;
	  if (t_setsockopt(n_socket, SOL_SOCKET, SO_NONBLOCK, &nonblock,  1) == -1)
	  {
	          safe_print(printf("SEND: setsockopt error"));
	          return ERROR;
	  }

	safe_print(printf("Check1: n_retval = %d\n",n_retval));
	/* All connected. Now send the relevant commands to initiate a mail transfer */
	//if (n_retval == 0 && send_command(n_socket, "", "HELO", " 10.48.50.241\r\n", MAIL_OK) == ERROR)
		//if (n_retval == 0 && send_command(n_socket, "", "HELO", " linnux-board0.linnux.ca.\r\n", MAIL_OK) == ERROR)
	if (n_retval == 0 && send_command(n_socket, "", "HELO", linnux_board_name.c_str(), MAIL_OK) == ERROR)
		n_retval = E_PROTOCOL_ERROR;
		usleep(SMTPWAITTIME);
	safe_print(printf("Check1.5: n_retval = %d\n",n_retval));

	if (n_retval == 0 && send_command(n_socket, "MAIL From:<", from, ">\r\n", MAIL_OK) == ERROR)
		n_retval = E_PROTOCOL_ERROR;
	usleep(SMTPWAITTIME);

	safe_print(printf("Check2: n_retval = %d\n",n_retval));
	if (n_retval == 0 && send_command(n_socket, "RCPT To:<", to, ">\r\n", MAIL_OK) == ERROR) 
		n_retval = E_PROTOCOL_ERROR;
	usleep(SMTPWAITTIME);

	safe_print(printf("Check3: n_retval = %d\n",n_retval));

	/* Now send the actual message */
	if (n_retval == 0 && send_command(n_socket, "", "DATA", "\r\n", MAIL_GO_AHEAD) == ERROR) 
		n_retval = E_PROTOCOL_ERROR;
	usleep(SMTPWAITTIME);

	safe_print(printf("Check4: n_retval = %d\n",n_retval));

	if (n_retval == 0 && send_mail_message(n_socket, from, to, subject, replyto, msg) == ERROR) 
		n_retval = E_PROTOCOL_ERROR;
	safe_print(printf("Check5: n_retval = %d\n",n_retval));
	usleep(SMTPWAITTIME);

	/* Now tell the mail server that we're done */
	if (n_retval == 0 && send_command(n_socket, "", "QUIT", "\r\n", MAIL_GOODBYE) == ERROR) 
		n_retval = E_PROTOCOL_ERROR;
	safe_print(printf("Check6: n_retval = %d\n",n_retval));
	usleep(SMTPWAITTIME);

	/* Now close up the socket and clean up */
	if (close(n_socket) == ERROR) {
		safe_print(printf("Could not close socket.\n"));
		n_retval = ERROR;
	}
	usleep(SMTPWAITTIME);

	safe_print(printf("Check7: n_retval = %d\n",n_retval));
	usleep(SMTPWAITTIME);

#ifdef WIN32
	cleanup_sockets_lib();
#endif

	return n_retval;
}

int connect_to_server(const char *server)
{
	struct hostent *host;
	struct in_addr	inp;
	struct protoent *proto;
	struct sockaddr_in sa;
	int n_sock;
#define SMTP_PORT	   25
#define BUFSIZE		4096
	char s_buf[BUFSIZE] = "";
	int n_ret;
    char *tempsrvername = my_mem_strdup(server);
	/* First resolve the hostname */
	host = gethostbyname(tempsrvername);
	if (host == NULL) {
		safe_print(fprintf(stderr, "Could not resolve hostname %s. Aborting...\n", server));
		if (tempsrvername != NULL){
			my_mem_free(tempsrvername);
		}
		return ERROR;
	}

	memmove(&inp, host->h_addr_list[0], host->h_length);

	/* Now create the socket structure */
	if ((n_sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		safe_print(fprintf(stderr, "Could not create a TCP socket. Aborting...\n"));
		if (tempsrvername != NULL){
			my_mem_free(tempsrvername);
		}
		return ERROR;
	}

	/* Now connect the socket */
	memset(&sa, 0, sizeof(sa));
	sa.sin_addr = inp;
	sa.sin_family = host->h_addrtype;
	sa.sin_port = htons(SMTP_PORT);
	if (connect(n_sock, (struct sockaddr *)&sa, sizeof(sa)) == SOCKET_ERROR) {
		safe_print(fprintf(stderr, "Connection refused by host %s.", server));
		if (tempsrvername != NULL){
			my_mem_free(tempsrvername);
		}
		return ERROR;
	}

	/* Now read the welcome message */
	n_ret = recv(n_sock, s_buf, BUFSIZE, 0);
	if (tempsrvername != NULL){
		my_mem_free(tempsrvername);
	}
	return n_sock;
}

int send_command(int n_sock, const char *prefix, const char *cmd, 
						const char *suffix, int ret_code)
{

    #define BUFSIZE		4096
	char *s_buf;
	char recv_str[BUFSIZE] = "";
	char s_buf2[50];
	int numbytes_received;
	
	std::string str_buf = "";
	/*
 	strncpy(s_buf, prefix, BUFSIZE-2);
	strncat(s_buf, cmd, BUFSIZE-2);
	strncat(s_buf, suffix, BUFSIZE-2);
	*/
	str_buf.append(std::string(prefix)).append(cmd).append(suffix);
	s_buf = my_mem_strdup(str_buf.c_str());
    safe_print(printf("Sending : [%s]\n",s_buf));
	if (send(n_sock, s_buf, strlen(s_buf), 0) == SOCKET_ERROR) {
		safe_print(fprintf(stderr, "Could not send command string %s to server.", s_buf));
		my_mem_free(s_buf);
		return ERROR;
	}
    my_mem_free(s_buf);
	/* Now read the response. */
	numbytes_received = recv(n_sock, recv_str, BUFSIZE-5, 0);
	if (numbytes_received >=0)
	{
		recv_str[numbytes_received] = '\0';
	}

	safe_print(printf("Received result: [%s]\n",recv_str));
	/* Now check if the ret_code is in the buf */
	snprintf(s_buf2, 40, "%d", ret_code);
	safe_print(printf("checking for retcode: %d [%s]\n",ret_code,s_buf2));
	if (strstr(recv_str, s_buf2) != NULL)
		return TRUE;
	else
		return ERROR;
}

int send_mail_message(int n_sock, const char *from, const char *to,
							const char *subject, const char *replyto, const char *msg)
{
#define BUFSIZE		4096
#define BUFSIZE2	100
#define MSG_TERM	"\r\n.\r\n"
#define MAIL_AGENT	"Mayukh's SMTP code (http://www.mayukhbose.com/freebies/c-code.php)"
	char s_buf[BUFSIZE];
	char s_buf2[BUFSIZE2];
	time_t t_now = time(NULL);
	char* tmpmsg=NULL;
	tmpmsg = my_mem_strdup(msg);
	if (tmpmsg==NULL){
		safe_print(printf("Warning: Sending NULL message in send_mail_message!\n"));
	}
	int n_ret;

	/* First prepare the envelope */
	strftime(s_buf2, BUFSIZE2, "%a, %d %b %Y  %H:%M:%S +0000", gmtime(&t_now));

	snprintf(s_buf, BUFSIZE, "Date: %s\r\nFrom: %s\r\nTo: %s\r\nSubject: %s\r\nReply-To: %s\r\n\r\n",
				s_buf2, from, to, subject, replyto);

	/* Send the envelope */
	if (send(n_sock, s_buf, strlen(s_buf), 0) == SOCKET_ERROR) {
		safe_print(fprintf(stderr, "Could not send message header: %s", s_buf));
		if (tmpmsg!=NULL) {my_mem_free(tmpmsg);};
		return ERROR;
	}

	/* Now send the message */
	if (send(n_sock, tmpmsg, strlen(tmpmsg), 0) == SOCKET_ERROR) {
		safe_print(fprintf(stderr, "Could not send the message %s\n", msg));
		if (tmpmsg!=NULL) {my_mem_free(tmpmsg);};
		return ERROR;
	}

	/* Now send the terminator*/
	if (send(n_sock, MSG_TERM, strlen(MSG_TERM), 0) == SOCKET_ERROR) {
		safe_print(fprintf(stderr, "Could not send the message terminator.\n"));
		if (tmpmsg!=NULL) {my_mem_free(tmpmsg);};
		return ERROR;
	}

	/* Read and discard the returned message ID */
	n_ret = recv(n_sock, s_buf, BUFSIZE, 0);
	if (tmpmsg!=NULL) {my_mem_free(tmpmsg);};
	return TRUE;
}

int send_smtp_mail(const std::string& smtpserver, const std::string& from, const std::string& to,
		const std::string& subject, const std::string& replyto, const std::string& msg)
{
   return send_mail(smtpserver.c_str(), from.c_str(), to.c_str(),
					subject.c_str(), replyto.c_str(), msg.c_str());
}
