// Copyright (c) 2004-2013 Sergey Lyubka <valenok@gmail.com>
// Copyright (c) 2013-2014 Cesanta Software Limited
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

#include <ctype.h>

#include "net_skeleton.h"

#define O_BINARY 0
typedef struct stat file_stat_t;
typedef pid_t process_id_t;

#include "mongoose.h"

#define MAX_REQUEST_SIZE 65536
#define IOBUF_SIZE 65536

// Extra HTTP headers to send in every static file reply
#if !defined(MONGOOSE_USE_EXTRA_HTTP_HEADERS)
#define MONGOOSE_USE_EXTRA_HTTP_HEADERS ""
#endif

#ifndef MONGOOSE_POST_SIZE_LIMIT
#define MONGOOSE_POST_SIZE_LIMIT 0
#endif

#ifndef MONGOOSE_IDLE_TIMEOUT_SECONDS
#define MONGOOSE_IDLE_TIMEOUT_SECONDS 30
#endif

struct vec {
	const char *ptr;
	int len;
};

// For directory listing and WevDAV support
struct dir_entry {
	struct connection *conn;
	char *file_name;
	file_stat_t st;
};

// NOTE(lsm): this enum shoulds be in sync with the config_options.
enum {
	ACCESS_CONTROL_LIST,
	EXTRA_MIME_TYPES,
	LISTENING_PORT,
	URL_REWRITES,
	AUTH_DOMAIN,
	BASIC_AUTH,
	NUM_OPTIONS
};

static const char *static_config_options[] = {
		"access_control_list",	 	NULL,
		"extra_mime_types", 		NULL,
		"listening_port", 			NULL,
		"url_rewrites", 			NULL,
		"auth_domain",				NULL,
		"basic_auth",				NULL,
		NULL };

struct mg_server {
	struct nsk_server nsk_server;
	union socket_address lsa; // Listening socket address
	mg_handler_t event_handler;
	char *config_options[NUM_OPTIONS];
};

// Local endpoint representation
union endpoint {
	int fd; // Opened regular local file
	struct nsk_connection *cgi_conn; // CGI socket
};

enum endpoint_type {
	EP_NONE, EP_FILE, EP_CGI, EP_USER, EP_PUT, EP_CLIENT
};

#define MG_HEADERS_SENT NSF_USER_1
#define MG_LONG_RUNNING NSF_USER_2
#define MG_CGI_CONN NSF_USER_3

struct connection {
	struct nsk_connection *nsk_conn;
	struct mg_connection mg_conn;
	struct mg_server *server;
	union endpoint endpoint;
	enum endpoint_type endpoint_type;
	char *path_info;
	char *request;
	uint32 num_bytes_sent; // Total number of bytes sent
	uint32 cl; // Reply content length, for Range support
	int request_len; // Request length, including last \r\n after last header
};

#define MG_CONN_2_CONN(c) ((struct connection *) ((char *) (c) - offsetof(struct connection, mg_conn)))

static void open_local_endpoint(struct connection *conn, int skip_user);
static void close_local_endpoint(struct connection *conn);

static int is_authorized(struct connection* conn);
static int check_password(const char *response, const char* expected_response);


static const struct {
	const char *extension;
	size_t ext_len;
	const char *mime_type;
}

static_builtin_mime_types[] = {
	{ ".html", 	5, "text/html" },
	{ ".htm", 	4, "text/html" },
	{ ".shtm", 	5, "text/html" },
	{ ".shtml", 6, "text/html" },
	{ ".css",	4, "text/css" },
	{ ".js", 	3, "application/x-javascript" },
	{ ".ico", 	4, "image/x-icon" },
	{ ".gif", 4, "image/gif" },
	{ ".jpg", 4, "image/jpeg" },
	{ ".jpeg", 5, "image/jpeg" },
	{ ".png", 4, "image/png" },
	{ ".svg", 4, "image/svg+xml" },
	{ ".txt", 4, "text/plain" },
	{ ".torrent", 8, "application/x-bittorrent" },
	{ ".wav", 4, "audio/x-wav" },
	{ ".mp3", 4, "audio/x-mp3" },
	{ ".mid", 4, "audio/mid" },
	{ ".m3u", 4, "audio/x-mpegurl" },
	{ ".ogg", 4, "application/ogg" },
	{ ".ram", 4, "audio/x-pn-realaudio" },
	{ ".xml", 4, "text/xml" },
	{ ".json", 5, "text/json" },
	{ ".xslt", 5, "application/xml" },
	{ ".xsl", 4, "application/xml" },
	{ ".ra", 3, "audio/x-pn-realaudio" },
	{ ".doc", 4, "application/msword" },
	{ ".exe", 4, "application/octet-stream" },
	{ ".zip", 4, "application/x-zip-compressed" },
	{ ".xls", 4, "application/excel" },
	{ ".tgz", 4, "application/x-tar-gz" },
	{ ".tar", 4, "application/x-tar" },
	{ ".gz", 3, "application/x-gunzip" },
	{ ".arj", 4, "application/x-arj-compressed" },
	{ ".rar", 4, "application/x-arj-compressed" },
	{ ".rtf", 4, "application/rtf" },
	{ ".pdf", 4, "application/pdf" },
	{ ".swf", 4, "application/x-shockwave-flash" },
	{ ".mpg", 4, "video/mpeg" },
	{ ".webm", 5, "video/webm" },
	{ ".mpeg", 5, "video/mpeg" },
	{ ".mov", 4, "video/quicktime" },
	{ ".mp4", 4, "video/mp4" },
	{ ".m4v", 4, "video/x-m4v" },
	{ ".asf", 4, "video/x-ms-asf" },
	{ ".avi", 4, "video/x-msvideo" },
	{ ".bmp", 4, "image/bmp" },
	{ ".ttf", 4, "application/x-font-ttf" },
	{ NULL, 0, NULL }
};

// A helper function for traversing a comma separated list of values.
// It returns a list pointer shifted to the next value, or NULL if the end
// of the list found.
// Value is stored in val vector. If value has form "x=y", then eq_val
// vector is initialized to point to the "y" part, and val vector length
// is adjusted to point only to "x".
static const char *next_option(const char *list, struct vec *val, struct vec *eq_val) {
	if (list == NULL || *list == '\0') {
		// End of the list
		list = NULL;
	} else {
		val->ptr = list;
		if ((list = strchr(val->ptr, ',')) != NULL) {
			// Comma found. Store length and shift the list ptr
			val->len = list - val->ptr;
			list++;
		} else {
			// This value is the last one
			list = val->ptr + strlen(val->ptr);
			val->len = list - val->ptr;
		}

		if (eq_val != NULL) {
			// Value has form "x=y", adjust pointers and lengths
			// so that val points to "x", and eq_val points to "y".
			eq_val->len = 0;
			eq_val->ptr = (const char *) memchr(val->ptr, '=', val->len);
			if (eq_val->ptr != NULL) {
				eq_val->ptr++; // Skip over '=' character
				eq_val->len = val->ptr + val->len - eq_val->ptr;
				val->len = (eq_val->ptr - val->ptr) - 1;
			}
		}
	}

	return list;
}

// Like snprintf(), but never returns negative value, or a value
// that is larger than a supplied buffer.
static int mg_vsnprintf(char *buf, size_t buflen, const char *fmt, va_list ap) {
	int n;
	if (buflen < 1)
		return 0;
	n = vsnprintf(buf, buflen, fmt, ap);
	if (n < 0) {
		n = 0;
	} else if (n >= (int) buflen) {
		n = (int) buflen - 1;
	}
	buf[n] = '\0';
	return n;
}

static int mg_snprintf(char *buf, size_t buflen, const char *fmt, ...) {
	va_list ap;
	int n;
	va_start(ap, fmt);
	n = mg_vsnprintf(buf, buflen, fmt, ap);
	va_end(ap);
	return n;
}

// Check whether full request is buffered. Return:
//   -1  if request is malformed
//    0  if request is not yet fully buffered
//   >0  actual request length, including last \r\n\r\n
static int get_request_len(const char *s, int buf_len) {
	const unsigned char *buf = (unsigned char *) s;
	int i;

	for (i = 0; i < buf_len; i++) {
		// Control characters are not allowed but >=128 are.
		// Abort scan as soon as one malformed character is found.
		if (!isprint(buf[i]) && buf[i] != '\r' && buf[i] != '\n' && buf[i] < 128) {
			return -1;
		} else if (buf[i] == '\n' && i + 1 < buf_len && buf[i + 1] == '\n') {
			return i + 2;
		} else if (buf[i] == '\n' && i + 2 < buf_len && buf[i + 1] == '\r' && buf[i + 2] == '\n') {
			return i + 3;
		}
	}

	return 0;
}

// Skip the characters until one of the delimiters characters found.
// 0-terminate resulting word. Skip the rest of the delimiters if any.
// Advance pointer to buffer to the next word. Return found 0-terminated word.
static char *skip(char **buf, const char *delimiters) {
	char *p, *begin_word, *end_word, *end_delimiters;

	begin_word = *buf;
	end_word = begin_word + strcspn(begin_word, delimiters);
	end_delimiters = end_word + strspn(end_word, delimiters);

	for (p = end_word; p < end_delimiters; p++) {
		*p = '\0';
	}

	*buf = end_delimiters;

	return begin_word;
}

// Parse HTTP headers from the given buffer, advance buffer to the point
// where parsing stopped.
static void parse_http_headers(char **buf, struct mg_connection *ri) {
	size_t i;

	for (i = 0; i < ARRAY_SIZE(ri->http_headers); i++) {
		ri->http_headers[i].name = skip(buf, ": ");
		ri->http_headers[i].value = skip(buf, "\r\n");
		if (ri->http_headers[i].name[0] == '\0')
			break;
		ri->num_headers = i + 1;
	}
}

static const char *status_code_to_str(int status_code) {
	switch (status_code) {
	case 200:
		return "OK";
	case 201:
		return "Created";
	case 204:
		return "No Content";
	case 301:
		return "Moved Permanently";
	case 302:
		return "Found";
	case 304:
		return "Not Modified";
	case 400:
		return "Bad Request";
	case 403:
		return "Forbidden";
	case 404:
		return "Not Found";
	case 405:
		return "Method Not Allowed";
	case 409:
		return "Conflict";
	case 411:
		return "Length Required";
	case 413:
		return "Request Entity Too Large";
	case 415:
		return "Unsupported Media Type";
	case 423:
		return "Locked";
	case 500:
		return "Server Error";
	case 501:
		return "Not Implemented";
	default:
		return "Server Error";
	}
}

static int call_user(struct connection *conn, enum mg_event ev) {
	return conn != NULL && conn->server != NULL && conn->server->event_handler != NULL ? conn->server->event_handler(&conn->mg_conn, ev) : MG_FALSE;
}

static void send_http_error(struct connection *conn, int code, const char *fmt, ...) {
	const char *message = status_code_to_str(code);
	const char *rewrites = conn->server->config_options[URL_REWRITES];
	char headers[200], body[200];
	struct vec a, b;
	va_list ap;
	int body_len, headers_len, match_code;

	conn->mg_conn.status_code = code;

	// Invoke error handler if it is set
	if (call_user(conn, MG_HTTP_ERROR) == MG_TRUE) {
		close_local_endpoint(conn);
		return;
	}

	// Handle error code rewrites
	while ((rewrites = next_option(rewrites, &a, &b)) != NULL) {
		if ((match_code = atoi(a.ptr)) > 0 && match_code == code) {
			struct mg_connection *c = &conn->mg_conn;
			c->status_code = 302;
			mg_printf(c, "HTTP/1.1 %d Moved\r\n"
					"Location: %.*s?code=%d&orig_uri=%s&query_string=%s\r\n\r\n", c->status_code, b.len, b.ptr, code, c->uri,
					c->query_string == NULL ? "" : c->query_string);
			close_local_endpoint(conn);
			return;
		}
	}

	body_len = mg_snprintf(body, sizeof(body), "%d %s\n", code, message);
	if (fmt != NULL) {
		va_start(ap, fmt);
		body_len += mg_vsnprintf(body + body_len, sizeof(body) - body_len, fmt, ap);
		va_end(ap);
	}
	if ((code >= 300 && code <= 399) || code == 204) {
		// 3xx errors do not have body
		body_len = 0;
	}
	headers_len = mg_snprintf(headers, sizeof(headers), "HTTP/1.1 %d %s\r\nContent-Length: %d\r\n"
			"Content-Type: text/plain\r\n\r\n", code, message, body_len);
	nsk_send(conn->nsk_conn, headers, headers_len);
	nsk_send(conn->nsk_conn, body, body_len);
	close_local_endpoint(conn); // This will write to the log file
}

static void write_chunk(struct connection *conn, const char *buf, int len) {
	char chunk_size[50];
	int n = mg_snprintf(chunk_size, sizeof(chunk_size), "%X\r\n", len);
	nsk_send(conn->nsk_conn, chunk_size, n);
	nsk_send(conn->nsk_conn, buf, len);
	nsk_send(conn->nsk_conn, "\r\n", 2);
}

int mg_printf(struct mg_connection *conn, const char *fmt, ...) {
	struct connection
	*c = MG_CONN_2_CONN(conn);
	int len;
	va_list ap;

	va_start(ap, fmt);
	len = nsk_vprintf(c->nsk_conn, fmt, ap);
	va_end(ap);

	return len;
}

static char *mg_strdup(const char *str) {
	char *copy = (char *) malloc(strlen(str) + 1);
	if (copy != NULL) {
		strcpy(copy, str);
	}
	return copy;
}

static int isbyte(int n) {
	return n >= 0 && n <= 255;
}

static int parse_net(const char *spec, uint32 *net, uint32 *mask) {
	int n, a, b, c, d, slash = 32, len = 0;

	if ((sscanf(spec, "%d.%d.%d.%d/%d%n", &a, &b, &c, &d, &slash, &n) == 5 || sscanf(spec, "%d.%d.%d.%d%n", &a, &b, &c, &d, &n) == 4) && isbyte(a) && isbyte(b)
			&& isbyte(c) && isbyte(d) && slash >= 0 && slash < 33) {
		len = n;
		*net = ((uint32) a << 24) | ((uint32) b << 16) | ((uint32) c << 8) | d;
		*mask = slash ? 0xffffffffU << (32 - slash) : 0;
	}

	return len;
}

// Verify given socket address against the ACL.
// Return -1 if ACL is malformed, 0 if address is disallowed, 1 if allowed.
static int check_acl(const char *acl, uint32 remote_ip) {
	int allowed, flag;
	uint32 net, mask;
	struct vec vec;

	// If any ACL is set, deny by default
	allowed = acl == NULL ? '+' : '-';

	while ((acl = next_option(acl, &vec, NULL)) != NULL) {
		flag = vec.ptr[0];
		if ((flag != '+' && flag != '-') || parse_net(&vec.ptr[1], &net, &mask) == 0) {
			return -1;
		}

		if (net == (remote_ip & mask)) {
			allowed = flag;
		}
	}

	return allowed == '+';
}

// Protect against directory disclosure attack by removing '..',
// excessive '/' and '\' characters
static void remove_double_dots_and_double_slashes(char *s) {
	char *p = s;

	while (*s != '\0') {
		*p++ = *s++;
		if (s[-1] == '/' || s[-1] == '\\') {
			// Skip all following slashes, backslashes and double-dots
			while (s[0] != '\0') {
				if (s[0] == '/' || s[0] == '\\') {
					s++;
				} else if (s[0] == '.' && s[1] == '.') {
					s += 2;
				} else {
					break;
				}
			}
		}
	}
	*p = '\0';
}

int mg_url_decode(const char *src, int src_len, char *dst, int dst_len, int is_form_url_encoded) {
	int i, j, a, b;
#define HEXTOI(x) (isdigit(x) ? x - '0' : x - 'W')

	for (i = j = 0; i < src_len && j < dst_len - 1; i++, j++) {
		if (src[i] == '%' && i < src_len - 2 && isxdigit(* (const unsigned char *) (src + i + 1)) && isxdigit(* (const unsigned char *) (src + i + 2))) {
			a = tolower(*(const unsigned char *) (src + i + 1));
			b = tolower(*(const unsigned char *) (src + i + 2));
			dst[j] = (char) ((HEXTOI(a) << 4) | HEXTOI(b));
			i += 2;
		} else if (is_form_url_encoded && src[i] == '+') {
			dst[j] = ' ';
		} else {
			dst[j] = src[i];
		}
	}

	dst[j] = '\0'; // Null-terminate the destination

	return i >= src_len ? j : -1;
}

static int is_valid_http_method(const char *s) {
	return !strcmp(s, "GET") || !strcmp(s, "POST") || !strcmp(s, "HEAD") || !strcmp(s, "CONNECT") || !strcmp(s, "PUT") || !strcmp(s, "DELETE")
			|| !strcmp(s, "OPTIONS") || !strcmp(s, "PROPFIND") || !strcmp(s, "MKCOL");
}

// Parse HTTP request, fill in mg_request structure.
// This function modifies the buffer by NUL-terminating
// HTTP request components, header names and header values.
// Note that len must point to the last \n of HTTP headers.
static int parse_http_message(char *buf, int len, struct mg_connection *ri) {
	int is_request, n;

	// Reset the connection. Make sure that we don't touch fields that are
	// set elsewhere: remote_ip, remote_port, server_param
	ri->request_method = ri->uri = ri->http_version = ri->query_string = NULL;
	ri->num_headers = ri->status_code = ri->is_websocket = ri->content_len = 0;

	buf[len - 1] = '\0';

	// RFC says that all initial whitespaces should be ingored
	while (*buf != '\0' && isspace(* (unsigned char *) buf)) {
		buf++;
	}
	ri->request_method = skip(&buf, " ");
	ri->uri = skip(&buf, " ");
	ri->http_version = skip(&buf, "\r\n");

	// HTTP message could be either HTTP request or HTTP response, e.g.
	// "GET / HTTP/1.0 ...." or  "HTTP/1.0 200 OK ..."
	is_request = is_valid_http_method(ri->request_method);
	if ((is_request && memcmp(ri->http_version, "HTTP/", 5) != 0) || (!is_request && memcmp(ri->request_method, "HTTP/", 5) != 0)) {
		len = -1;
	} else {
		if (is_request) {
			ri->http_version += 5;
		}
		parse_http_headers(&buf, ri);

		if ((ri->query_string = strchr(ri->uri, '?')) != NULL) {
			*(char *) ri->query_string++ = '\0';
		}
		n = (int) strlen(ri->uri);
		mg_url_decode(ri->uri, n, (char *) ri->uri, n + 1, 0);
		remove_double_dots_and_double_slashes((char *) ri->uri);
	}

	return len;
}

static int lowercase(const char *s) {
	return tolower(*(const unsigned char *) s);
}

static int mg_strcasecmp(const char *s1, const char *s2) {
	int diff;

	do {
		diff = lowercase(s1++) - lowercase(s2++);
	} while (diff == 0 && s1[-1] != '\0');

	return diff;
}

static int mg_strncasecmp(const char *s1, const char *s2, size_t len) {
	int diff = 0;

	if (len > 0)
		do {
			diff = lowercase(s1++) - lowercase(s2++);
		} while (diff == 0 && s1[-1] != '\0' && --len > 0);

	return diff;
}

// Return HTTP header value, or NULL if not found.
const char *mg_get_header(const struct mg_connection *ri, const char *s) {
	int i;

	for (i = 0; i < ri->num_headers; i++)
		if (!mg_strcasecmp(s, ri->http_headers[i].name))
			return ri->http_headers[i].value;

	return NULL;
}

// Perform case-insensitive match of string against pattern
int mg_match_prefix(const char *pattern, int pattern_len, const char *str) {
	const char *or_str;
	int len, res, i = 0, j = 0;

	if ((or_str = (const char *) memchr(pattern, '|', pattern_len)) != NULL) {
		res = mg_match_prefix(pattern, or_str - pattern, str);
		return res > 0 ? res : mg_match_prefix(or_str + 1, (pattern + pattern_len) - (or_str + 1), str);
	}

	for (; i < pattern_len; i++, j++) {
		if (pattern[i] == '?' && str[j] != '\0') {
			continue;
		} else if (pattern[i] == '$') {
			return str[j] == '\0' ? j : -1;
		} else if (pattern[i] == '*') {
			i++;
			if (pattern[i] == '*') {
				i++;
				len = (int) strlen(str + j);
			} else {
				len = (int) strcspn(str + j, "/");
			}
			if (i == pattern_len) {
				return j + len;
			}
			do {
				res = mg_match_prefix(pattern + i, pattern_len - i, str + j + len);
			} while (res == -1 && len-- > 0);
			return res == -1 ? -1 : j + res + len;
		} else if (lowercase(&pattern[i]) != lowercase(&str[j])) {
			return -1;
		}
	}
	return j;
}

// This function prints HTML pages, and expands "{{something}}" blocks
// inside HTML by calling appropriate callback functions.
// Note that {{@path/to/file}} construct outputs embedded file's contents,
// which provides SSI-like functionality.
void mg_template(struct mg_connection *conn, const char *s, struct mg_expansion *expansions) {
	int i, j, pos = 0, inside_marker = 0;

	for (i = 0; s[i] != '\0'; i++) {
		if (inside_marker == 0 && !memcmp(&s[i], "{{", 2)) {
			if (i > pos) {
				mg_send_data(conn, &s[pos], i - pos);
			}
			pos = i;
			inside_marker = 1;
		}
		if (inside_marker == 1 && !memcmp(&s[i], "}}", 2)) {
			for (j = 0; expansions[j].keyword != NULL; j++) {
				const char *kw = expansions[j].keyword;
				if ((int) strlen(kw) == i - (pos + 2) && memcmp(kw, &s[pos + 2], i - (pos + 2)) == 0) {
					expansions[j].handler(conn);
					pos = i + 2;
					break;
				}
			}
			inside_marker = 0;
		}
	}
	if (i > pos) {
		mg_send_data(conn, &s[pos], i - pos);
	}
}

static int should_keep_alive(const struct mg_connection *conn) {
	struct connection
	*c = MG_CONN_2_CONN(conn);
	const char *method = conn->request_method;
	const char *http_version = conn->http_version;
	const char *header = mg_get_header(conn, "Connection");
	return method != NULL && (!strcmp(method, "GET") || c->endpoint_type == EP_USER)
			&& ((header != NULL && !mg_strcasecmp(header, "keep-alive")) || (header == NULL && http_version && !strcmp(http_version, "1.1")));
}

int mg_write(struct mg_connection *c, const void *buf, int len) {
	struct connection
	*conn = MG_CONN_2_CONN(c);
	return nsk_send(conn->nsk_conn, buf, len);
}

void mg_send_status(struct mg_connection *c, int status) {
	if (c->status_code == 0) {
		c->status_code = status;
		mg_printf(c, "HTTP/1.1 %d %s\r\n", status, status_code_to_str(status));
	}
}

void mg_send_header(struct mg_connection *c, const char *name, const char *v) {
	if (c->status_code == 0) {
		c->status_code = 200;
		mg_printf(c, "HTTP/1.1 %d %s\r\n", 200, status_code_to_str(200));
	}
	mg_printf(c, "%s: %s\r\n", name, v);
}

static void terminate_headers(struct mg_connection *c) {
	struct connection
	*conn = MG_CONN_2_CONN(c);
	if (!(conn->nsk_conn->flags & MG_HEADERS_SENT)) {
		mg_send_header(c, "Transfer-Encoding", "chunked");
		mg_write(c, "\r\n", 2);
		conn->nsk_conn->flags |= MG_HEADERS_SENT;
	}
}

void mg_send_data(struct mg_connection *c, const void *data, int data_len) {
	terminate_headers(c);
write_chunk(MG_CONN_2_CONN(c), (const char *) data, data_len);
}

void mg_printf_data(struct mg_connection *c, const char *fmt, ...) {
	struct connection
	*conn = MG_CONN_2_CONN(c);
	va_list ap;
	int len;
	char mem[IOBUF_SIZE], *buf = mem;

	terminate_headers(c);

	va_start(ap, fmt);
	len = nsk_avprintf(&buf, sizeof(mem), fmt, ap);
	va_end(ap);

	if (len > 0) {
		write_chunk((struct connection *) conn, buf, len);
	}
	if (buf != mem && buf != NULL) {
		free(buf);
	}
}

static void write_terminating_chunk(struct connection *conn) {
	mg_write(&conn->mg_conn, "0\r\n\r\n", 5);
}

static int call_request_handler(struct connection *conn) {
	int result;
	conn->mg_conn.content = conn->nsk_conn->recv_iobuf.buf;
	if ((result = call_user(conn, MG_REQUEST)) == MG_TRUE) {
		if (conn->nsk_conn->flags & MG_HEADERS_SENT) {
			write_terminating_chunk(conn);
		}
		close_local_endpoint(conn);
	}
	return result;
}

const char *mg_get_mime_type(const char *path, const char *default_mime_type) {
	const char *ext;
	size_t i, path_len;

	path_len = strlen(path);

	for (i = 0; static_builtin_mime_types[i].extension != NULL; i++) {
		ext = path + (path_len - static_builtin_mime_types[i].ext_len);
		if (path_len > static_builtin_mime_types[i].ext_len && mg_strcasecmp(ext, static_builtin_mime_types[i].extension) == 0) {
			return static_builtin_mime_types[i].mime_type;
		}
	}

	return default_mime_type;
}

static void call_request_handler_if_data_is_buffered(struct connection *conn) {
	struct iobuf *loc = &conn->nsk_conn->recv_iobuf;
	struct mg_connection *c = &conn->mg_conn;

	if ((size_t) loc->len >= c->content_len && call_request_handler(conn) == MG_FALSE) {
		open_local_endpoint(conn, 1);
	}
}

static void send_options(struct connection *conn) {
	conn->mg_conn.status_code = 200;
	mg_printf(&conn->mg_conn, "%s", "HTTP/1.1 200 OK\r\n"
	"Access-Control-Allow-Origin: *\r\n"
	"Access-Control-Allow-Methods: GET,POST\r\n"
	"Access-Control-Allow-Headers: Content-Type\r\n"
	"Access-Control-Max-Age: 120\r\n\r\n");	
	close_local_endpoint(conn);
}

static int parse_header(const char *str, int str_len, const char *var_name, char *buf, size_t buf_size) {
	int ch = ' ', len = 0, n = strlen(var_name);
	const char *p, *end = str + str_len, *s = NULL;

	if (buf != NULL && buf_size > 0)
		buf[0] = '\0';

	// Find where variable starts
	for (s = str; s != NULL && s + n < end; s++) {
		if ((s == str || s[-1] == ' ' || s[-1] == ',') && s[n] == '=' && !memcmp(s, var_name, n))
			break;
	}

	if (s != NULL && &s[n + 1] < end) {
		s += n + 1;
		if (*s == '"' || *s == '\'')
			ch = *s++;
		p = s;
		while (p < end && p[0] != ch && p[0] != ',' && len < (int) buf_size) {
			if (p[0] == '\\' && p[1] == ch)
				p++;
			buf[len++] = *p++;
		}
		if (len >= (int) buf_size || (ch != ' ' && *p != ch)) {
			len = 0;
		} else {
			if (len > 0 && s[len - 1] == ',')
				len--;
			if (len > 0 && s[len - 1] == ';')
				len--;
			buf[len] = '\0';
		}
	}

	return len;
}

int mg_parse_header(const char *s, const char *var_name, char *buf, size_t buf_size) {
	return parse_header(s, s == NULL ? 0 : strlen(s), var_name, buf, buf_size);
}

static void open_local_endpoint(struct connection *conn, int skip_user) {

	// If EP_USER was set in a prev call, reset it
	conn->endpoint_type = EP_NONE;

	if (conn->server->event_handler && call_user(conn, MG_AUTH) == MG_FALSE) {
		mg_send_basic_auth_request(&conn->mg_conn);
		return;
	 }

	if (!strcmp(conn->mg_conn.request_method, "OPTIONS")) {
		send_options(conn);
		return;
	}
	
	// Call URI handler if one is registered for this URI
	if (skip_user == 0 && conn->server->event_handler != NULL) {
		conn->endpoint_type = EP_USER;
#if MONGOOSE_POST_SIZE_LIMIT > 1
		{
			const char *cl = mg_get_header(&conn->mg_conn, "Content-Length");
			if (!strcmp(conn->mg_conn.request_method, "POST") &&
					(cl == NULL || to64(cl) > MONGOOSE_POST_SIZE_LIMIT)) {
				send_http_error(conn, 500, "POST size > %zu",
						(size_t) MONGOOSE_POST_SIZE_LIMIT);
			}
		}
#endif
		return;
	}

	if (!is_authorized(conn)) {
		mg_send_basic_auth_request(&conn->mg_conn);
		close_local_endpoint(conn);
	} else {
		send_http_error(conn, 404, NULL);
	}
}

void mg_send_basic_auth_request(struct mg_connection *c) {
  struct connection *conn = MG_CONN_2_CONN(c);
  c->status_code = 401;
  mg_printf(c,
            "HTTP/1.1 401 Unauthorized\r\n"
            "WWW-Authenticate: Basic realm=\"%s\"\r\n\r\n",
            mg_get_option(conn->server, "auth_domain"));
  close_local_endpoint(conn);
}

static void send_continue_if_expected(struct connection *conn) {
	static const char expect_response[] = "HTTP/1.1 100 Continue\r\n\r\n";
	const char *expect_hdr = mg_get_header(&conn->mg_conn, "Expect");

	if (expect_hdr != NULL && !mg_strcasecmp(expect_hdr, "100-continue")) {
		nsk_send(conn->nsk_conn, expect_response, sizeof(expect_response) - 1);
	}
}

// Return 1 if request is authorised, 0 otherwise.
static int is_authorized(struct connection* conn) {
  int authorized = MG_TRUE;

  // Only do basic auth if we have a password set
  if(mg_get_option(conn->server, "basic_auth") > 0) {
	  authorized = mg_authorize_basic(&conn->mg_conn, mg_get_option(conn->server, "basic_auth"));
  }


  return authorized;
}

// Authorize against the opened passwords file. Return 1 if authorized.
int mg_authorize_basic(struct mg_connection *c, const char* pass) {
  const char *hdr;

  if (c == NULL) return 0;
  if ((hdr = mg_get_header(c, "Authorization")) == NULL || mg_strncasecmp(hdr, "Basic ", 6) != 0) return 0;

  return check_password(hdr+6, pass);
}

void base64_encode(const unsigned char *src, int src_len, char *dst) {
  static const char *b64 =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  int i, j, a, b, c;

  for (i = j = 0; i < src_len; i += 3) {
    a = src[i];
    b = i + 1 >= src_len ? 0 : src[i + 1];
    c = i + 2 >= src_len ? 0 : src[i + 2];

    dst[j++] = b64[a >> 2];
    dst[j++] = b64[((a & 3) << 4) | (b >> 4)];
    if (i + 1 < src_len) {
      dst[j++] = b64[(b & 15) << 2 | (c >> 6)];
    }
    if (i + 2 < src_len) {
      dst[j++] = b64[c & 63];
    }
  }
  while (j % 4 != 0) {
    dst[j++] = '=';
  }
  dst[j++] = '\0';
}

// Check the user's password, return 1 if OK
static int check_password(const char *response, const char* expected_response) {
  return mg_strcasecmp(response, expected_response) == 0 ? MG_TRUE : MG_FALSE;
}

static int is_valid_uri(const char *uri) {
	// Conform to http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5.1.2
	// URI can be an asterisk (*) or should start with slash.
	return uri[0] == '/' || (uri[0] == '*' && uri[1] == '\0');
}

static void try_parse(struct connection *conn) {
	struct iobuf *io = &conn->nsk_conn->recv_iobuf;

	if (conn->request_len == 0 && (conn->request_len = get_request_len(io->buf, io->len)) > 0) {
		// If request is buffered in, remove it from the iobuf. This is because
		// iobuf could be reallocated, and pointers in parsed request could
		// become invalid.
		conn->request = (char *) malloc(conn->request_len);
		memcpy(conn->request, io->buf, conn->request_len);
		DBG(("%p [%.*s]", conn, conn->request_len, conn->request));
		iobuf_remove(io, conn->request_len);
		conn->request_len = parse_http_message(conn->request, conn->request_len, &conn->mg_conn);
		if (conn->request_len > 0) {
			const char *cl_hdr = mg_get_header(&conn->mg_conn, "Content-Length");
			conn->cl = cl_hdr == NULL ? 0 : to64(cl_hdr);
			conn->mg_conn.content_len = (long int) conn->cl;
		}
	}
}

static void process_request(struct connection *conn) {
	struct iobuf *io = &conn->nsk_conn->recv_iobuf;

	try_parse(conn);
	DBG(("%p %d %d %d [%.*s]", conn, conn->request_len, io->len,
					conn->nsk_conn->flags, io->len, io->buf));
	if (conn->request_len < 0 || (conn->request_len > 0 && !is_valid_uri(conn->mg_conn.uri))) {
		send_http_error(conn, 400, NULL);
	} else if (conn->request_len == 0 && io->len > MAX_REQUEST_SIZE) {
		send_http_error(conn, 413, NULL);
	} else if (conn->request_len > 0 && strcmp(conn->mg_conn.http_version, "1.0") != 0 && strcmp(conn->mg_conn.http_version, "1.1") != 0) {
		send_http_error(conn, 505, NULL);
	} else if (conn->request_len > 0 && conn->endpoint_type == EP_NONE) {
		send_continue_if_expected(conn);
		open_local_endpoint(conn, 0);
	}

	if (conn->endpoint_type == EP_USER) {
		call_request_handler_if_data_is_buffered(conn);
	}
}

static void call_http_client_handler(struct connection *conn) {
	//conn->mg_conn.status_code = code;
	// For responses without Content-Lengh, use the whole buffer
	if (conn->cl == 0) {
		conn->mg_conn.content_len = conn->nsk_conn->recv_iobuf.len;
	}
	conn->mg_conn.content = conn->nsk_conn->recv_iobuf.buf;
	if (call_user(conn, MG_REPLY) == MG_FALSE) {
		conn->nsk_conn->flags |= NSF_CLOSE_IMMEDIATELY;
	}
	iobuf_remove(&conn->nsk_conn->recv_iobuf, conn->mg_conn.content_len);
	conn->mg_conn.status_code = 0;
	conn->cl = conn->num_bytes_sent = conn->request_len = 0;
	free(conn->request);
	conn->request = NULL;
}

static void process_response(struct connection *conn) {
	struct iobuf *io = &conn->nsk_conn->recv_iobuf;

	try_parse(conn);
	DBG(("%p %d %d [%.*s]", conn, conn->request_len, io->len,
					io->len > 40 ? 40 : io->len, io->buf));
	if (conn->request_len < 0 || (conn->request_len == 0 && io->len > MAX_REQUEST_SIZE)) {
		call_http_client_handler(conn);
	} else if (io->len >= conn->cl) {
		call_http_client_handler(conn);
	}
}

static void close_local_endpoint(struct connection *conn) {
	struct mg_connection *c = &conn->mg_conn;
	// Must be done before free()
	int keep_alive = should_keep_alive(&conn->mg_conn) && (conn->endpoint_type == EP_FILE || conn->endpoint_type == EP_USER);
	DBG(("%p %d %d %d", conn, conn->endpoint_type, keep_alive,
					conn->nsk_conn->flags));

	switch (conn->endpoint_type) {
	case EP_PUT:
	case EP_FILE:
		close(conn->endpoint.fd);
		break;
	case EP_CGI:
		if (conn->endpoint.cgi_conn != NULL) {
			conn->endpoint.cgi_conn->flags |= NSF_CLOSE_IMMEDIATELY;
			conn->endpoint.cgi_conn->connection_data = NULL;
		}
		break;
	default:
		break;
	}

	// Gobble possible POST data sent to the URI handler
	iobuf_remove(&conn->nsk_conn->recv_iobuf, conn->mg_conn.content_len);
	conn->endpoint_type = EP_NONE;
	conn->cl = conn->num_bytes_sent = conn->request_len = 0;
	conn->nsk_conn->flags &= ~(NSF_FINISHED_SENDING_DATA | NSF_BUFFER_BUT_DONT_SEND | NSF_CLOSE_IMMEDIATELY | MG_HEADERS_SENT | MG_LONG_RUNNING);
	c->request_method = c->uri = c->http_version = c->query_string = NULL;
	c->num_headers = c->status_code = c->is_websocket = c->content_len = 0;
	free(conn->request);
	conn->request = NULL;
	free(conn->path_info);
	conn->path_info = NULL;

	if (keep_alive) {
		process_request(conn); // Can call us recursively if pipelining is used
	} else {
		conn->nsk_conn->flags |= conn->nsk_conn->send_iobuf.len == 0 ? NSF_CLOSE_IMMEDIATELY : NSF_FINISHED_SENDING_DATA;
	}
}

static void transfer_file_data(struct connection *conn) {
	char buf[IOBUF_SIZE];
	int n = read(conn->endpoint.fd, buf, conn->cl < (uint32) sizeof(buf) ? (int) conn->cl : (int) sizeof(buf));

	if (n <= 0) {
		close_local_endpoint(conn);
	} else if (n > 0) {
		conn->cl -= n;
		nsk_send(conn->nsk_conn, buf, n);
		if (conn->cl <= 0) {
			close_local_endpoint(conn);
		}
	}
}

int mg_poll_server(struct mg_server *server, int milliseconds) {
	return nsk_server_poll(&server->nsk_server, milliseconds);
}

void mg_destroy_server(struct mg_server **server) {
	if (server != NULL && *server != NULL) {
		struct mg_server *s = *server;
		int i;

		nsk_server_free(&s->nsk_server);
		for (i = 0; i < (int) ARRAY_SIZE(s->config_options); i++) {
			free(s->config_options[i]); // It is OK to free(NULL)
		}
		free(s);
		*server = NULL;
	}
}

struct mg_iterator {
	mg_handler_t cb;
	void *param;
};

static void iter(struct nsk_connection *nsconn, enum nsk_event ev, void *param) {
	if (ev == NS_POLL) {
		struct mg_iterator *it = (struct mg_iterator *) param;
		struct connection *c = (struct connection *) nsconn->connection_data;
		c->mg_conn.callback_param = it->param;
		it->cb(&c->mg_conn, MG_POLL);
	}
}

// Apply function to all active connections.
void mg_iterate_over_connections(struct mg_server *server, mg_handler_t cb, void *param) {
	struct mg_iterator it = { cb, param };
	nsk_iterate(&server->nsk_server, iter, &it);
}

static int get_var(const char *data, size_t data_len, const char *name, char *dst, size_t dst_len) {
	const char *p, *e, *s;
	size_t name_len;
	int len;

	if (dst == NULL || dst_len == 0) {
		len = -2;
	} else if (data == NULL || name == NULL || data_len == 0) {
		len = -1;
		dst[0] = '\0';
	} else {
		name_len = strlen(name);
		e = data + data_len;
		len = -1;
		dst[0] = '\0';

		// data is "var1=val1&var2=val2...". Find variable first
		for (p = data; p + name_len < e; p++) {
			if ((p == data || p[-1] == '&') && p[name_len] == '=' && !mg_strncasecmp(name, p, name_len)) {

				// Point p to variable value
				p += name_len + 1;

				// Point s to the end of the value
				s = (const char *) memchr(p, '&', (size_t)(e - p));
				if (s == NULL) {
					s = e;
				}
				assert(s >= p);

				// Decode variable into destination buffer
				len = mg_url_decode(p, (size_t)(s - p), dst, dst_len, 1);

				// Redirect error code from -1 to -2 (destination buffer too small).
				if (len == -1) {
					len = -2;
				}
				break;
			}
		}
	}

	return len;
}

int mg_get_var(const struct mg_connection *conn, const char *name, char *dst, size_t dst_len) {
	int len = get_var(conn->query_string, conn->query_string == NULL ? 0 : strlen(conn->query_string), name, dst, dst_len);
	if (len < 0) {
		len = get_var(conn->content, conn->content_len, name, dst, dst_len);
	}
	return len;
}

static int get_line_len(const char *buf, int buf_len) {
	int len = 0;
	while (len < buf_len && buf[len] != '\n')
		len++;
	return buf[len] == '\n' ? len + 1 : -1;
}

int mg_parse_multipart(const char *buf, int buf_len, char *var_name, int var_name_len, char *file_name, int file_name_len, const char **data, int *data_len) {
	static const char cd[] = "Content-Disposition: ";

	int hl, bl, n, ll, pos, cdl = sizeof(cd) - 1;
	//char *p;

	if (buf == NULL || buf_len <= 0)
		return 0;
	if ((hl = get_request_len(buf, buf_len)) <= 0)
		return 0;
	if (buf[0] != '-' || buf[1] != '-' || buf[2] == '\n')
		return 0;

	// Get boundary length
	bl = get_line_len(buf, buf_len);

	// Loop through headers, fetch variable name and file name
	var_name[0] = file_name[0] = '\0';
	for (n = bl; (ll = get_line_len(buf + n, hl - n)) > 0; n += ll) {
		if (mg_strncasecmp(cd, buf + n, cdl) == 0) {
			parse_header(buf + n + cdl, ll - (cdl + 2), "name", var_name, var_name_len);
			parse_header(buf + n + cdl, ll - (cdl + 2), "filename", file_name, file_name_len);
		}
	}

	// Scan body, search for terminating boundary
	for (pos = hl; pos + (bl - 2) < buf_len; pos++) {
		if (buf[pos] == '-' && !memcmp(buf, &buf[pos], bl - 2)) {
			if (data_len != NULL)
				*data_len = (pos - 2) - hl;
			if (data != NULL)
				*data = buf + hl;
			return pos;
		}
	}

	return 0;
}

const char **mg_get_valid_option_names(void) {
	return static_config_options;
}

static int get_option_index(const char *name) {
	int i;

	for (i = 0; static_config_options[i * 2] != NULL; i++) {
		if (strcmp(static_config_options[i * 2], name) == 0) {
			return i;
		}
	}
	return -1;
}

static void set_default_option_values(char **opts) {
	const char *value, **all_opts = mg_get_valid_option_names();
	int i;

	for (i = 0; all_opts[i * 2] != NULL; i++) {
		value = all_opts[i * 2 + 1];
		if (opts[i] == NULL && value != NULL) {
			opts[i] = mg_strdup(value);
		}
	}
}

const char *mg_set_option(struct mg_server *server, const char *name, const char *value) {
	int ind = get_option_index(name);
	const char *error_msg = NULL;
	char **v = NULL;

	if (ind < 0)
		return "No such option";
	v = &server->config_options[ind];

	// Return success immediately if setting to the same value
	if ((*v == NULL && value == NULL) || (value != NULL && *v != NULL && !strcmp(value, *v))) {
		return NULL;
	}

	if (*v != NULL) {
		free(*v);
		*v = NULL;
	}

	if (value == NULL)
		return NULL;

	*v = mg_strdup(value);
	DBG(("%s [%s]", name, *v));

	if (ind == LISTENING_PORT) {
		int port = nsk_bind(&server->nsk_server, value);
		if (port < 0) {
			error_msg = "Cannot bind to port";
		} else {
			if (!strcmp(value, "0")) {
				char buf[10];
				mg_snprintf(buf, sizeof(buf), "%d", port);
				free(*v);
				*v = mg_strdup(buf);
			}
		}

#ifdef NS_ENABLE_SSL
	} else if (ind == SSL_CERTIFICATE) {
		int res = nsk_set_ssl_cert(&server->nsk_server, value);
		if (res == -2) {
			error_msg = "Cannot load PEM";
		} else if (res == -3) {
			error_msg = "SSL not enabled";
		} else if (res == -1) {
			error_msg = "SSL_CTX_new() failed";
		}
#endif
	}

	return error_msg;
}

static void on_accept(struct nsk_connection *nc, union socket_address *sa) {
	struct mg_server *server = (struct mg_server *) nc->server;
	struct connection *conn;

	if (!check_acl(server->config_options[ACCESS_CONTROL_LIST], ntohl(*(uint32 *) &sa->sin.sin_addr))
			|| (conn = (struct connection *) calloc(1, sizeof(*conn))) == NULL) {
		nc->flags |= NSF_CLOSE_IMMEDIATELY;
	} else {
		// Circularly link two connection structures
		nc->connection_data = conn;
		conn->nsk_conn = nc;

		// Initialize the rest of connection attributes
		conn->server = server;
		conn->mg_conn.server_param = nc->server->server_data;
	}
}

static void mg_ev_handler(struct nsk_connection *nc, enum nsk_event ev, void *p) {
	struct connection *conn = (struct connection *) nc->connection_data;

	switch (ev) {
	case NS_ACCEPT:
		on_accept(nc, (union socket_address *) p);
		break;

	case NS_CONNECT:
		conn->mg_conn.status_code = *(int *) p;
		if (conn->mg_conn.status_code != 0 || call_user(conn, MG_CONNECT) == MG_FALSE) {
			nc->flags |= NSF_CLOSE_IMMEDIATELY;
		}
		break;

	case NS_RECV:
		if (nc->flags & NSF_ACCEPTED) {
			process_request(conn);
		} else {
			process_response(conn);
		}
		break;

	case NS_SEND:
		break;

	case NS_CLOSE:
		nc->connection_data = NULL;
		if ((nc->flags & MG_CGI_CONN) && conn && conn->nsk_conn) {
			conn->nsk_conn->flags &= ~NSF_BUFFER_BUT_DONT_SEND;
			conn->nsk_conn->flags |= conn->nsk_conn->send_iobuf.len > 0 ? NSF_FINISHED_SENDING_DATA : NSF_CLOSE_IMMEDIATELY;
			conn->endpoint.cgi_conn = NULL;
		} else if (conn != NULL) {
			DBG(("%p %d closing", conn, conn->endpoint_type));

			if (conn->endpoint_type == EP_CLIENT && nc->recv_iobuf.len > 0) {
				call_http_client_handler(conn);
			}

			call_user(conn, MG_CLOSE);
			close_local_endpoint(conn);
			free(conn);
		}
		break;

	case NS_POLL:
		if (call_user(conn, MG_POLL) == MG_TRUE) {
			nc->flags |= NSF_FINISHED_SENDING_DATA;
		}

		if (conn != NULL && conn->endpoint_type == EP_FILE) {
			transfer_file_data(conn);
		}

		// Expire idle connections
		{
			time_t current_time = *(time_t *) p;

			if (nc->last_io_time + MONGOOSE_IDLE_TIMEOUT_SECONDS < current_time) {
				mg_ev_handler(nc, NS_CLOSE, NULL);
				nc->flags |= NSF_CLOSE_IMMEDIATELY;
			}
		}
		break;

	default:
		break;
	}
}

void mg_wakeup_server(struct mg_server *server) {
	nsk_server_wakeup(&server->nsk_server);
}

void mg_set_listening_socket(struct mg_server *server, int sock) {
	if (server->nsk_server.listening_sock != INVALID_SOCKET) {
		close(server->nsk_server.listening_sock);
	}
	server->nsk_server.listening_sock = (sock_t) sock;
}

int mg_get_listening_socket(struct mg_server *server) {
	return server->nsk_server.listening_sock;
}

const char *mg_get_option(const struct mg_server *server, const char *name) {
	const char **opts = (const char **) server->config_options;
	int i = get_option_index(name);
	return i == -1 ? NULL : opts[i] == NULL ? "" : opts[i];
}

struct mg_server *mg_create_server(void *server_data, mg_handler_t handler) {
	struct mg_server *server = (struct mg_server *) calloc(1, sizeof(*server));
	nsk_server_init(&server->nsk_server, server_data, mg_ev_handler);
	set_default_option_values(server->config_options);
	server->event_handler = handler;
	return server;
}
