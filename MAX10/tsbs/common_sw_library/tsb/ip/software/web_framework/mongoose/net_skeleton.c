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

#include "net_skeleton.h"

#ifndef NS_MALLOC
#define NS_MALLOC malloc
#endif

#ifndef NS_REALLOC
#define NS_REALLOC realloc
#endif

#ifndef NS_FREE
#define NS_FREE free
#endif

#ifndef IOBUF_RESIZE_MULTIPLIER
#define IOBUF_RESIZE_MULTIPLIER 2.0
#endif

void iobuf_init(struct iobuf *iobuf, int size) {
  iobuf->len = iobuf->size = 0;
  iobuf->buf = NULL;

  if (size > 0 && (iobuf->buf = (char *) NS_MALLOC(size)) != NULL) {
    iobuf->size = size;
  }
}

void iobuf_free(struct iobuf *iobuf) {
  if (iobuf != NULL) {
    if (iobuf->buf != NULL) NS_FREE(iobuf->buf);
    iobuf_init(iobuf, 0);
  }
}

int iobuf_append(struct iobuf *io, const void *buf, int len) {
  static const double mult = IOBUF_RESIZE_MULTIPLIER;
  char *p = NULL;
  int new_len = 0;

  assert(io->len >= 0);
  assert(io->len <= io->size);

  if (len <= 0) {
  } else if ((new_len = io->len + len) < io->size) {
    memcpy(io->buf + io->len, buf, len);
    io->len = new_len;
  } else if ((p = (char *)
              NS_REALLOC(io->buf, (int) (new_len * mult))) != NULL) {
    io->buf = p;
    memcpy(io->buf + io->len, buf, len);
    io->len = new_len;
    io->size = (int) (new_len * mult);
  } else {
    len = 0;
  }

  return len;
}

void iobuf_remove(struct iobuf *io, int n) {
  if (n >= 0 && n <= io->len) {
    memmove(io->buf, io->buf + n, io->len - n);
    io->len -= n;
  }
}

static void nsk_add_conn(struct nsk_server *server, struct nsk_connection *c) {
  c->next = server->active_connections;
  server->active_connections = c;
  c->prev = NULL;
  if (c->next != NULL) c->next->prev = c;
}

static void nsk_remove_conn(struct nsk_connection *conn) {
  if (conn->prev == NULL) conn->server->active_connections = conn->next;
  if (conn->prev) conn->prev->next = conn->next;
  if (conn->next) conn->next->prev = conn->prev;
}

// Print message to buffer. If buffer is large enough to hold the message,
// return buffer. If buffer is to small, allocate large enough buffer on heap,
// and return allocated buffer.
int nsk_avprintf(char **buf, size_t size, const char *fmt, va_list ap) {
  va_list ap_copy;
  int len;

  va_copy(ap_copy, ap);
  len = vsnprintf(*buf, size, fmt, ap_copy);
  va_end(ap_copy);

  if (len < 0) {
    // eCos and Windows are not standard-compliant and return -1 when
    // the buffer is too small. Keep allocating larger buffers until we
    // succeed or out of memory.
    *buf = NULL;
    while (len < 0) {
      if (*buf) free(*buf);
      size *= 2;
      if ((*buf = (char *) NS_MALLOC(size)) == NULL) break;
      va_copy(ap_copy, ap);
      len = vsnprintf(*buf, size, fmt, ap_copy);
      va_end(ap_copy);
    }
  } else if (len > (int) size) {
    // Standard-compliant code path. Allocate a buffer that is large enough.
    if ((*buf = (char *) NS_MALLOC(len + 1)) == NULL) {
      len = -1;
    } else {
      va_copy(ap_copy, ap);
      len = vsnprintf(*buf, len + 1, fmt, ap_copy);
      va_end(ap_copy);
    }
  }

  return len;
}

int nsk_vprintf(struct nsk_connection *conn, const char *fmt, va_list ap) {
  char mem[2000], *buf = mem;
  int len;

  if ((len = nsk_avprintf(&buf, sizeof(mem), fmt, ap)) > 0) {
    iobuf_append(&conn->send_iobuf, buf, len);
  }
  if (buf != mem && buf != NULL) {
    free(buf);
  }

  return len;
}

int nsk_printf(struct nsk_connection *conn, const char *fmt, ...) {
  int len;
  va_list ap;
  va_start(ap, fmt);
  len = nsk_vprintf(conn, fmt, ap);
  va_end(ap);
  return len;
}

static void nsk_call(struct nsk_connection *conn, enum nsk_event ev, void *p) {
  if (conn->server->callback) conn->server->callback(conn, ev, p);
}

static void nsk_close_conn(struct nsk_connection *conn) {
  DBG(("%p %d", conn, conn->flags));
  nsk_call(conn, NS_CLOSE, NULL);
  nsk_remove_conn(conn);
  closesocket(conn->sock);
  iobuf_free(&conn->recv_iobuf);
  iobuf_free(&conn->send_iobuf);
  NS_FREE(conn);
}

void nsk_set_close_on_exec(sock_t sock) {
  fcntl(sock, F_SETFD, FD_CLOEXEC);
}

static void nsk_set_non_blocking_mode(sock_t sock) {
  int flags = fcntl(sock, F_GETFL, 0);
  fcntl(sock, F_SETFL, flags | O_NONBLOCK);
}

// Valid listening port spec is: [ip_address:]port, e.g. "80", "127.0.0.1:3128"
static int nsk_parse_port_string(const char *str, union socket_address *sa) {
  unsigned int a, b, c, d, port;
  int len = 0;

  // MacOS needs that. If we do not zero it, subsequent bind() will fail.
  // Also, all-zeroes in the socket address means binding to all addresses
  // for both IPv4 and IPv6 (INADDR_ANY and IN6ADDR_ANY_INIT).
  memset(sa, 0, sizeof(*sa));
  sa->sin.sin_family = AF_INET;

  if (sscanf(str, "%u.%u.%u.%u:%u%n", &a, &b, &c, &d, &port, &len) == 5) {
    // Bind to a specific IPv4 address, e.g. 192.168.1.5:8080
    sa->sin.sin_addr.s_addr = htonl((a << 24) | (b << 16) | (c << 8) | d);
    sa->sin.sin_port = htons((uint16) port);
  } else if (sscanf(str, "%u%n", &port, &len) == 1) {
    // If only port is specified, bind to IPv4, INADDR_ANY
    sa->sin.sin_port = htons((uint16) port);
  } else {
    port = 0;   // Parsing failure. Make port invalid.
  }

  return port <= 0xffff && str[len] == '\0';
}

// 'sa' must be an initialized address to bind to
static sock_t nsk_open_listening_socket(union socket_address *sa) {
  socklen_t len = sizeof(*sa);
  sock_t on = 1, sock = INVALID_SOCKET;

  if ((sock = socket(sa->sa.sa_family, SOCK_STREAM, 6)) != INVALID_SOCKET &&
      !setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (void *) &on, sizeof(on)) &&
      !bind(sock, &sa->sa, sa->sa.sa_family == AF_INET ?
            sizeof(sa->sin) : sizeof(sa->sa)) &&
      !listen(sock, SOMAXCONN)) {
    nsk_set_non_blocking_mode(sock);
    // In case port was set to 0, get the real port number
    (void) getsockname(sock, &sa->sa, &len);
  } else if (sock != INVALID_SOCKET) {
    closesocket(sock);
    sock = INVALID_SOCKET;
  }

  return sock;
}


int nsk_set_ssl_cert(struct nsk_server *server, const char *cert) {
#ifdef NS_ENABLE_SSL
  if (cert != NULL &&
      (server->ssl_ctx = SSL_CTX_new(SSLv23_server_method())) == NULL) {
    return -1;
  } else if (SSL_CTX_use_certificate_file(server->ssl_ctx, cert, 1) == 0 ||
             SSL_CTX_use_PrivateKey_file(server->ssl_ctx, cert, 1) == 0) {
    return -2;
  } else {
    SSL_CTX_use_certificate_chain_file(server->ssl_ctx, cert);
  }
  return 0;
#else
  return server != NULL && cert == NULL ? 0 : -3;
#endif
}

int nsk_bind(struct nsk_server *server, const char *str) {
  nsk_parse_port_string(str, &server->listening_sa);
  if (server->listening_sock != INVALID_SOCKET) {
    closesocket(server->listening_sock);
  }
  server->listening_sock = nsk_open_listening_socket(&server->listening_sa);
  return server->listening_sock == INVALID_SOCKET ? -1 :
    (int) ntohs(server->listening_sa.sin.sin_port);
}


static struct nsk_connection *accept_conn(struct nsk_server *server) {
  struct nsk_connection *c = NULL;
  union socket_address sa;
  socklen_t len = sizeof(sa);
  sock_t sock = INVALID_SOCKET;

  // NOTE(lsm): on Windows, sock is always > FD_SETSIZE
  if ((sock = accept(server->listening_sock, &sa.sa, &len)) == INVALID_SOCKET) {
    closesocket(sock);
  } else if ((c = (struct nsk_connection *) NS_MALLOC(sizeof(*c))) == NULL ||
             memset(c, 0, sizeof(*c)) == NULL) {
    closesocket(sock);
#ifdef NS_ENABLE_SSL
  } else if (server->ssl_ctx != NULL &&
             ((c->ssl = SSL_new(server->ssl_ctx)) == NULL ||
              SSL_set_fd(c->ssl, sock) != 1)) {
    DBG(("SSL error"));
    closesocket(sock);
    free(c);
    c = NULL;
#endif
  } else {
    nsk_set_close_on_exec(sock);
    nsk_set_non_blocking_mode(sock);
    c->server = server;
    c->sock = sock;
    c->flags |= NSF_ACCEPTED;

    nsk_add_conn(server, c);
    nsk_call(c, NS_ACCEPT, &sa);
    DBG(("%p %d %p %p", c, c->sock, c->ssl, server->ssl_ctx));
  }

  return c;
}

static int nsk_is_error(int n) {
  return n == 0 ||
    (n < 0 && errno != EINTR && errno != EINPROGRESS &&
     errno != EAGAIN && errno != EWOULDBLOCK
    );
}

static void nsk_read_from_socket(struct nsk_connection *conn) {
  char buf[2048];
  int n = 0;

  if (conn->flags & NSF_CONNECTING) {
    int ok = 1;
    //int ret;
   // socklen_t len = sizeof(ok);

    //ret = getsockopt(conn->sock, SOL_SOCKET, SO_ERROR, (char *) &ok, &len);
    //(void) ret;
#ifdef NS_ENABLE_SSL
    if (ret == 0 && ok == 0 && conn->ssl != NULL) {
      int res = SSL_connect(conn->ssl);
      int ssl_err = SSL_get_error(conn->ssl, res);
      DBG(("%p res %d %d", conn, res, ssl_err));
      if (res == 1) {
        conn->flags = NSF_SSL_HANDSHAKE_DONE;
      } else if (res == 0 || ssl_err == 2 || ssl_err == 3) {
        return; // Call us again
      } else {
        ok = 1;
      }
    }
#endif
    conn->flags &= ~NSF_CONNECTING;
    DBG(("%p ok=%d", conn, ok));
    if (ok != 0) {
      conn->flags |= NSF_CLOSE_IMMEDIATELY;
    }
    nsk_call(conn, NS_CONNECT, &ok);
    return;
  }

#ifdef NS_ENABLE_SSL
  if (conn->ssl != NULL) {
    if (conn->flags & NSF_SSL_HANDSHAKE_DONE) {
      n = SSL_read(conn->ssl, buf, sizeof(buf));
    } else {
      int res = SSL_accept(conn->ssl);
      int ssl_err = SSL_get_error(conn->ssl, res);
      DBG(("%p res %d %d", conn, res, ssl_err));
      if (res == 1) {
        conn->flags |= NSF_SSL_HANDSHAKE_DONE;
      } else if (res == 0 || ssl_err == 2 || ssl_err == 3) {
        return; // Call us again
      } else {
        conn->flags |= NSF_CLOSE_IMMEDIATELY;
      }
      return;
    }
  } else
#endif
  {
    n = recv(conn->sock, buf, sizeof(buf), 0);
  }

  DBG(("%p <- %d bytes [%.*s%s]",
       conn, n, n < 40 ? n : 40, buf, n < 40 ? "" : "..."));

  if (nsk_is_error(n)) {
    conn->flags |= NSF_CLOSE_IMMEDIATELY;
  } else if (n > 0) {
    iobuf_append(&conn->recv_iobuf, buf, n);
    nsk_call(conn, NS_RECV, &n);
  }
}

static void nsk_write_to_socket(struct nsk_connection *conn) {
  struct iobuf *io = &conn->send_iobuf;
  int n = 0;

#ifdef NS_ENABLE_SSL
  if (conn->ssl != NULL) {
    n = SSL_write(conn->ssl, io->buf, io->len);
  } else
#endif
  { n = send(conn->sock, io->buf, io->len, 0); }

  DBG(("%p -> %d bytes [%.*s%s]", conn, n, io->len < 40 ? io->len : 40,
       io->buf, io->len < 40 ? "" : "..."));

  if (nsk_is_error(n)) {
    conn->flags |= NSF_CLOSE_IMMEDIATELY;
  } else if (n > 0) {
    iobuf_remove(io, n);
    //conn->num_bytes_sent += n;
  }

  if (io->len == 0 && (conn->flags & NSF_FINISHED_SENDING_DATA)) {
    conn->flags |= NSF_CLOSE_IMMEDIATELY;
  }

  nsk_call(conn, NS_SEND, NULL);
}

int nsk_send(struct nsk_connection *conn, const void *buf, int len) {
  return iobuf_append(&conn->send_iobuf, buf, len);
}

static void nsk_add_to_set(sock_t sock, fd_set *set, sock_t *max_fd) {
  if (sock != INVALID_SOCKET) {
    FD_SET(sock, set);
    if (*max_fd == INVALID_SOCKET || sock > *max_fd) {
      *max_fd = sock;
    }
  }
}

int nsk_server_poll(struct nsk_server *server, int milli) {
  struct nsk_connection *conn, *tmp_conn;
  struct timeval tv;
  fd_set read_set, write_set;
  int num_active_connections = 0;
  sock_t max_fd = INVALID_SOCKET;
  time_t current_time = time(NULL);

  if (server->listening_sock == INVALID_SOCKET &&
      server->active_connections == NULL) return 0;

  FD_ZERO(&read_set);
  FD_ZERO(&write_set);
  nsk_add_to_set(server->listening_sock, &read_set, &max_fd);
  nsk_add_to_set(server->ctl[1], &read_set, &max_fd);

  for (conn = server->active_connections; conn != NULL; conn = tmp_conn) {
    tmp_conn = conn->next;
    nsk_call(conn, NS_POLL, &current_time);
    nsk_add_to_set(conn->sock, &read_set, &max_fd);
    if (conn->flags & NSF_CONNECTING) {
      nsk_add_to_set(conn->sock, &write_set, &max_fd);
    }
    if (conn->send_iobuf.len > 0 && !(conn->flags & NSF_BUFFER_BUT_DONT_SEND)) {
      nsk_add_to_set(conn->sock, &write_set, &max_fd);
    } else if (conn->flags & NSF_CLOSE_IMMEDIATELY) {
      nsk_close_conn(conn);
    }
  }

  tv.tv_sec = milli / 1000;
  tv.tv_usec = (milli % 1000) * 1000;

  if (select((int) max_fd + 1, &read_set, &write_set, NULL, &tv) > 0) {
    // Accept new connections
    if (server->listening_sock != INVALID_SOCKET &&
        FD_ISSET(server->listening_sock, &read_set)) {
      // We're not looping here, and accepting just one connection at
      // a time. The reason is that eCos does not respect non-blocking
      // flag on a listening socket and hangs in a loop.
      if ((conn = accept_conn(server)) != NULL) {
        conn->last_io_time = current_time;
      }
    }

    // Read possible wakeup calls
    if (server->ctl[1] != INVALID_SOCKET &&
        FD_ISSET(server->ctl[1], &read_set)) {
      unsigned char ch;
      recv(server->ctl[1], (char*)&ch, 1, 0);
      send(server->ctl[1], (char*)&ch, 1, 0);
    }

    for (conn = server->active_connections; conn != NULL; conn = tmp_conn) {
      tmp_conn = conn->next;
      if (FD_ISSET(conn->sock, &read_set)) {
        conn->last_io_time = current_time;
        nsk_read_from_socket(conn);
      }
      if (FD_ISSET(conn->sock, &write_set)) {
        if (conn->flags & NSF_CONNECTING) {
          nsk_read_from_socket(conn);
        } else if (!(conn->flags & NSF_BUFFER_BUT_DONT_SEND)) {
          conn->last_io_time = current_time;
          nsk_write_to_socket(conn);
        }
      }
    }
  }

  for (conn = server->active_connections; conn != NULL; conn = tmp_conn) {
    tmp_conn = conn->next;
    num_active_connections++;
    if (conn->flags & NSF_CLOSE_IMMEDIATELY) {
      nsk_close_conn(conn);
    }
  }
  //DBG(("%d active connections", num_active_connections));

  return num_active_connections;
}


struct nsk_connection *nsk_add_sock(struct nsk_server *s, sock_t sock, void *p) {
  struct nsk_connection *conn;
  if ((conn = (struct nsk_connection *) NS_MALLOC(sizeof(*conn))) != NULL) {
    memset(conn, 0, sizeof(*conn));
    nsk_set_non_blocking_mode(sock);
    conn->sock = sock;
    conn->connection_data = p;
    conn->server = s;
    conn->last_io_time = time(NULL);
    nsk_add_conn(s, conn);
    DBG(("%p %d", conn, sock));
  }
  return conn;
}

void nsk_iterate(struct nsk_server *server, nsk_callback_t cb, void *param) {
  struct nsk_connection *conn, *tmp_conn;

  for (conn = server->active_connections; conn != NULL; conn = tmp_conn) {
    tmp_conn = conn->next;
    cb(conn, NS_POLL, param);
  }
}

void nsk_server_wakeup(struct nsk_server *server) {
  unsigned char ch = 0;
  if (server->ctl[0] != INVALID_SOCKET) {
    send(server->ctl[0], (char*)&ch, 1, 0);
    recv(server->ctl[0], (char*)&ch, 1, 0);
  }
}

void nsk_server_init(struct nsk_server *s, void *server_data, nsk_callback_t cb) {
  memset(s, 0, sizeof(*s));
  s->listening_sock = s->ctl[0] = s->ctl[1] = INVALID_SOCKET;
  s->server_data = server_data;
  s->callback = cb;
#ifdef NS_ENABLE_SSL
  SSL_library_init();
  s->client_ssl_ctx = SSL_CTX_new(SSLv23_client_method());
#endif
}

void nsk_server_free(struct nsk_server *s) {
  struct nsk_connection *conn, *tmp_conn;

  DBG(("%p", s));
  if (s == NULL) return;
  // Do one last poll, see https://github.com/cesanta/mongoose/issues/286
  nsk_server_poll(s, 0);

  if (s->listening_sock != INVALID_SOCKET) closesocket(s->listening_sock);
  if (s->ctl[0] != INVALID_SOCKET) closesocket(s->ctl[0]);
  if (s->ctl[1] != INVALID_SOCKET) closesocket(s->ctl[1]);
  s->listening_sock = s->ctl[0] = s->ctl[1] = INVALID_SOCKET;

  for (conn = s->active_connections; conn != NULL; conn = tmp_conn) {
    tmp_conn = conn->next;
    nsk_close_conn(conn);
  }

#ifdef NS_ENABLE_SSL
  if (s->ssl_ctx != NULL) SSL_CTX_free(s->ssl_ctx);
  if (s->client_ssl_ctx != NULL) SSL_CTX_free(s->client_ssl_ctx);
#endif
}
