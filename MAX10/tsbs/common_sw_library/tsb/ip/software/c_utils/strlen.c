#include "strlen.h"

unsigned long my_strlen(const char *s)
{
    unsigned long sz = 0;
    while(*s++) sz++;
    return sz;
}
