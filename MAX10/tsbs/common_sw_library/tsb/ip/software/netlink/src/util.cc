/*
    NetLink Sockets: Networking C++ library
    Copyright 2012 Pedro Francisco Pareja Ruiz (PedroPareja@Gmail.com)

    This file is part of NetLink Sockets.

    NetLink Sockets is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    NetLink Sockets is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with NetLink Sockets. If not, see <http://www.gnu.org/licenses/>.

*/


#include <netlink/util.h>

#ifdef REPLACE_NETLINK_GETTIMEOFDAY
#include <inttypes.h>
#include <math.h>
#include <stdio.h>
#include <time.h>

unsigned long long ____________alt_getttime() {

	    unsigned long long            ms; // Milliseconds
	    unsigned long long            total_ms; // Milliseconds
	    struct timespec spec;

	    clock_gettime(CLOCK_REALTIME, &spec);

	    ms = round(spec.tv_nsec / 1.0e6); // Convert nanoseconds to milliseconds
	    total_ms  = spec.tv_sec*1000 + ms;
	    return total_ms;

}
#endif

unsigned long long NL_NAMESPACE_NAME::getTime() {

    #ifdef OS_WIN32

        SYSTEMTIME now;
        GetSystemTime(&now);
        unsigned long long milisec = now.wHour *3600*1000 + now.wMinute *60*1000 + now.wSecond *1000 + now.wMilliseconds;
        return(milisec);

    #else

		#ifdef REPLACE_NETLINK_GETTIMEOFDAY
		        return ____________alt_getttime();
        #else
				struct timeval now;
				gettimeofday(&now, NULL);
				unsigned long long milisec = now.tv_sec * 1000 + now.tv_usec / 1000.0;
				return(milisec);
		#endif

    #endif
    return 0;
}

