// Copyright (c) 2014 Cesanta Software Limited
// All rights reserved
//
// This library is dual-licensed: you can redistribute it and/or modify
// it under the terms of the GNU General Public License version 2 as
// published by the Free Software Foundation. For the terms of this
// license, see <http://www.gnu.org/licenses/>.
//
// You are free to use this library under the terms of the GNU General
// Public License, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// Alternatively, you can license this library under a commercial
// license, as set out in <http://cesanta.com/>.

#ifndef NS_SKELETON_HEADER_INCLUDED
#define NS_SKELETON_HEADER_INCLUDED

#define NS_SKELETON_VERSION "1.0"

#include <sys/types.h>
#include <sys/stat.h>
#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <unistd.h>
#include "ipport.h"
#include "libport.h"
#include "osport.h"
#include "tcpport.h"
#include "net.h"
#include <alt_iniche_dev.h>
#define closesocket(x) close(x)
#define to64(x) strtol(x, NULL, 10)
typedef int sock_t;
typedef int socklen_t;


typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int uint32;
typedef signed char sint8;
typedef signed short sint16;
typedef signed int sint32;

#ifdef NS_ENABLE_DEBUG
#define DBG(x) do { printf("%-20s ", __func__); printf x; putchar('\n'); \
  fflush(stdout); } while(0)
#else
#define DBG(x)
#endif

#define ARRAY_SIZE(array) (sizeof(array) / sizeof(array[0]))

#ifdef NS_ENABLE_SSL
#ifdef __APPLE__
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#endif
#include <openssl/ssl.h>
#else
typedef void *SSL;
typedef void *SSL_CTX;
#endif

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

union socket_address {
  struct sockaddr sa;
  struct sockaddr_in sin;
#ifdef NS_ENABLE_IPV6
  struct sockaddr_in6 sin6;
#endif
};

struct iobuf {
  char *buf;
  int len;
  int size;
};

void iobuf_init(struct iobuf *, int initial_size);
void iobuf_free(struct iobuf *);
int iobuf_append(struct iobuf *, const void *data, int data_size);
void iobuf_remove(struct iobuf *, int data_size);

struct nsk_connection;
enum nsk_event { NS_POLL, NS_ACCEPT, NS_CONNECT, NS_RECV, NS_SEND, NS_CLOSE };
typedef void (*nsk_callback_t)(struct nsk_connection *, enum nsk_event, void *);

struct nsk_server {
  void *server_data;
  union socket_address listening_sa;
  sock_t listening_sock;
  struct nsk_connection *active_connections;
  nsk_callback_t callback;
  SSL_CTX *ssl_ctx;
  SSL_CTX *client_ssl_ctx;
  sock_t ctl[2];
};

struct nsk_connection {
  struct nsk_connection *prev, *next;
  struct nsk_server *server;
  void *connection_data;
  time_t last_io_time;
  sock_t sock;
  struct iobuf recv_iobuf;
  struct iobuf send_iobuf;
  SSL *ssl;
  unsigned int flags;
#define NSF_FINISHED_SENDING_DATA   (1 << 0)
#define NSF_BUFFER_BUT_DONT_SEND    (1 << 1)
#define NSF_SSL_HANDSHAKE_DONE      (1 << 2)
#define NSF_CONNECTING              (1 << 3)
#define NSF_CLOSE_IMMEDIATELY       (1 << 4)
#define NSF_ACCEPTED                (1 << 5)
#define NSF_USER_1                  (1 << 6)
#define NSF_USER_2                  (1 << 7)
#define NSF_USER_3                  (1 << 8)
#define NSF_USER_4                  (1 << 9)
};

void nsk_server_init(struct nsk_server *, void *server_data, nsk_callback_t);
void nsk_server_free(struct nsk_server *);
int nsk_server_poll(struct nsk_server *, int milli);
void nsk_server_wakeup(struct nsk_server *);
void nsk_iterate(struct nsk_server *, nsk_callback_t cb, void *param);
struct nsk_connection *nsk_add_sock(struct nsk_server *, sock_t sock, void *p);

int nsk_bind(struct nsk_server *, const char *addr);
int nsk_set_ssl_cert(struct nsk_server *, const char *ssl_cert);
struct nsk_connection *nsk_connect(struct nsk_server *, const char *host,
                                 int port, int ssl, void *connection_param);

int nsk_send(struct nsk_connection *, const void *buf, int len);
int nsk_printf(struct nsk_connection *, const char *fmt, ...);
int nsk_vprintf(struct nsk_connection *, const char *fmt, va_list ap);
int nsk_avprintf(char **buf, size_t size, const char *fmt, va_list ap);

// Utility functions
void *nsk_start_thread(void *(*f)(void *), void *p);
int nsk_socketpair(sock_t [2]);
void nsk_set_close_on_exec(sock_t);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // NS_SKELETON_HEADER_INCLUDED
