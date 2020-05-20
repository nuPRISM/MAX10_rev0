#ifndef MY_USLEEP_H
#define MY_USLEEP_H 1
#ifdef __cplusplus
extern "C" {
#endif
#include "basedef.h"
#ifdef MY_USLEEP_USE_USLEEP
#include <unistd.h>
#elif defined MY_USLEEP_USE_POLL
#include <poll.h>
#elif defined MY_USLEEP_USE_SELECT
#include <sys/time.h>
#else
#error "unable to implement my_usleep"
#endif

int
my_usleep (unsigned int usec);

#ifdef __cplusplus
}
#endif



#endif
