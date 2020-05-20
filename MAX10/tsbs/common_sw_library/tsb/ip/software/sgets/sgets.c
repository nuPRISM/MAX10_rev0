#include "sgets.h"
#include <stddef.h>

char *sgets( char * str, int num, char **input )
{
    char *next = *input;
    int  numread = 0;

    while ( numread + 1 < num && *next ) {
        int isnewline = ( *next == '\n' );
        *str++ = *next++;
        numread++;
        // newline terminates the line but is included
        if ( isnewline )
            break;
    }

    if ( numread == 0 ) {
        return NULL;  // "eof"
    }
    // must have hit the null terminator or end of line
    *str = '\0';  // null terminate this tring
    // set up input for next call
    *input = next;
    return str;
}
