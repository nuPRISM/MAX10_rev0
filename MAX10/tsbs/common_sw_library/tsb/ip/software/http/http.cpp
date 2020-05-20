/******************************************************************************
 * Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
 * All rights reserved. All use of this software and documentation is          *
 * subject to the License Agreement located at the end of this file below.     *
 *******************************************************************************
 *                                                                             *
 * File: http.c                                                                *
 *                                                                             *
 * A rough imlementation of HTTP. This is not intended to be a complete        *
 * implementation, just enough for a demo simple web server. This example      *
 * application is more complex than the telnet serer example in that it uses   *
 * non-blocking IO & multiplexing to allow for multiple simultaneous HTTP      *
 * sessions.                                                                   *
 *                                                                             *
 * This example uses the sockets interface. A good introduction to sockets     *
 * programming is the book Unix Network Programming by Richard Stevens         *
 *                                                                             *
 * Please refer to file ReadMe.txt for notes on this software example.         *
 *******************************************************************************/
//#define DEBUG_HTTP_INSERTION
#define DIE_WITH_ERROR_BUFFER 256

#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <ctype.h>
#include "basedef.h"
#include "handle_cgi_query_str.h"
#include "cpp_to_c_header_interface.h"
#include "http.h"
#include "ucos_cpp_utils.h"
#include "linnux_utils.h"
extern "C" {
#include "my_mem_defs.h"
#include <sys/param.h>
#include <sys/fcntl.h>
#include "sys/alt_alarm.h"
#include "alt_types.h"

//#include "simple_socket_server.h"
#include "ipport.h"
#include "libport.h"
#include "osport.h"
#include "tcpport.h"
#include "mtrand/mtrand_c_interface.h"
#include "my_mem_defs.h"
#include "mem.h"
#include "trio/trio.h"
#include "slre.h"

}

#include <climits>
#if defined(IS_GRIF16) || SUPPORT_BOARD_MANAGEMENT_UART
#include "board_management.h"
#endif

#ifdef DEBUG
#include alt_debug.h
#else
#define ALT_DEBUG_ASSERT(a)
#endif /* DEBUG */

#define d_dh(x) do { if (LINNUX_DEBUG_HTTP) { x; } } while (0)


#if HTTP_SERVER_SUPPORT_FLASH_MEMORY_DOWNLOAD_AS_FILE
extern void* open_external_flash_for_http_file_download(unsigned int index, int* error);
extern int read_from_flash_for_http_file_download(void* flash_ptr, int offset, void* dest_addr, int length);
extern int get_flash_length_for_http_file_download(void* flash_ptr);
#endif


#if HTTP_SERVER_SUPPORT_MEMORY_DOWNLOAD_AS_FILE
extern int get_mem_region_data_for_http_file_download(unsigned int index, unsigned int *base_address, unsigned int *length);
#endif

struct slre        flash_match_slre;
struct slre        mem_match_slre;


int http_find_file(http_conn* conn);
/* 
 * TX & RX buffers. 
 * 
 * These are declared globally to prevent the MicroC/OS-II thread from
 * consuming too much OS-stack space
 */
alt_u8 http_rx_buffer[HTTP_NUM_CONNECTIONS][HTTP_RX_BUF_SIZE];
alt_u8 http_tx_buffer[HTTP_NUM_CONNECTIONS][HTTP_TX_BUF_SIZE];

char constant_bw_check_str[HTTP_TX_BUF_SIZE+2];
int bw_check_strlen = 0;



/* Declare upload buffer structure globally. */
struct upload_buf_struct
{
	alt_u8* wr_pos;
	alt_u8* rd_pos;
	alt_u8 buffer[UPLOAD_BUF_SIZE];
} upload_buf;

/* Declare a structure to hold flash programming information. */
struct flash_inf_struct
{
	alt_u8* start;
	int size;
	alt_u8 device[40];
}flash_inf;

void die_with_error(char err_msg[DIE_WITH_ERROR_BUFFER])
{
	safe_print(printf("\nFatal Error: %s\n", err_msg));

	OSTaskDel(OS_PRIO_SELF);

	while(1);
}
/*Function prototypes and external functions. */


void gen_random(char *s, const int len) {
	static const char alphanum[] =
			"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	int i = 0;
	for (i = 0; i < len; ++i) {
		//s[i] = alphanum[gm_rand() % (sizeof(alphanum) - 1)];
		s[i] = alphanum[gm_rand() & (0x1F)]; //"&" should be faster than "%";
	}

	s[len] = 0;
}



#ifdef RECONFIG_REQUEST_PIO_NAME
extern void trigger_reset();
#endif
extern int ParseSRECBuf(struct flash_inf_struct *flash_info);



/* 
 * This canned HTTP reply will serve as a "404 - Not Found" Web page. HTTP
 * headers and HTML embedded into the single string.
 */
static const alt_8 canned_http_response[] = {"\
		HTTP/1.0 404 Not Found\r\n\
		Content-Type: text/html\r\n\
		Content-Length: 272\r\n\r\n\
		<HTML><HEAD><TITLE>Nios II Web Server Demonstration</TITLE></HEAD>\
		<title>NicheStack on Nios II</title><BODY><h1>HTTP Error 404</h1>\
		<center><h2>Nios II Web Server Demonstration</h2>\
		Can't find the requested file file. \
		Have you programmed the flash filing system into flash?</html>\
		"};

static const alt_8 canned_response2[] = {"\
		HTTP/1.0 200 OK\r\n\
		Content-Type: text/html\r\n\
		Content-Length: 2000\r\n\r\n\
		<HTML><HEAD><TITLE>Nios II Web Server Demonstration</TITLE></HEAD>\
		<title>NicheStack on Nios II</title><BODY>\
		<center><h2>Nios II Web Server Hardware Report</h2>\
		</center>\
		"};
/* 
 * Mapping between pages to post to and functions to call: This allows us to
 * have the HTTP server respond to a POST requset saying "print" by calling
 * a "print" routine (below).
 */
typedef struct funcs
{
	alt_u8*  name;
	void (*func)();
}post_funcs;

/* 
 * print()
 * 
 * This routine is called to demonstrate doing something server-side when an
 * HTTP "POST" command is received.
 */
void print()
{
	d_dh(safe_print(printf("HTTP POST received.\n")););
}

int http_parse_multipart_header( http_conn* conn )
{

	d_dh(safe_print(printf("http_parse_multipart_header 1\n")););
	/* Most of the information is on the first line following the boundary. */
	alt_u8* cr_pos;
	alt_u8* temp_pos;

	/*
	 * For now, make the assumption that no multipart headers are split
	 * across packets.  This is a reasonable assumption, but not a surety.
	 *
	 */
	while( (temp_pos = (alt_u8 *) strstr( (char *)conn->rx_rd_pos, (char *) conn->boundary )) )
	{
		d_dh(safe_print(printf("http_parse_multipart_header 2\n")););
		if( strstr( (char *) conn->rx_rd_pos, "upload_image" ) )
		{
			/* Terminate the received data by going back 5
			 * from temp_pos and setting it to NULL.*/
			*(temp_pos-5) = '\0';
			conn->file_upload = 0;
			break;
		}
		/* Find the end of the content disposition line. */
		conn->rx_rd_pos = (alt_u8 *) strstr( (char *)conn->rx_rd_pos, "Content-Disposition" );
		if( conn->rx_rd_pos == 0 ) return(-1);
		cr_pos = (alt_u8 *) strchr( (char *)conn->rx_rd_pos, '\r' );
		if( cr_pos == 0 ) return(-1);
		/* Insert a NULL byte over the second quotation mark. */
		*(cr_pos - 1) = '\0';
		/* Move rx_rd_pos to end of the line, just beyond the newly
		 * inserted NULL.
		 */
		/* Look for "=" delimiter. */
		temp_pos = (alt_u8 *) strchr( (char *) conn->rx_rd_pos, '=' );
		if( temp_pos == 0 ) return(-1);
		d_dh(safe_print(printf("http_parse_multipart_header 3\n")););
		/* If second "=" delimiter exists, then parse for conn->filename. */
		if( (temp_pos = (alt_u8 *) strchr( (char *) (temp_pos+1), '=' )) )
		{
			d_dh(safe_print(printf("http_parse_multipart_header 4\n")););
			if( strlen((char *)temp_pos+2) > 256 )
			{
				return(-1);
			}
			strcpy((char *) conn->filename, (char *)(temp_pos+2) );
			d_dh(safe_print(printf("upload filename = %s\n", (char *) conn->filename)););
			/*
			 * Place rx_rd_pos at the start of the next pertinent line.
			 * In this case, skip two lines ahead.
			 */
			cr_pos = (alt_u8 *) strchr( (char *) (cr_pos+1), '\r');
			if( cr_pos == 0 ) return(-1);
			cr_pos = (alt_u8 *) strchr( (char *) (cr_pos+1), '\r');
			if( cr_pos == 0 ) return(-1);
			conn->rx_rd_pos = cr_pos+2;
		}
		else
		{
			d_dh(safe_print(printf("http_parse_multipart_header 5\n")););
			/*
			 * If no second delimiter, then skip ahead to start of 2nd. line.
			 * That will be the start of the flash device name.
			 *
			 */
			temp_pos = (alt_u8 *) strchr( (char *) (cr_pos+1), '\r' );
			conn->rx_rd_pos = temp_pos+2;
			cr_pos = (alt_u8 *) strchr( (char *) conn->rx_rd_pos, '\r' );
			*cr_pos = '\0';
			/* Ok, now copy the flash_device string. */
			strcpy( (char *) conn->flash_device, (char *) conn->rx_rd_pos );
			/* Place rx_rd_pos at the start of the next line. */
			conn->rx_rd_pos = cr_pos+2;
		}
	}
	d_dh(safe_print(printf("http_parse_multipart_header 6\n")););

	return(0);
}

void file_upload(http_conn* conn)
{
	d_dh(safe_print(printf( ("in file upload 1\n"))););
	int buf_len;
	int data_used;
	struct upload_buf_struct *upload_buffer = &upload_buf;
	struct flash_inf_struct *flash_info = &flash_inf;
	/* Look for boundary, parse multipart form "mini" header information if found. */
	d_dh(safe_print(printf( ("in file upload 2\n"))););
	if( strstr((char *) conn->rx_rd_pos, (char *) conn->boundary ) )
	{
		if( http_parse_multipart_header( conn ) )
		{
			d_dh(safe_print(printf( "multipart-form:  header parse failure...resetting connection!" )););
			conn->state = RESET_HTTP;
		}
	}
	d_dh(safe_print(printf( ("in file upload 3\n"))););
	/* Exception for IE.  It sometimes sends _really_ small initial packets! */
	if( strchr( (char *) conn->rx_rd_pos, ':' ) )
	{
		conn->state = READY_HTTP;
		return;
	}
	d_dh(safe_print(printf( ("in file upload 4\n"))););
	/* Calculate the string size... */
	buf_len = strlen((char *) conn->rx_rd_pos);
	conn->content_received = conn->content_received + buf_len;
	/* Copy all the received data into the upload buffer. */
	if ( memmove( (void*) upload_buffer->wr_pos,
			(void*) conn->rx_rd_pos,
			buf_len ) == NULL )
	{
		d_dh(safe_print(printf("ERROR:  memcpy to file upload buffer failed!" )););
	}
	d_dh(safe_print(printf( ("in file upload 5\n"))););
	/* Increment the wr_pos pointer to just after the received data. */
	upload_buffer->wr_pos = upload_buffer->wr_pos + buf_len;
	conn->rx_rd_pos = conn->rx_rd_pos + buf_len;
	/* Reset the buffers after copying the data into the big intermediate
	 * buffer.*/
	data_used = conn->rx_rd_pos - conn->rx_buffer;
	memmove(conn->rx_buffer,conn->rx_rd_pos,conn->rx_wr_pos-conn->rx_rd_pos);
	conn->rx_rd_pos = conn->rx_buffer;
	conn->rx_wr_pos -= data_used;
	d_dh(safe_print(printf( ("in file upload 6\n"))););
	//memset(conn->rx_wr_pos, 0, data_used);
	if ( conn->file_upload == 0 )
	{
		d_dh(safe_print(printf("Received a total of %d bytes.\n", conn->content_received )););
		/* Insert a NULL character (temporarily). */
		*upload_buffer->wr_pos = '\0';
		/* Populate flash_info struct... print the buffer size. */
		flash_info->size = (int) strlen((char *)upload_buffer->buffer);
		d_dh(safe_print(printf("Upload Buffer size = %d.\n", flash_info->size)););
		strcpy( (char *)flash_info->device, (char *)conn->flash_device );
		flash_info->start = upload_buffer->rd_pos;
		/* Populate the flash_inf struct. */
		//safe_print(printf( "Here's the Buffer:\n\n%s", upload_buffer->buffer));
		d_dh(safe_print(printf( ("in file upload 7\n"))););
		http_find_file(conn);
		conn->close = 1;
	}
	else
	{
		d_dh(safe_print(printf( ("in file upload 8\n"))););
		conn->state = READY_HTTP;
	}
}


#ifdef RECONFIG_REQUEST_PIO_NAME
post_funcs reset_field =
{
		"/RESET_SYSTEM",
		trigger_reset
};
#endif

/*
 * http_reset_connection()
 * 
 * This routine will clear our HTTP connection structure & prepare it to handle
 * a new HTTP connection.
 */
void http_reset_connection(http_conn* conn, int http_instance)
{
	memset(conn, 0, sizeof(http_conn));

	conn->fd = -1;
	conn->state = READY_HTTP;
	conn->keep_alive_count = HTTP_KEEP_ALIVE_COUNT;

	conn->rx_buffer = (alt_u8 *) &(http_rx_buffer[http_instance][0]);
	conn->tx_buffer = (alt_u8 *) &(http_tx_buffer[http_instance][0]);
	conn->rx_wr_pos = (alt_u8 *) &(http_rx_buffer[http_instance][0]);
	conn->rx_rd_pos = (alt_u8 *) &(http_rx_buffer[http_instance][0]);
}

/*
 * http_manage_connection()
 * 
 * This routine performs house-keeping duties for a specific HTTP connection
 * structure. It is called from various points in the HTTP server code to
 * ensure that connections are reset properly on error, completion, and
 * to ensure that "zombie" connections are dealt with.
 */
void http_manage_connection(http_conn* conn, int http_instance)
{
	alt_u32 current_time = 0;

	/*
	 * Keep track of whether an open connection has timed out. This will be
	 * determined by comparing the current time with that of the most recent
	 * activity.
	 */
	if(conn->state == READY_HTTP || conn->state == PROCESS_HTTP || conn->state == DATA_HTTP)
	{
		current_time = alt_nticks();

		if( ((current_time - conn->activity_time) >= HTTP_KEEP_ALIVE_TIME) && conn->file_upload != 1 )
		{
			conn->state = RESET_HTTP;
		}
	}

	/*
	 * The reply has been sent. Is is time to drop this connection, or
	 * should we persist? We'll keep track of these here and mark our
	 * state machine as ready for additional connections... or not.
	 *  - Only send so many files per connection.
	 *  - Stop when we reach a timeout.
	 *  - If someone (like the client) asked to close the connection, do so.
	 */
	if(conn->state == COMPLETE_HTTP)
	{
		if(conn->file_is_currently_open)
		{
			f_close(&conn->file_handle);
			conn->file_is_currently_open = 0;
		}

		conn->keep_alive_count--;
		conn->data_sent = 0;

		if(conn->keep_alive_count == 0)
		{
			conn->close = 1;
		}

		conn->state = conn->close ? CLOSE_HTTP : READY_HTTP;
	}

	/*
	 * Some error occured. http_reset_connection() will take care of most
	 * things, but the RX buffer still needs to be cleared, and any open
	 * files need to be closed. We do this in a separate state to maintain
	 * efficiency between successive (error-free) connections.
	 */
	if(conn->state == RESET_HTTP)
	{
		if(conn->file_is_currently_open)
		{
			f_close(&conn->file_handle);
			conn->file_is_currently_open = 0;
		}

		memset(conn->rx_buffer, 0, HTTP_RX_BUF_SIZE);
		conn->state = CLOSE_HTTP;
	}

	/* Close the TCP connection */
	if(conn->state == CLOSE_HTTP)
	{
		t_shutdown(conn->fd,2); //shut down both read and write
		close(conn->fd);
		if ((conn->c_string_to_send_instead_of_file != ((char*) NULL)) &&  (conn->file_is_actually_a_c_string))
		{
			my_mem_free(conn->c_string_to_send_instead_of_file);
			conn->c_string_to_send_instead_of_file = (char*)NULL;
		}
		http_reset_connection(conn, http_instance);
	}
}

/*
 * http_handle_accept()
 * 
 * A listening socket has detected someone trying to connect to us. If we have 
 * any open connection slots we will accept the connection (this creates a 
 * new socket for the data transfer), but if all available connections are in 
 * use we'll ignore the client's incoming connection request.
 */
HTTP_ACCEPT_RTSTATUS http_handle_accept(int listen_socket, http_conn* conn)
{
	HTTP_ACCEPT_RTSTATUS ret_code = HTTP_ACCEPT_RTSTATUS_HTTP_OK;
	int i, socket, len;

	struct sockaddr_in rem;

	len = sizeof(rem);

	/*
	 * Loop through available connection slots to determine the first available
	 * connection.
	 */
	for(i=0; i<HTTP_NUM_CONNECTIONS; i++)
	{
		if((conn+i)->fd == -1)
		{
			break;
		}
	}

	/*
	 * There are no more connection slots available. Ignore the connection
	 * request for now.
	 */
	if(i == HTTP_NUM_CONNECTIONS)
		return HTTP_ACCEPT_RTSTATUS_MAX_HTTP_CONN;

	if((socket = accept(listen_socket,(struct sockaddr*)&rem,&len)) < 0)
	{

		d_dh(safe_print(fprintf(stderr, "[http_handle_accept] accept failed (%d)\n", socket)););
		return HTTP_ACCEPT_RTSTATUS_ACCEPT_FAILED;
	}

	(conn+i)->fd = socket;
	(conn+i)->activity_time = alt_nticks();

	return ret_code;
}

/*
 * http_read_line()
 * 
 * This routine will scan the RX data buffer for a newline, allowing us to
 * parse an in-coming HTTP request line-by-line.
 */
int http_read_line(http_conn* conn)
{
	alt_u8* lf_addr;
	int ret_code = 0;

	/* Find the Carriage return which marks the end of the header */
	lf_addr = (alt_u8 *) strchr((char *)conn->rx_rd_pos, '\n');

	if (lf_addr == NULL)
	{
		ret_code = -1;
	}
	else
	{
		/*
		 * Check that the line feed has a matching CR, if so zero that
		 * else zero the LF so we can use the string searching functions.
		 */
		if ((lf_addr > conn->rx_buffer) && (*(lf_addr-1) == '\r'))
		{
			*(lf_addr-1) = 0;
		}

		*lf_addr = 0;
		conn->rx_rd_pos = lf_addr+1;
	}

	return ret_code;
}

/* http_process_multipart()
 * 
 * This function parses and parses relevant "header-like" information
 * from HTTP multipart forms.
 *   - Content-Type, Content-Disposition, boundary, etc.
 */
int http_parse_type_boundary( http_conn* conn,
		char* start,
		int len )
{
	char* delimiter;
	char* boundary_start;
	char line[HTTP_MAX_LINE_SIZE];

	/* Copy the Content-Type/Boundary line. */
	if( len > HTTP_MAX_LINE_SIZE )
	{
		d_dh(safe_print(printf( "process headers:  overflow content-type/boundary parsing.\n" )););
		return(-1);
	}
	strncpy( line, start, len );
	/* Add a null byte to the end of it. */
	*(line + len) = '\0';
	/* Get the Content-Type value. */
	if( (delimiter = strchr( line, ';' )) )
	{
		/* Need to parse both a boundary and Content-Type. */
		boundary_start = strchr( line, '=' ) + 2;
		strcpy( (char *) conn->boundary, (char *)boundary_start);
		/* Insert a null space in place of the delimiter. */
		*delimiter = '\0';
		/* First part of the line is the Content-Type. */

		strcpy( (char *)conn->content_type, (char *)line);
	}
	else
	{
		strcpy( (char *)conn->content_type, (char *)line );
	}
	return 0;
}

/*
 * http_process_headers()
 * 
 * This routine looks for HTTP header commands, specified by a ":" character.
 * We will look for "Connection: Close" and "Content-length: <len>" strings. 
 * A more advanced server would parse far more header information.
 * 
 * This routine should be modified in the future not to use strtok() as its
 * a bit invasive and is not thread-safe!
 * 
 */
int http_process_headers(http_conn* conn)
{
	alt_u8* option;
	alt_u8* cr_pos;
	alt_u8* ct_start;
	alt_u8* orig_read_pos = conn->rx_rd_pos;
	alt_u8* delimiter_token;
	alt_u8 temp_null;
	alt_u8* boundary_start;
	int ct_len;
	int opt_len;


	/*
	 * A boundary was found.  This is a multi-part form
	 * and header processing stops here!
	 *
	 */
	if( (conn->boundary[0] == '-') && (conn->content_length > 0) )

	{
		boundary_start = (alt_u8 *)strstr( (char *)conn->rx_rd_pos,(char *) conn->boundary );
		//conn->rx_rd_pos = boundary_start + strlen(conn->boundary);
		return -1;
	}
	/* Skip the next section we'll chop with strtok(). Perl for Nios, anyone? */
	else if( (delimiter_token = (alt_u8 *)strchr((char *)conn->rx_rd_pos, ':')) )
	{
		conn->rx_rd_pos = delimiter_token + 1;
		conn->content_received = conn->rx_rd_pos - conn->rx_buffer;
	}
	else
	{
		return -1;
	}

	option = (alt_u8 *)strtok((char *)orig_read_pos, ":");

	if(stricmp((char *)option,"Connection") == 0)
	{
		temp_null = *(option + 17);
		*(option + 17) = 0;

		if(stricmp((char *)(option+12), "close") == 0)
		{
			conn->close = 1;
		}
		*(option + 17) = temp_null;
	}
	else if (stricmp((char *)option, "Content-Length") == 0)
	{
		conn->content_length = atoi((char *)(option+16));
		//printf( "Content Length = %d.\n", conn->content_length );
	}
	/* When getting the Content-Type, get the whole line and throw it
	 * to another function.  This will be done several times.
	 */
	else if (stricmp((char *)option, "Content-Type" ) == 0)
	{
		/* Determine the end of line for "Content-Type" line. */
		cr_pos = (alt_u8 *)strchr((char *) conn->rx_rd_pos, '\r' );
		/* Find the length of the string. */
		opt_len = strlen((char *)option);
		ct_len = cr_pos - (option + opt_len + 2);
		/* Calculate the start of the string. */
		ct_start = cr_pos - ct_len;
		/* Pass the start of the string and the size of the string to
		 * a function.
		 */
		if( (http_parse_type_boundary( conn, (char *)ct_start, ct_len ) < 0) )
		{
			/* Something failed...return a negative value. */
			return -1;
		}
	}
	return 0;
}

/*
 * http_process_request()
 * 
 * This routine parses the beginnings of an HTTP request to extract the
 * command, version, and URI. Unsupported commands/versions/etc. will cause
 * us to error out drop the connection.
 */
int http_process_request(http_conn* conn)
{
	alt_u8* uri = 0;
	alt_u8* version = 0;
	alt_u8* temp = 0;
	if( (temp = (alt_u8*)strstr((char *)conn->rx_rd_pos, "GET")) )
	{
		conn->action = GET;
		conn->rx_rd_pos = temp;
	}
	else if( (temp = (alt_u8*)strstr((char *)conn->rx_rd_pos, "POST")) )
	{
		conn->action = POST;
		conn->rx_rd_pos = temp;
	}
	else
	{
		safe_print(fprintf(stderr, "Unsupported (for now) request\n"));
		conn->action = UNKNOWN;
		return -1;
	}

	/* First space char separates action from URI */
	if( (conn->rx_rd_pos = (alt_u8*)strchr((char *)conn->rx_rd_pos, ' ')) )
	{
		conn->rx_rd_pos++;
		uri = conn->rx_rd_pos;
	}
	else
	{
		return -1;
	}

	/* Second space char separates URI from HTTP version. */
	if( (conn->rx_rd_pos = (alt_u8*)strchr((char *)conn->rx_rd_pos, ' ')) )
	{
		*conn->rx_rd_pos = 0;
		conn->rx_rd_pos++;
		version = conn->rx_rd_pos;
	}
	else
	{
		return -1;
	}

	/* Is this an HTTP version we support? */
	if ((version == NULL) || (strncmp((char *)version, "HTTP/", 5) != 0))
	{
		return -1;
	}

	if (!isdigit(version[5]) || version[6] != '.' || !isdigit(version[7]))
	{
		return -1;
	}

	/* Before v1.1 we close the connection after responding to the request */
	if ( (((version[5] - '0')*10) + version[7] - '0') < 11)
	{
		conn->close = 1;
	}

	strcpy((char *)conn->uri, (char *)uri);

	return 0;
}

/*
 * http_send_file_chunk()
 * 
 * This routine will send the next chunk of a file during an open HTTP session
 * where a file is being sent back to the client. This routine is called 
 * repeatedly until the file is completely sent, at which time the connection
 * state will go to "COMPLETE". Doing this rather than sending the entire
 * file allows us (in part) to multiplex between connections "simultaneously".
 */
int http_send_file_chunk(http_conn* conn)
{
	int chunk_sent = 0, ret_code = 0, result = 0;
	int i;
	static int chuck_count = 0;
	alt_u8* tx_ptr;
	UINT file_chunk_size = 0;
	chuck_count++;
	//printf("send file chunk: %d conn->fd: %d\n", chuck_count, conn->fd);
	if(conn->data_sent < conn->file_length)
	{
		// file_chunk_size = fread(conn->tx_buffer, 1, MIN(HTTP_TX_BUF_SIZE, (conn->file_length - conn->data_sent)), conn->file_handle);
		if (conn->file_is_actually_a_c_string)
		{
			//file_chunk_size = snprintf((char*)conn->tx_buffer, MIN(HTTP_TX_BUF_SIZE, (conn->file_length - conn->data_sent)), "%s", (char *)(((char *) conn->c_string_to_send_instead_of_file) + conn->data_sent));
			//if (file_chunk_size > MIN(HTTP_TX_BUF_SIZE, (conn->file_length - conn->data_sent)))
			//{
			file_chunk_size = MIN(HTTP_TX_BUF_SIZE, (conn->file_length - conn->data_sent));
			memmove((void *) conn->tx_buffer, (void *) (conn->c_string_to_send_instead_of_file + conn->data_sent), file_chunk_size);
			//}
			//safe_print(printf("file chunk size: %d, conn->file_length: %d data_sent: %d str[%s]\n",(int) file_chunk_size, (int) conn->file_length, (int) conn->data_sent, conn->c_string_to_send_instead_of_file));
			//safe_print(printf("original ptr: %u calculated_ptr: %u ", (unsigned int) conn->c_string_to_send_instead_of_file, (unsigned int)  ((char *)(((char *) conn->c_string_to_send_instead_of_file) + conn->data_sent)));

			//printf("tx_buffer: [")));
			//for (i=0; i < file_chunk_size; i++)
			//	{
			//	   safe_print(printf("%c",*(conn->tx_buffer+i)));
			//	};
			//safe_print(printf("]\n"));

		} else
		{
			if (conn->we_are_actually_doing_a_bw_check) {
				file_chunk_size = bw_check_strlen;
				strncpy((char *)conn->tx_buffer,constant_bw_check_str,file_chunk_size);
				gen_random(constant_bw_check_str,HTTP_TX_BUF_SIZE-1);
			} else {
				if (conn->file_is_actually_flash) {
					file_chunk_size =  MIN(HTTP_TX_BUF_SIZE, (conn->file_length - conn->data_sent));
					/*
					int cpu_sr;
					//enter critical mode because read flash is supposedly not thread safe
					OS_ENTER_CRITICAL();
					alt_read_flash(conn->flash_ptr,
							conn->current_flash_offset,
							(void *) conn->tx_buffer,
							file_chunk_size);
					conn->current_flash_offset += file_chunk_size;
					OS_EXIT_CRITICAL();
					*/
                    int ret_code;
#if HTTP_SERVER_SUPPORT_FLASH_MEMORY_DOWNLOAD_AS_FILE
					ret_code = read_from_flash_for_http_file_download(conn->flash_ptr,
												conn->current_flash_offset,
												(void *) conn->tx_buffer,
												file_chunk_size);
#else
					ret_code = -1;
#endif

					d_dh(safe_print(printf("[http_send_file_chunk] read_from_flash_for_http_file_download returned %d, conn->flash_ptr = 0x%x conn->current_flash_offset = %d file_chunk_size = %d\n", ret_code, conn->flash_ptr, conn->current_flash_offset, file_chunk_size); fflush(NULL);));

					conn->current_flash_offset += file_chunk_size;


					if (ret_code != 0) {
						safe_print(printf("Error: read_from_flash_for_http_file_download returned %d, conn->flash_ptr = 0x%x conn->current_flash_offset = %d file_chunk_size = %d\n", ret_code, conn->flash_ptr, conn->current_flash_offset, file_chunk_size); fflush(NULL););
					}
				} else {
					if (conn->file_is_actually_memory) {
						file_chunk_size =  MIN(HTTP_TX_BUF_SIZE, (conn->file_length - conn->data_sent));
						memmove((void *) conn->tx_buffer,(void*)(conn->memory_region_base + conn->current_mem_offset),file_chunk_size);
						conn->current_mem_offset += file_chunk_size;
					} else {
						f_read(&conn->file_handle, (void *) conn->tx_buffer, MIN(HTTP_TX_BUF_SIZE, (conn->file_length - conn->data_sent)), &file_chunk_size);
					}
				}
			}
			//safe_print(printf("after file read\n"));
		}

		tx_ptr = conn->tx_buffer;

		int http_chunk_try_count;

		while(chunk_sent < file_chunk_size)
		{

			http_chunk_try_count = 0;
			while (http_chunk_try_count < LINNUX_MAX_HTTP_CHUNK_RETRANSMIT_COUNT)
			{
				http_chunk_try_count++;

				//safe_print(printf("before send: conn->fd: %d tx_ptr:%d file_chunk_size:%d\n",conn->fd, tx_ptr, (int) file_chunk_size));
				result = send(conn->fd, (char *)tx_ptr, file_chunk_size, 0);
				//safe_print(printf("after send: conn->fd: %d tx_ptr:%d file_chunk_size:%d\n",conn->fd, tx_ptr,(int) file_chunk_size));

				/* Error - get out of here! */
				if (result < 0)
				{
					int e = t_errno(conn->fd);
					std::string timestamp_str = get_current_time_and_date_as_string();
					TrimSpaces(timestamp_str);
					d_dh(safe_print(printf("\n[%s][http_send_file] file send returned [%d], t_errno = [%d]; Retransmitting file chunk at offset [%d], attempt = [%d], HTTP connection [%d] \n", timestamp_str.c_str(),(int) result, (int) e, (int) conn->data_sent, (int) http_chunk_try_count, (int) conn->fd)););
				} else
				{
					break;
				}
			}


			if(result < 0)
			{
				std::string timestamp_str = get_current_time_and_date_as_string();
				TrimSpaces(timestamp_str);
				int e = t_errno(conn->fd);
				d_dh(safe_print(printf("\n[%s][http_send_file] file send returned [%d], t_errno = [%d], at file offset [%d],  tried [%d] TX  attempts, closing HTTP connection [%d]\n",
						timestamp_str.c_str(), (int) result,        (int) e,(int) conn->data_sent, (int) http_chunk_try_count, (int) conn->fd)););
				ALT_DEBUG_ASSERT(1);
				conn->state = RESET_HTTP;
				return result;
			}
			else
			{
				/*
				 * No errors, but the number of bytes sent might be less than we wanted.
				 */

				//safe_print(printf("conn->fd: %d chunk_sent:%d file_chunk_size:%d\n",conn->fd, chunk_sent,(int) file_chunk_size));
				conn->activity_time = alt_nticks();
				chunk_sent += result;
				conn->data_sent += result;
				tx_ptr += result;
				file_chunk_size -= result;
			}
		} /* while(chunk_sent < file_chunk_size) */
	} /* if(conn->data_sent < conn->file_length) */

	/*
	 * We managed to send all of the file contents to the IP stack successfully.
	 * At this point we can mark our connection info as complete.
	 */
	if(conn->data_sent >= conn->file_length)
	{
		conn->state = COMPLETE_HTTP;
		if ((conn->c_string_to_send_instead_of_file != ((char*) NULL)) &&  (conn->file_is_actually_a_c_string))
		{
			my_mem_free(conn->c_string_to_send_instead_of_file);
			conn->c_string_to_send_instead_of_file = (char*)NULL;
		}
	}

	return ret_code;
}

/*
 * http_send_file_header()
 *
 * Construct and send an HTTP header describing the now-opened file that is
 * about to be sent to the client.
 */
int http_send_file_header(http_conn* conn, const alt_u8* name, int code)
{
	int     result = 0, ret_code = 0;
	alt_u8* tx_wr_pos = conn->tx_buffer;
	fpos_t  end, start;
	const alt_u8* ext = (const alt_u8*)strchr((char *)name, '.');

	tx_wr_pos += sprintf((char *)tx_wr_pos, (const char *)HTTP_VERSION_STRING);
	switch(code)
	{
	/* HTTP Code: "200 OK\r\n" (we have opened the file successfully) */
	case HTTP_OK:
	{
		tx_wr_pos += sprintf((char *)tx_wr_pos, (const char *)HTTP_OK_STRING);
		break;
	}
	/* HTTP Code: "404 Not Found\r\n" (couldn't find requested file) */
	case HTTP_NOT_FOUND:
	{
		tx_wr_pos += sprintf((char *)tx_wr_pos, (const char *)HTTP_NOT_FOUND_STRING);
		break;
	}
	default:
	{
		d_dh(safe_print(fprintf(stderr, "[http_send_file_header] Invalid HTTP code: %d\n", code)););
		conn->state = RESET_HTTP;
		return -1;
		break;
	}
	}

	/* Handle the various content types */
	tx_wr_pos += sprintf((char *)tx_wr_pos, (const char *)HTTP_CONTENT_TYPE);

	if (conn->file_is_actually_a_c_string) {
		conn->file_length = strlen(conn->c_string_to_send_instead_of_file);
		d_dh(printf("CGI: conn->file_length = %d\n",conn->file_length););
		tx_wr_pos += sprintf((char *)tx_wr_pos, (const char *)HTTP_CONTENT_TYPE_HTML);
	} else
	{
		if ((!strcasecmp((char *)ext, ".html")) || (!strcasecmp((char *)ext, ".htm")))
		{
			tx_wr_pos += sprintf((char *)tx_wr_pos, HTTP_CONTENT_TYPE_HTML);
		}
		else if (!strcasecmp((char *)ext, ".jpg"))
		{
			tx_wr_pos += sprintf((char *)tx_wr_pos, HTTP_CONTENT_TYPE_JPG);
		}
		else if (!strcasecmp((char *)ext, ".gif"))
		{
			tx_wr_pos += sprintf((char *)tx_wr_pos, HTTP_CONTENT_TYPE_GIF);
		}
		else if (!strcasecmp((char *)ext, ".png"))
		{
			tx_wr_pos += sprintf((char *)tx_wr_pos, HTTP_CONTENT_TYPE_PNG);
		}
		else if (!strcasecmp((char *)ext, ".js"))
		{
			tx_wr_pos += sprintf((char *)tx_wr_pos, HTTP_CONTENT_TYPE_JS);
		}
		else if (!strcasecmp((char *)ext, ".css"))
		{
			tx_wr_pos += sprintf((char *)tx_wr_pos, HTTP_CONTENT_TYPE_CSS);
		}
		else if (!strcasecmp((char *)ext, ".swf"))
		{
			tx_wr_pos += sprintf((char *)tx_wr_pos, HTTP_CONTENT_TYPE_SWF);
		}
		else if (!strcasecmp((char *)ext, ".ico"))
		{
			tx_wr_pos += sprintf((char *)tx_wr_pos, HTTP_CONTENT_TYPE_ICO);
		}
		else if (!strcasecmp((char *)ext, ".jnlp"))
		{
			tx_wr_pos += sprintf((char *)tx_wr_pos, HTTP_CONTENT_TYPE_JNLP);
		}
		else
		{
			//assume it is a text file and send it as text
			tx_wr_pos += sprintf((char *)tx_wr_pos, HTTP_CONTENT_TYPE_TEXT);

			//safe_print(fprintf(stderr, "[http_send_file] Unknown content type: \"%s\"\n", ext));
			//conn->state = RESET_HTTP;
			//ALT_DEBUG_ASSERT(1);
			//return -1;
		}
		if (conn->we_are_actually_doing_a_bw_check) {
			conn->file_length = INT_MAX - 2;
		} else {
			if (conn ->file_is_actually_flash) {
               #if HTTP_SERVER_SUPPORT_FLASH_MEMORY_DOWNLOAD_AS_FILE
				conn->file_length = get_flash_length_for_http_file_download(conn->flash_ptr);
			   #else
								conn->file_length =  0; //we should never get here
			   #endif
				d_dh(safe_print(printf( "Flash region length: %d\n", conn->file_length)));
				fflush(NULL);
			} else {

				if (conn ->file_is_actually_memory) {
					conn->file_length = conn->memory_region_length;
					d_dh(safe_print(printf( "memory region length: %u\n", conn->file_length)));
					fflush(NULL);
				} else  {
					conn->file_length = f_size(&conn->file_handle);
				}
			}
		  }
		}
		/* Get the file length and stash it into our connection info */
		//fseek(conn->file_handle, 0, SEEK_END);
		//fgetpos(conn->file_handle, &end);
		//fseek(conn->file_handle, 0, SEEK_SET);
		//fgetpos(conn->file_handle, &start);
		//conn->file_length = end - start;


		/* "Content-Length: <length bytes>\r\n" */
		tx_wr_pos += sprintf((char *)tx_wr_pos,(const char *) HTTP_CONTENT_LENGTH);
		tx_wr_pos += sprintf((char *)tx_wr_pos, "%d\r\n", conn->file_length);

		/*
		 * 'close' will be set during header parsing if the client either specified
		 * that they wanted the connection closed ("Connection: Close"), or if they
		 * are using an HTTP version prior to 1.1. Otherwise, we will keep the
		 * connection alive.
		 *
		 * We send a specified number of files in a single keep-alive connection,
		 * we'll also close the connection. It's best to be polite and tell the client,
		 * though.
		 */
		if(!conn->keep_alive_count)
		{
			conn->close = 1;
		}

		if(conn->close)
		{
			tx_wr_pos += sprintf((char *)tx_wr_pos, (const char *)HTTP_CLOSE);
		}
		else
		{
			tx_wr_pos += sprintf((char *)tx_wr_pos, (const char *)HTTP_KEEP_ALIVE);
		}

		/* "\r\n" (two \r\n's in a row means end of headers */
		tx_wr_pos += sprintf((char *)tx_wr_pos, (const char *)HTTP_CR_LF);

		/* Send the reply header */
		result = send(conn->fd, (char *)conn->tx_buffer, (tx_wr_pos - conn->tx_buffer),0);

		if(result < 0)
		{
			d_dh(safe_print(fprintf(stderr, "[http_send_file] header send returned %d\n", result)););
			conn->state = RESET_HTTP;
			return result;
		}
		else
		{
			conn->activity_time = alt_nticks();
		}
		//safe_print(printf("Send File Header returned with code %d\n",ret_code));
		return ret_code;
	}


	/*
	 * http_find_file()
	 *
	 * Try to find the file requested. If nothing is requested you get /index.html
	 * If we can't find it, send a "404 - Not found" message.
	 */
	int http_find_file(http_conn* conn)
	{
		alt_u8  filename[HTTP_URI_SIZE+100];
		std::string cgi_str;
		struct cap         captures[10];
		int     ret_code = 0;
		conn->we_are_actually_doing_a_bw_check = 0;
		conn->file_is_actually_flash = 0;
		conn->file_is_actually_memory = 0;

		cgi_str = handle_cgi_query_str(std::string((char *)conn->uri));

		if (cgi_str.length() == 0) {
			conn->c_string_to_send_instead_of_file = NULL;
		} else {
			conn->c_string_to_send_instead_of_file = my_mem_strdup(cgi_str.c_str());
		}

		if (conn->c_string_to_send_instead_of_file == NULL)
		{
			conn->file_is_actually_a_c_string=0;
			strncpy( (char *)filename, BASE_DIRECTORY_PATH, strlen(BASE_DIRECTORY_PATH));

			/* URI of "/" means get the default, usually index.html */
			if ( (conn->uri[0] == '/') && (conn->uri[1] == '\0') )
			{
				strcpy(((char *)filename)+strlen(BASE_DIRECTORY_PATH), HTTP_DEFAULT_FILE);
			}
			else
			{
				strcpy( ((char *)filename)+strlen(BASE_DIRECTORY_PATH), (const char *) conn->uri);
			}

			if (!strcmp((char *)filename,"/bw_check")) {
				conn->we_are_actually_doing_a_bw_check = 1;
				conn->file_is_currently_open = 1;
				conn->file_is_actually_flash = 0;
				conn->file_is_actually_memory = 0;

				safe_print(printf("Doing a bandwidth check....\n"));
				conn->file_is_actually_a_c_string=0; /*used to "trick" conn to send a string instead of a file */
				conn->c_string_to_send_instead_of_file = NULL;
				ret_code = http_send_file_header(conn, filename, HTTP_OK);
				return ret_code;
			}

					#if HTTP_SERVER_SUPPORT_FLASH_MEMORY_DOWNLOAD_AS_FILE

									if (slre_match(&flash_match_slre, (char *)filename, strlen(filename), captures)) {
										std::string flash_index_str;
										flash_index_str.append(captures[1].ptr,captures[1].len);
										int flash_index;
										flash_index = atoi(flash_index_str.c_str());
										conn->file_is_currently_open = 1;
										conn->file_is_actually_flash = 1;
										conn->current_flash_offset = 0;
										conn->file_is_actually_a_c_string=0; /*used to "trick" conn to send a string instead of a file */
										conn->file_is_actually_memory = 0;
										conn->c_string_to_send_instead_of_file = NULL;
										int error;
										conn->flash_ptr = open_external_flash_for_http_file_download(flash_index,&error);
										if (conn->flash_ptr == NULL) {
											safe_print(printf( "Flash ptr returned null on open, error is %d!\n",error));
											goto send_404;
										}
										ret_code = http_send_file_header(conn, filename, HTTP_OK);
										return ret_code;
									}
					#endif
					#if  HTTP_SERVER_SUPPORT_MEMORY_DOWNLOAD_AS_FILE
									if (slre_match(&mem_match_slre, (char *)filename, strlen(filename), captures)) {
										conn->file_is_currently_open = 1;
										conn->file_is_actually_flash = 0;
										conn->current_flash_offset = 0;
										conn->file_is_actually_a_c_string=0;
										conn->file_is_actually_memory = 1;
										std::string mem_index_str;
										mem_index_str.append(captures[1].ptr,captures[1].len);
										conn->memory_region_index =  atoi(mem_index_str.c_str());
										int res = get_mem_region_data_for_http_file_download(conn->memory_region_index,&(conn->memory_region_base),&(conn->memory_region_length));
										if (!res) {
											safe_print(printf( "Error while sending memory range %d, error is %d!\n",conn->memory_region_index,res));
											goto send_404;
										}
										conn->current_mem_offset = 0;
										conn->c_string_to_send_instead_of_file = NULL;
										ret_code = http_send_file_header(conn, filename, HTTP_OK);
										return ret_code;
									}

					#endif

					/* Try to open the file */
					//safe_print(printf("\nFetching file:  %s.\n", filename ));
					//conn->file_handle = fopen(filename, "r");
					conn->file_is_currently_open = 0;
					conn->file_is_actually_flash = 0;
					conn->file_is_actually_memory = 0;

					FRESULT fopen_result = f_open(&conn->file_handle, (const TCHAR*)filename, FA_OPEN_EXISTING | FA_READ);
					//safe_print(printf("File open result: %d  Filename: %s\n", fopen_result, filename));

					if (fopen_result == FR_OK)
					{
						/* We've found the requested file; send its header and move on. */
											conn->file_is_currently_open = 1;
											//safe_print(printf("Sending file: %s to requester via HTTP\n",filename));
											conn->file_is_actually_a_c_string=0; /*used to "trick" conn to send a string instead of a file */
											conn->file_is_actually_flash = 0;
											conn->file_is_actually_memory = 0;
											conn->c_string_to_send_instead_of_file = NULL;
											ret_code = http_send_file_header(conn, filename, HTTP_OK);
											return ret_code;

					}



		} else
		{
			conn->file_is_currently_open = 1;
			conn->file_is_actually_a_c_string=1; /*used to "trick" conn to send a string instead of a file */
			conn->file_is_actually_flash = 0;
			conn->file_is_actually_memory = 0;
			//safe_print(printf("String to print from CGI is: [%s]\n",conn->c_string_to_send_instead_of_file));
			ret_code = http_send_file_header(conn, filename, HTTP_OK);
			return ret_code;

			//safe_print(printf("Request Handled by CGI, with retcode: %d\n",ret_code));
			//cgi handled it return OK
		}


		/* Can't find the requested file? Try for a 404-page. */
send_404:
	    strcpy(((char *)filename), BASE_DIRECTORY_PATH);
	    strcpy(((char *)filename)+strlen(BASE_DIRECTORY_PATH), HTTP_NOT_FOUND_FILE);
	    //conn->file_handle = fopen(filename, "r");
	    FRESULT fopen_result1;
	    fopen_result1 = f_open(&conn->file_handle, ((char *)filename), FA_OPEN_EXISTING | FA_READ);
	    /* We located the specified "404: Not-Found" page */
	    if (fopen_result1 != FR_OK)
	    {
	    	ALT_DEBUG_ASSERT(fd != NULL);
	    	conn->file_is_currently_open = 1;
	    	ret_code = http_send_file_header(conn, filename, HTTP_NOT_FOUND);
	    }
	    /* Can't find the 404 page: This likely means there is no file system */
	    else
	    {
	    	d_dh(safe_print(fprintf(stderr, "Can't open the 404 File Not Found error page.\n")););
	    	d_dh(safe_print(fprintf(stderr, "Have you programmed the filing system into flash?\n")););
	    	send(conn->fd,(char*)canned_http_response,strlen((const char *)canned_http_response),0);
	    	f_close(&conn->file_handle);
	    	conn->file_is_currently_open = 0;
	    	conn->state = RESET_HTTP;
	    	return -1;
	    }
		return ret_code;
	}


	/*
	 * http_send_file()
	 *
	 * This function sends re-directs to either program_flash.html or
	 * reset_sytem.html.
	 */

	void http_send_redirect( alt_u8 redirect[256] )
	{
		safe_print(printf( ("Don't do anything....for now.\n")));
	}

	/*
	 * http_handle_post()
	 *
	 * Process the post request and take the appropriate action.
	 */
	int http_handle_post(http_conn* conn)
	{
		alt_u8* tx_wr_pos = conn->tx_buffer;
		int ret_code = 0;
		struct upload_buf_struct *upload_buffer = &upload_buf;
		printf("in handle post 1\n");
		tx_wr_pos += sprintf((char*)tx_wr_pos, HTTP_VERSION_STRING);
		tx_wr_pos += sprintf((char*)tx_wr_pos, HTTP_NO_CONTENT_STRING);
		tx_wr_pos += sprintf((char*)tx_wr_pos, HTTP_CLOSE);
		tx_wr_pos += sprintf((char*)tx_wr_pos, HTTP_END_OF_HEADERS);

		//if (!strcmp(conn->uri, mapping.name))
		//{
		//	send(conn->fd, conn->tx_buffer, (tx_wr_pos - conn->tx_buffer), 0);
		//	conn->state = CLOSE_HTTP;
		//	mapping.func();
		//}


		//else if (!strcmp(conn->uri, upload_field.name))
		//	{
		d_dh(safe_print(printf("in handle post 2\n")););
		conn->file_upload = 1;
		upload_buffer->rd_pos = upload_buffer->wr_pos = (alt_u8*) upload_buffer->buffer;
		memset(upload_buffer->rd_pos, '\0', conn->content_length );
		d_dh(safe_print(printf("in handle post 3\n")););
		//upload_field.func(conn);
		d_dh(safe_print(printf("in handle post 4\n")););
		//	}

#ifdef RECONFIG_REQUEST_PIO_NAME
		else if (!strcmp(conn->uri, reset_field.name))
		{
			/* Close the socket. */
			send(conn->fd, conn->tx_buffer, (tx_wr_pos - conn->tx_buffer), 0);
			reset_field.func();
		}
#endif
		return ret_code;
	}


	/*
	 * http_prepare_response()
	 *
	 * Service the various HTTP commands, calling the relevant subroutine.
	 * We only handle GET and POST.
	 */
	int http_prepare_response(http_conn* conn)
	{
		int ret_code = 0;

		switch (conn->action)
		{
		case GET:
		{
			/* Find file from uri */
			//safe_print(printf("http_prepare_response 1\n"));
			ret_code = http_find_file(conn);
			break;
		}
		case POST:
		{
			/* Handle POSTs. */
			//	safe_print(printf("http_prepare_response 2\n"));
			ret_code = http_handle_post(conn);
			//	safe_print(printf("http_prepare_response 3\n"));
			break;
		}
		default:
		{
			break;
		}
		} /* switch (conn->action) */

		return ret_code;
	}

	/*
	 * http_handle_receive()
	 *
	 * Work out what the request we received was, and handle it.
	 */
	void http_handle_receive(http_conn* conn, int http_instance)
	{
		int data_used, rx_code;

		if (conn->state == READY_HTTP)
		{
			rx_code = recv(conn->fd, (char *)conn->rx_wr_pos,
					(HTTP_RX_BUF_SIZE - (conn->rx_wr_pos - conn->rx_buffer) -1),
					0);

			/*
			 * If a valid data received, take care of buffer pointer & string
			 * termination and move on. Otherwise, we need to return and wait for more
			 * data to arrive (until we time out).
			 */
			if(rx_code > 0)
			{
				/* Increment rx_wr_pos by the amount of data received. */
				conn->rx_wr_pos += rx_code;
				/* Place a zero just after the data received to serve as a terminator. */
				*(conn->rx_wr_pos+1) = 0;

				if(strstr((char *)conn->rx_buffer, HTTP_END_OF_HEADERS))
				{
					conn->state = PROCESS_HTTP;
				}
				/* If the connection is a file upload, skip right to DATA_HTTP.*/
				if(conn->file_upload == 1)
				{
					conn->state = DATA_HTTP;
				}
			}
		}

		if(conn->state == PROCESS_HTTP)
		{
			/*
			 * If we (think) we have valid headers, keep the connection alive a bit
			 * longer.
			 */
			conn->activity_time = alt_nticks();

			/*
			 * Attempt to process the fundamentals of the HTTP request. We may
			 * error out and reset if the request wasn't complete, or something
			 * was asked from us that we can't handle.
			 */
			if (http_process_request(conn))
			{
				d_dh(safe_print(fprintf(stderr, "[http_handle_receive] http_process_request failed\n")););
				conn->state = RESET_HTTP;
				http_manage_connection(conn, http_instance);
			}

			/*
			 * Step through the headers to see if there is any other useful
			 * information about our pending transaction to extract. After that's
			 * done, send some headers of our own back to let the client know
			 * what's happening. Also, once all in-coming headers have been parsed
			 * we can manage our RX buffer to prepare for the next in-coming
			 * connection.
			 */
			while(conn->state == PROCESS_HTTP)
			{
				if(http_read_line(conn))
				{
					d_dh(safe_print(fprintf(stderr, "[http_handle_receive] error reading headers\n")););
					conn->state = RESET_HTTP;
					http_manage_connection(conn, http_instance);
					break;
				}
				if(http_process_headers(conn))
				{
					if( (conn->rx_rd_pos = (alt_u8 *)strstr((char *)conn->rx_rd_pos, HTTP_CR_LF)) )
					{
						conn->rx_rd_pos += 2;
						conn->state = DATA_HTTP;
						conn->activity_time = alt_nticks();
					}
					else
					{
						d_dh(safe_print(fprintf(stderr, "[http_handle_receive] Can't find end of headers!\n")););
						conn->state = RESET_HTTP;
						http_manage_connection(conn, http_instance);
						break;
					}
				}
			} /* while(conn->state == PROCESS_HTTP) */

			if( http_prepare_response(conn) )
			{
				conn->state = RESET_HTTP;
				d_dh(safe_print(fprintf(stderr, "[http_handle_receive] Error preparing response\n")););
				http_manage_connection(conn, http_instance);
			}

			/*
			 * Manage RX Buffer: Slide any un-read data in our input buffer
			 * down over previously-read data that can now be overwritten, and
			 * zero-out any bytes in question at the top of our new un-read space.
			 */
			if(conn->rx_rd_pos > (conn->rx_buffer + HTTP_RX_BUF_SIZE))
			{
				conn->rx_rd_pos = conn->rx_buffer + HTTP_RX_BUF_SIZE;
			}

			data_used = conn->rx_rd_pos - conn->rx_buffer;
			memmove(conn->rx_buffer,conn->rx_rd_pos,conn->rx_wr_pos-conn->rx_rd_pos);
			conn->rx_rd_pos = conn->rx_buffer;
			conn->rx_wr_pos -= data_used;
			memset(conn->rx_wr_pos, 0, data_used);
		}

		if (conn->state == DATA_HTTP && conn->file_upload == 1 )
		{
			/* Jump to the file_upload() function....process more received data. */
			//upload_field.func(conn);
		}
	}

	/*
	 * http_handle_transmit()
	 *
	 * Transmit a chunk of a file in an active HTTP connection. This routine
	 * will be called from the thread's main loop when ever the socket is in
	 * the 'DATA_HTTP' state and the socket is marked as available for writing (free
	 * buffer space).
	 */
	void http_handle_transmit(http_conn* conn, int http_instance)
	{
		if( http_send_file_chunk(conn) )
		{
			d_dh(safe_print(fprintf(stderr, "[http_handle_transmit]: Send file chunk failed\n")););
		}
	}

	/*
	 * WStask()
	 *
	 * This MicroC/OS-II thread spins forever after first establishing a listening
	 * socket for HTTP connections, binding them, and listening. Once setup,
	 * it perpetually waits for incoming data to either a listening socket, or
	 * (if there is an active connection), an HTTP data socket. When data arrives,
	 * the approrpriate routine is called to either accept/reject a connection
	 * request, or process incoming data.
	 *
	 * This routine calls "select()" to determine which sockets are ready for
	 * reading or writing. This, in conjunction with the use of non-blocking
	 * send() and recv() calls and sending responses broken up into chunks lets
	 * us handle multiple active HTTP requests.
	 */

	int http_is_in_a_safe_state = 0;

	void WSTask(void *dummy)
	{
		int     i, fd_listen, max_socket;
		struct  sockaddr_in addr;
		struct  timeval select_timeout;
		fd_set  readfds, writefds;
		static  http_conn     conn[HTTP_NUM_CONNECTIONS];
		int errornum;

		gen_random(constant_bw_check_str,HTTP_TX_BUF_SIZE-1);
		bw_check_strlen =  MIN(strlen(constant_bw_check_str),HTTP_TX_BUF_SIZE-1);


		if (!slre_compile(&flash_match_slre, "flash([0123456789]+).rbf")) {
			safe_print(printf("Error compiling RE: %s\n", flash_match_slre.err_str));
		}

		if (!slre_compile(&mem_match_slre, "mem([0123456789]+).rbf")) {
					safe_print(printf("Error compiling RE: %s\n", flash_match_slre.err_str));
		}

		re_init_http_server:
		http_is_in_a_safe_state = 1;
		safe_print(printf("[HTTP]HTTP is in a safe state!\n"));
		while (put_http_in_a_safe_state) {
			MyOSTimeDlyHMSM(0,0,LINNUX_NETWORK_SAFE_STATE_DELAY_IN_SECONDS,0);
		}
		http_is_in_a_safe_state = 0;
		safe_print(printf("[HTTP]HTTP is functional\n"));
		/*
		 * Sockets primer...
		 * The socket() call creates an endpoint for TCP of UDP communication. It
		 * returns a descriptor (similar to a file descriptor) that we call fd_listen,
		 * or, "the socket we're listening on for connection requests" in our web
		 * server example.
		 */

		if ((fd_listen = socket(AF_INET, SOCK_STREAM, 0)) < 0)
		{

			die_with_error("[WSTask] Listening socket creation failed");
		}

		int reuse= 1;
		if ((errornum = (int) t_setsockopt(fd_listen, SOL_SOCKET, SO_REUSEADDR, &reuse,  1))== -1)
		{
			safe_print(printf("[WSTask] setsockopt() to REUSE failed\n"));
		}

		/*
		 * Sockets primer, continued...
		 * Calling bind() associates a socket created with socket() to a particular IP
		 * port and incoming address. In this case we're binding to HTTP_PORT and to
		 * INADDR_ANY address (allowing anyone to connect to us. Bind may fail for
		 * various reasons, but the most common is that some other socket is bound to
		 * the port we're requesting.
		 */
		addr.sin_family = AF_INET;
		addr.sin_port = htons(HTTP_PORT);
		addr.sin_addr.s_addr = INADDR_ANY;

		if ((bind(fd_listen,(struct sockaddr *)&addr,sizeof(addr))) < 0)
		{

			die_with_error("[WSTask] Bind failed");
		}

		/*
		 * Sockets primer, continued...
		 * The listen socket is a socket which is waiting for incoming connections.
		 * This call to listen will block (i.e. not return) until someone tries to
		 * connect to this port.
		 */
		if ((listen(fd_listen,1)) < 0)
		{

			die_with_error("[WSTask] Listen failed");
		}

		/*
		 * At this point we have successfully created a socket which is listening
		 * on HTTP_PORT for connection requests from any remote address.
		 */
		for(i=0; i<HTTP_NUM_CONNECTIONS; i++)
		{

			http_reset_connection(&conn[i], i);

		}

		int num_chunks_counted = 0;

		while(1)
		{
			/*
			 * The select() call below tells the stack to return  from this call
			 * when any of the events we have expressed an interest in happen (it
			 * blocks until our call to select() is satisfied).
			 *
			 * In the call below we're only interested in either someone trying to
			 * connect to us, or when an existing (active) connection has new receive
			 * data, or when an existing connection is in the "DATA_HTTP" state meaning that
			 * we're in the middle of processing an HTTP request. If none of these
			 * conditions are satisfied, select() blocks until a timeout specified
			 * in the select_timeout struct.
			 *
			 * The sockets we're interested in (for RX) are passed in inside the
			 * readfds parameter, while those we're interested in for TX as passed in
			 * inside the writefds parameter. The format of readfds and writefds is
			 * implementation dependant, hence there are standard macros for
			 * setting/reading the values:
			 *
			 *   FD_ZERO  - Zero's out the sockets we're interested in
			 *   FD_SET   - Adds a socket to those we're interested in
			 *   FD_ISSET - Tests whether the chosen socket is set
			 */
			FD_ZERO(&readfds);
			FD_ZERO(&writefds);
			FD_SET(fd_listen, &readfds);

			max_socket = fd_listen+1;

			for(i=0; i<HTTP_NUM_CONNECTIONS; i++)
			{
				if (put_http_in_a_safe_state) {
					goto re_init_http_server;
				}
				if (conn[i].fd != -1)
				{
					/* We're interested in reading any of our active sockets */

					FD_SET(conn[i].fd, &readfds);

					/*
					 * We're interested in writing to any of our active sockets in the DATA_HTTP
					 * state
					 */
					if(conn[i].state == DATA_HTTP)
					{
						FD_SET(conn[i].fd, &writefds);
					}

					/*
					 * select() must be called with the maximum number of sockets to look
					 * through. This will be the largest socket number + 1 (since we start
					 * at zero).
					 */
					if (max_socket <= conn[i].fd)
					{
						max_socket = conn[i].fd+1;
					}
				}
			}

			/*
			 * Set timeout value for select. This must be reset for each select()
			 * call.
			 */
			/*
			select_timeout.tv_sec = 0;
			select_timeout.tv_usec = 100000;

			select(max_socket, &readfds, &writefds, NULL, &select_timeout);
			*/
			t_select(&readfds, &writefds, NULL, HTTP_T_SELECT_IN_SYSTEM_TICKS);
			/*
			 * If fd_listen (the listening socket we originally created in this thread
			 * is "set" in readfds, then we have an incoming connection request.
			 * We'll call a routine to explicitly accept or deny the incoming connection
			 * request.
			 */

			if (put_http_in_a_safe_state) {
				goto re_init_http_server;
			}

			HTTP_ACCEPT_RTSTATUS http_accept_result;
			if (FD_ISSET(fd_listen, &readfds))
			{
				http_accept_result=http_handle_accept(fd_listen, conn);
				if (put_http_in_a_safe_state) {
					goto re_init_http_server;
				}
				if (http_accept_result == HTTP_ACCEPT_RTSTATUS_ACCEPT_FAILED)
				{
					safe_print(printf("http_handle_accept error. Gonna wait a while and then restart...\n"));
					MyOSTimeDlyHMSM(0,0,LINNUX_NETWORK_RECUPERATION_DELAY_IN_SECONDS,0);
					goto re_init_http_server;
				}

			}

			/*
			 * If http_handle_accept() accepts the connection, it creates *another*
			 * socket for sending/receiving data. This socket is independant of the
			 * listening socket we created above. This socket's descriptor is stored
			 * in conn[i].fd. Therefore if conn[i].fd is set in readfs, we have
			 * incoming data for our HTTP server, and we call our receive routine
			 * to process it. Likewise, if conn[i].fd is set in writefds, we have
			 * an open connection that is *capable* of being written to.
			 */


			if (tcp_ip_services_to_shutdown &  LINNUX_TCPIP_SHUTDOWN_HTTP)
			{
				safe_print(printf("\n\nHTTP: shutting down all HTTP sockets!\n\n"));

				for(i=0; i<HTTP_NUM_CONNECTIONS; i++)
				{
					if (conn[i].fd != -1)
					{
						conn[i].state = RESET_HTTP;
						t_shutdown(conn[i].fd,2);//shutdown both read and write
					}
				}
				tcp_ip_services_to_shutdown = (tcp_ip_services_to_shutdown & (~LINNUX_TCPIP_SHUTDOWN_HTTP));
			}


			int num_active_connections;
			num_active_connections = 0;

			for(i=0; i<HTTP_NUM_CONNECTIONS; i++)
			{
				if (put_http_in_a_safe_state) {
					goto re_init_http_server;
				}
				if (conn[i].fd != -1)
				{
					num_active_connections++;

					if(FD_ISSET(conn[i].fd,&readfds))
					{
						if (put_http_in_a_safe_state) {
							goto re_init_http_server;
						}
						http_handle_receive(&conn[i], i);
					}

					if(FD_ISSET(conn[i].fd,&writefds))
					{
						if (put_http_in_a_safe_state) {
							goto re_init_http_server;
						}
						http_handle_transmit(&conn[i], i);
					}
					if (put_http_in_a_safe_state) {
						goto re_init_http_server;
					}
					http_manage_connection(&conn[i], i);
				}
			}

			MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MINIMAL_PROCESS_DLY_MS); //delay a little bit to give lower priority processes a chance to run

			if (num_active_connections == 0)
			{
				MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MEDIUM_PROCESS_DLY_MS); //delay a little bit to give lower priority processes a chance to run
			} else
			{
				num_chunks_counted++;
				if ((num_chunks_counted % LINNUX_HTTP_NUM_CHUNKS_TO_COUNT_BEFORE_CEDING_CONTROL) == 0)
				{
					MyOSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_MINIMAL_PROCESS_DLY_MS); //delay a little bit to give lower priority processes a chance to run
				}
			}
		} /* while(1) */
	}
	/******************************************************************************
	 *                                                                             *
	 * License Agreement                                                           *
	 *                                                                             *
	 * Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
	 * All rights reserved.                                                        *
	 *                                                                             *
	 * Permission is hereby granted, free of charge, to any person obtaining a     *
	 * copy of this software and associated documentation files (the "Software"),  *
	 * to deal in the Software without restriction, including without limitation   *
	 * the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
	 * and/or sell copies of the Software, and to permit persons to whom the       *
	 * Software is furnished to do so, subject to the following conditions:        *
	 *                                                                             *
	 * The above copyright notice and this permission notice shall be included in  *
	 * all copies or substantial portions of the Software.                         *
	 *                                                                             *
	 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
	 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
	 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
	 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
	 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
	 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
	 * DEALINGS IN THE SOFTWARE.                                                   *
	 *                                                                             *
	 * This agreement shall be governed in all respects by the laws of the State   *
	 * of California and by the laws of the United States of America.              *
	 * Altera does not recommend, suggest or require that this reference design    *
	 * file be used in conjunction or combination with any other product.          *
	 ******************************************************************************/
