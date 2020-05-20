/*
 * telnet_quit_command_encapsulator.h
 *
 *  Created on: Dec 14, 2011
 *      Author: linnyair
 */

#ifndef TELNET_QUIT_COMMAND_ENCAPSULATOR_H_
#define TELNET_QUIT_COMMAND_ENCAPSULATOR_H_

class telnet_quit_command_encapsulator {
protected:
	unsigned int telnet_console_index;
public:

	//telnet_quit_command_encapsulator();
	//virtual ~telnet_quit_command_encapsulator();
    unsigned int get_telnet_console_index() const
    {
        return telnet_console_index;
    }

    void set_telnet_console_index(unsigned int telnet_console_index)
    {
        this->telnet_console_index = telnet_console_index;
    }

};

#endif /* TELNET_QUIT_COMMAND_ENCAPSULATOR_H_ */
