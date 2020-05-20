#include "my_usleep.h"
#include <stddef.h>
int my_usleep (unsigned int usec) {
  int rc = 0;
#ifdef MY_USLEEP_USE_USLEEP
  rc = usleep(usec);
#elif MY_USLEEP_USE_POLL
  rc = poll(NULL, 0, usec / 1000);
#elif defined MY_USLEEP_USE_SELECT
  struct timeval t;
  t.tv_sec = usec / 1000000;
  t.tv_usec = usec % 1000000;
  rc = select(0, NULL, NULL, NULL, &t);
#else
#error "My_USLEEP MAcros Not Defined!"
#endif
  return rc;
}
