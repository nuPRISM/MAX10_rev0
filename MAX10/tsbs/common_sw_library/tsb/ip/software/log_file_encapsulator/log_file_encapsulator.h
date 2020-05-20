/*
 * log_file_encapsulator.h
 *
 *  Created on: Nov 4, 2011
 *      Author: linnyair
 */

#ifndef LOG_FILE_ENCAPSULATOR_H_
#define LOG_FILE_ENCAPSULATOR_H_

#include "basedef.h"
#include <string>

class log_file_encapsulator {
protected:
	std::string filename;
	int fileindex;
	LINNUX_LOGFILE_STATES filestate;
    void set_fileindex(int fileindex);
    void set_filename(std::string filename);
    void set_filestate(LINNUX_LOGFILE_STATES filestate);

public:
	log_file_encapsulator();
    int get_fileindex() const;
    std::string get_filename() const;
    LINNUX_LOGFILE_STATES get_filestate() const;
	int open_for_write(std::string the_filename);
	int close();
	int write_str(std::string the_str);
	int is_open();
	//virtual ~log_file_encapsulator();
};

#endif /* LOG_FILE_ENCAPSULATOR_H_ */
