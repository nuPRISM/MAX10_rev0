#ifndef TEST_MANAGEMENT_TASKS_H_
#define TEST_MANAGEMENT_TASKS_H_
#define NUM_UDP_STREAMING_STREAMS (4)
/* Nichestack definitions */
#include "ipport.h"
#include "libport.h"
#include "osport.h"
#include "bsdsock.h"

#include "alt_types.h"

#define STREAM_SERVER_PUBLIC_PORT	(8181)

//
// STRING DEFINITIONS
//
#define BEGIN_STR "<BEGIN>"
#define BEGIN_STR_SIZE (sizeof BEGIN_STR) - 1
#define BUSY_STR "<BUSY>"
#define BUSY_STR_SIZE (sizeof BUSY_STR) - 1
#define END_STR "<END>"
#define END_STR_SIZE (sizeof END_STR) - 1
#define REQUEST_STR "<REQUEST "
#define REQUEST_STR_SIZE (sizeof REQUEST_STR) - 1
#define ACCEPT_STR "<ACCEPT>"
#define ACCEPT_STR_SIZE (sizeof ACCEPT_STR) - 1
#define DENY_STR "<DENY>"
#define DENY_STR_SIZE (sizeof DENY_STR) - 1
#define START_STR "<START "
#define START_STR_SIZE (sizeof START_STR) - 1
#define START_ACK_STR "<START>"
#define START_ACK_STR_SIZE (sizeof START_ACK_STR) - 1
#define STOP_STR "<STOP>"
#define STOP_STR_SIZE (sizeof STOP_STR) - 1
#define RELEASE_STR "<RELEASE>"
#define RELEASE_STR_SIZE (sizeof RELEASE_STR) - 1
#define HUH_STR "<HUH>"
#define HUH_STR_SIZE (sizeof HUH_STR) - 1

//
// SERVER STATE DEFINITIONS
//
#define BEGIN_STATE			(0)
#define ESTABLISHED_STATE	(1)
#define START_STATE			(2)

extern OS_EVENT *stream_client_Mbox;
extern OS_EVENT *client_request_Mbox;

extern struct inet_taskinfo the_stream_server_task;
extern struct inet_taskinfo the_stream_client_task;

extern void stream_server_task(void *task_data);
extern void stream_client_task(void *task_data);
extern int tx_command(int fd, char *buffer, int length, int flags);

extern volatile int client_session_fd[];

typedef volatile struct {
	volatile alt_u32 ip_address;		// HBO
	volatile alt_u32 packet_length;
	volatile struct GenericIO pio;
	volatile alt_u32 streamer_index; // index of the UDP streaming chain we want to use
} client_request;

#endif /*TEST_MANAGEMENT_TASKS_H_*/
