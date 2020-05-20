/******************************************************************************
* Copyright  2004 Altera Corporation, San Jose, California, USA.             *
* All rights reserved. All use of this software and documentation is          *
* subject to the License Agreement located at the end of this file below.     *
*******************************************************************************
*                                                                             *
* This file is used to set/read the target system clock.                      *
*                                                                             *
******************************************************************************/

extern "C" {



#include "includes.h"
#include "ipport.h"
#include "tcpport.h"
#include "alt_error_handler.hpp"
#include "alt_types.h"
#include "ntp_client/ntp_client.h"
#include "target_clock.h"
#include "ucos_ii.h"
}
#include <errno.h>
#include <sys/param.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/fcntl.h>
#include <sys/types.h>
#include <sys/time.h>
#include <stdio.h>
#include <time.h>
#include <ctime>
#include "chan_fatfs/ff.h"
#include "basedef.h"

#ifdef LCD_DISPLAY_NAME
OS_EVENT *lcd_sem;
#endif /* LCD_DISPLAY_NAME */

#ifdef LCD_DISPLAY_NAME
extern  FILE* lcdDevice;
#endif /* LCD_DISPLAY_NAME */

#define INCLUDE_LOCAL_TIME
#ifdef INCLUDE_LOCAL_TIME

#define BASE_YEAR	1970
#define START_WDAY	4	/* constant. don't change */
#define SECS_PER_MIN	60
#define SECS_PER_HOUR	(SECS_PER_MIN*60)
#define SECS_PER_DAY	(SECS_PER_HOUR*24)

static unsigned int month_days[12] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

static unsigned long tzoffset;		/* timezone offset in seconds */

static void secs_to_tm (unsigned long t, struct tm *tm)
{
	unsigned long days, rem;
	unsigned int y, mon;
	days = t/SECS_PER_DAY;
	rem = t - (days*SECS_PER_DAY);
	tm->tm_hour = rem / SECS_PER_HOUR;
	rem -= tm->tm_hour*SECS_PER_HOUR;
	tm->tm_min = rem / SECS_PER_MIN;
	rem -= tm->tm_min*SECS_PER_MIN;
	tm->tm_sec = rem;
	tm->tm_wday = (days + START_WDAY) % 7;
	y = BASE_YEAR;
	while (days >= 365) {
		if ((y % 4) == 0) {
			if (days == 365)
				break;
			/* leap year */
			days--;
		}
		days -= 365;
		y++;
	}
	tm->tm_year = y - 1900;
	tm->tm_yday = days;

	/* Set correct # of days for feburary */
	month_days[1] = ((y % 4) == 0) ? 29 : 28;

	for (mon = 0; mon < 12; mon++) {
		if (days < month_days[mon]) {
			tm->tm_mon = mon;
			break;
		}
		days -= month_days[mon];
	}
	if (mon == 12)  {
		/* PANIC */
		safe_print(printf ("secs_to_tm:remaining days=%d\n", (int)days));
	}

	tm->tm_mday = days + 1;
	tm->tm_isdst = 0;
	/* tm->tm_gmtoff = 0; */
}

void settimezone (int hours, int mins)
{
	tzoffset = hours*SECS_PER_HOUR + mins*SECS_PER_MIN;
}

struct tm *
my_localtime ( const time_t *timep)
{
	static struct tm tm;
	unsigned long t;

	t = *timep + tzoffset;
	secs_to_tm (t, &tm);
	return &tm;
}

struct tm *
gmtime (const time_t *timep)
{
	static struct tm tm;
	unsigned long t;

	t = *timep;
	secs_to_tm (t, &tm);
	return &tm;
}

time_t
time (time_t *tp)
{
	long int t;

	t = (long int) (cticks / TPS);
	if (tp)
		*tp = t;
	return t;
}
#endif /* INCLUDE_LOCAL_TIME */

time_t convLocalTimeToString(char *timeBuffer)
{
   time_t dateTime;
   struct tm *tmDateTime;

   time(&dateTime);
   tmDateTime = my_localtime((const time_t *)&dateTime);
   sprintf(timeBuffer, "%02d:%02d:%02d", tmDateTime->tm_hour,
	  tmDateTime->tm_min, tmDateTime->tm_sec);

   return(dateTime);
}


void set_rtc_clk()
{
 struct timeval the_gotten_time;
 struct tm *timeinfo;
 int cpu_sr;
 ///* commented to avoid potential problems */OS_ENTER_CRITICAL();
 gettimeofday(&the_gotten_time,NULL);
 timeinfo = my_localtime(&the_gotten_time.tv_sec);

 OS_ENTER_CRITICAL();
 rtcYear = timeinfo->tm_year;
 rtcMon =  timeinfo->tm_mon+1;
 rtcMday = timeinfo->tm_mday;
 rtcHour = timeinfo->tm_hour;
 rtcMin  = timeinfo->tm_min;
 rtcSec  = timeinfo->tm_sec;
 OS_EXIT_CRITICAL();

 ///* commented to avoid potential problems */  OS_EXIT_CRITICAL();
 //printf(" rtc Year: %d Month: %d Day: %d Hour: %d Min: %d Sec: %d\n", rtcYear,rtcMon,  rtcMday , rtcHour, rtcMin, rtcSec);
}

/*
 * This function sets the system clock time.  
 */
int setclock(alt_u32 seconds)
{
  int cpu_sr;
  struct timeval the_time, the_gotten_time;
  struct timezone zone;
  struct tm *timeinfo;
  static int is_first_call = 1;
  /* 
   * NTP Time is seconds since 1900 
   * Convert to Unix time which is seconds since 1970
   */
  seconds -= NTP_TO_UNIX_TIME;
  
  the_time.tv_sec = seconds;
  zone.tz_minuteswest = 8*60; //PST
  zone.tz_dsttime = 0; //TODO: need to change this to reflect PDT

  //safe_print(printf("Setting System Clock time to: %s\n",ctime(&the_time.tv_sec)));
  //settimeofday() can not be called at the same time as gettimeofday()
  //;
  if (is_first_call)
  {
    ///*?*/OS_ENTER_CRITICAL();
    settimezone(LINNUX_TIMEZONE_HOUR,LINNUX_TIMEZONE_MINUTE);
    // /*?*/OS_EXIT_CRITICAL();
    // /*?*/OS_ENTER_CRITICAL();
    settimeofday(&the_time, NULL);
    ///*?*/OS_EXIT_CRITICAL();
  } else
  {
   // /*?*/OS_ENTER_CRITICAL();
   settimeofday(&the_time, &zone);
   ///*?*/OS_EXIT_CRITICAL();
  }

  ///*?*/OS_ENTER_CRITICAL();
  gettimeofday(&the_gotten_time,NULL);
  timeinfo = my_localtime(&the_gotten_time.tv_sec);
  ///*?*/OS_EXIT_CRITICAL();
  //now set RTC variables in fatfs
  //printf(" Set time to: Year: %d Month: %d Day: %d Hour: %d Min: %d Sec: %d\n", timeinfo->tm_year,timeinfo->tm_mon,timeinfo->tm_mday, timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);
  /*rtcYear = timeinfo->tm_year;
  rtcMon =  timeinfo->tm_mon+1;
  rtcMday = timeinfo->tm_mday;
  rtcHour = timeinfo->tm_hour;
  rtcMin  = timeinfo->tm_min;
  rtcSec  = timeinfo->tm_sec;
  safe_print(printf(" rtc Year: %d Month: %d Day: %d Hour: %d Min: %d Sec: %d\n", rtcYear,rtcMon,  rtcMday , rtcHour, rtcMin, rtcSec));
  */


  return 0;
}

void * get_void_ptr_to_local_time()
{
	int cpu_sr;
	 struct timeval the_gotten_time;
	 struct tm *timeinfo;
	 ///*?*/OS_ENTER_CRITICAL();
	 gettimeofday(&the_gotten_time,NULL);
	 timeinfo = my_localtime(&the_gotten_time.tv_sec);
	 ///*?*/OS_EXIT_CRITICAL();
         return ((void *) timeinfo);
}

/*
 * This task is called once a second to update the LCD display with the 
 * current system time.  
 */
#ifdef LCD_DISPLAY_NAME
void lcddisplaytime_task(void *pdata)
{
  struct timeval time = {0, 0};
  struct timezone zone = {0, 0};
  struct tm time_struct;
  struct tm *pt_time_struct = &time_struct;
  alt_u8 char_array1[16];
  alt_u8 char_array2[16];
  INT8U  ucos_retcode = OS_NO_ERR;

  OSSemPend(lcd_sem, 0, &ucos_retcode);

  lcdDevice = fopen(LCD_DISPLAY_NAME, "w");
  if(lcdDevice < 0)
  {
    safe_print(printf("[displaytime]error opening lcd %s\n", strerror(errno)));
    exit(0);
  }
    
  while(1)
  {

   // OSSchedLock();
    if(gettimeofday(&time, &zone) < 0)
    {
      safe_print(printf("[displaytime]error get the time of day %s\n", strerror(errno)));
      exit(0);
    }
  //  OSSchedUnlock();
  

    pt_time_struct = gmtime(&time.tv_sec);
    
    lcdDevice = fopen(LCD_DISPLAY_NAME, "w");
      if(lcdDevice < 0)
        safe_print(printf("[displaytime]error opening lcd %s\n", strerror(errno)));
 
    fprintf(lcdDevice, "\x1b");
    fprintf(lcdDevice, "[2J");
  
    if(strftime(char_array1, 16, "%a %b %d,%Y", pt_time_struct) == 0)
    {
      safe_print(printf("[displaytime] Time string is two big for LCD"));
    }
    else
    {
      fprintf(lcdDevice,"%s\n", char_array1);
    }
  
    if(strftime(char_array2, 16, "%I:%M:%S %p GMT", pt_time_struct) == 0)
    {
      printf("[displaytime] Time string is two big for LCD");
    }
    else
    {
      fprintf(lcdDevice,"%s\n", char_array2);
    }
    fclose(lcdDevice);
    OSSemPost(lcd_sem);
    MyOSTimeDlyHMSM(0,0,1,0);
  }
  
}
#endif /* LCD_DISPLAY_NAME */

/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2004 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/
