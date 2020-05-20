/*
 * build.c
 *
 *  Created on: Jun 23, 2016
 *      Author: bryerton
 */

#include <time.h>
#include <string.h>
#include "build.h"

	// Convert __TIMESTAMP__ from string to UNIX Timestamp ( Wed Jan 18 22:29:12 2012 )
unsigned int GetBuildTime(void) {
	struct tm tm;
	memset(&tm, 0, sizeof(struct tm));

	_timezone = -25200;

	strptime(__DATE__" "__TIME__, "%b %d %Y %T", &tm);
	return mktime(&tm) - _timezone;
}


