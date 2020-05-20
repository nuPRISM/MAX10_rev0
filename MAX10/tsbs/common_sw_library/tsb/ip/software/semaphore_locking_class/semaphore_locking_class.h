/*
 * semaphore_locking_class.h
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#ifndef SEMAPHORE_LOCKING_CLASS_H_
#define SEMAPHORE_LOCKING_CLASS_H_
extern "C" {
#include "includes.h"
#include "ucos_ii.h"
}

#include "basedef.h"
#include <stdio.h>
#include <string>

class semaphore_locking_class {
protected:
	OS_EVENT* the_semaphore_pointer;
public:
	semaphore_locking_class() {
		the_semaphore_pointer = NULL;
}

	semaphore_locking_class(OS_EVENT* theSemaphorePointer) {
		set_the_semaphore_pointer(theSemaphorePointer);
	}

virtual int lock();
virtual int unlock();

OS_EVENT* get_the_semaphore_pointer() const {
	return the_semaphore_pointer;
}

void set_the_semaphore_pointer(OS_EVENT* theSemaphorePointer) {
	the_semaphore_pointer = theSemaphorePointer;
}

virtual std::string get_semaphore_description() {
	return std::string("(No Semaphore Description Given)");
}

};

#endif /* SEMAPHORE_LOCKING_CLASS_H_ */
