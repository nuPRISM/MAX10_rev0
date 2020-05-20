/*
 * log_file_encapsulator.cpp
 *
 *  Created on: Nov 4, 2011
 *      Author: linnyair
 */

#include "log_file_encapsulator.h"
#include "chan_fatfs/fatfs_linnux_api.h"
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <map>
#include <float.h>
#include <vector>
#include <unistd.h>
#include <time.h>
#include <stdio.h>
#include <unistd.h>

/*
log_file_encapsulator::~log_file_encapsulator() {
	// TODO Auto-generated destructor stub
}

*/
void log_file_encapsulator::set_fileindex(int fileindex)
{
	this->fileindex = fileindex;
}

void log_file_encapsulator::set_filename(std::string filename)
{
	this->filename = filename;
}

void log_file_encapsulator::set_filestate(LINNUX_LOGFILE_STATES filestate)
{
	this->filestate = filestate;
}


log_file_encapsulator::log_file_encapsulator()
{
	set_fileindex(-1);
	set_filename("");
	set_filestate(LINNUX_LOGFILE_UNDEFINED);
}

int log_file_encapsulator::get_fileindex() const
		{
	return fileindex;
		}

std::string log_file_encapsulator::log_file_encapsulator::get_filename() const
		{
	return filename;
		}
LINNUX_LOGFILE_STATES log_file_encapsulator::get_filestate() const
		{
	return filestate;
		}

int log_file_encapsulator::open_for_write(std::string the_filename)
{
	int fopen_result = linnux_sd_card_file_open_for_write(the_filename);
	if (fopen_result != LINNUX_RETVAL_ERROR)
	{
		set_filestate(Linnux_LOGFILE_OPEN);
		set_filename(the_filename);
		set_fileindex(fopen_result);
		safe_print(std::cout << "Opened logfile: [" << the_filename << "] successfully with id: ["<<this->get_fileindex() << "] " << std::endl);

		return (get_fileindex());
	} else
	{
		safe_print(std::cout << "Error opening logfile: " << the_filename << std::endl);
		set_fileindex(-1);
		set_filename("");
		set_filestate(LINNUX_LOGFILE_ERROR);
		return LINNUX_RETVAL_ERROR;
	}
}

int log_file_encapsulator::close()
{
	safe_print(std::cout << "log_file_encapsulator: Entered close() member function " << std::endl);

	if (get_filestate() == Linnux_LOGFILE_OPEN)
	{
		if (linnux_sd_card_fclose(get_fileindex()))
		{
			set_filestate(LINNUX_LOGFILE_CLOSED);
			safe_print(std::cout << "log_file_encapsulator: Close file: [" << get_fileindex() << "] With File name: " << get_filename () << std::endl);
			return 1;
		} else
		{
			safe_print(std::cout << "Warning: log_file_encapsulator: Tried Unsuccessfully to close file index [" << get_fileindex() << "] filename: [" << get_filename() << "] that was in a non-open state of:" << (int) get_filestate() << std::endl);
			set_filestate(LINNUX_LOGFILE_ERROR);
			return 0;
		}
	} else
	{
		safe_print(std::cout << "Warning: log_file_encapsulator: Tried to close a non-open file file index [" << get_fileindex() << "] filename: [" << get_filename() << "] that was in a non-open state of:" << (int) get_filestate() << std::endl);
		return 0;
	}

}

int log_file_encapsulator::write_str(std::string the_str)
{
	std::string messagestr;
	if (get_filestate() == Linnux_LOGFILE_OPEN)
	{
		//safe_print(std::cout << "log_file_encapsulator: Writing string to logfile with file index  [" << get_fileindex() << "] filename: [" << get_filename() << "]" << std::endl);
		if (!(linnux_sd_card_write_string_to_file(get_fileindex(), the_str)))
		{
			//Let's try again. This is a logfile, after all
			safe_print(std::cout << "Error while writing string to logile: ["  << get_filename() << "], Gonna try again! " << std::endl);
			usleep(LINNUX_LOG_FILE_DISK_ERROR_WAIT_USEC); //sleep a little, allow SD card to recover
			messagestr = "\n\n\n==== Rewrite due to disk Error === [\n\n\n";
			messagestr.append(the_str).append("\n\n\n]==== End Rewrite due to disk Error ===\n");
			if (!linnux_sd_card_write_string_to_file(get_fileindex(),messagestr))
			{
				safe_print(std::cout << "Still Error while writing string to logile: ["  << get_filename() << "], aborting! " << std::endl);

				set_filestate(LINNUX_LOGFILE_ERROR);
				return (0);
			} else
			{
				safe_print(std::cout << "Second write OK while writing string to logile: ["  << get_filename() << "]! " << std::endl);
				//OK, we had to write twice, but it worked
				return (1);
			}
		} else
		{
			return (1);
		}
	}
	{
		safe_print(std::cout << "log_file_encapsulator: Error: Tried to write string: [" << the_str << "] To non-open log file  with file index  [" << get_fileindex() << "] filename: [" << get_filename() << "]" << std::endl);
		return (0);
	}
}

int log_file_encapsulator::is_open()
{
	return (get_filestate() == Linnux_LOGFILE_OPEN);
}

