/*
 * semaphore_locking_class.cpp
 *
 *  Created on: Feb 12, 2014
 *      Author: yairlinn
 */

#include "semaphore_locking_class.h"
#include <iostream>

int semaphore_locking_class::lock(){
	INT8U semaphore_err;
	if (get_the_semaphore_pointer() != NULL) {
		OSSemPend(get_the_semaphore_pointer(),	0, &semaphore_err);
		if (semaphore_err != OS_NO_ERR) {
			safe_print(std::cout << get_semaphore_description() << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__ << " Semaphore Error: "	<< semaphore_err << std::endl);
			return RETURN_VAL_ERROR;
		}
		return RETURN_VAL_TRUE;
	} else {
		safe_print(std::cout << get_semaphore_description() << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__ <<  " Error: Semaphore is NULL!" << std::endl);
		return RETURN_VAL_FALSE;
	}
	return RETURN_VAL_TRUE;
}



int semaphore_locking_class::unlock(){
	INT8U semaphore_err;
	if (get_the_semaphore_pointer() != NULL) {

		semaphore_err = OSSemPost(get_the_semaphore_pointer());

		if (semaphore_err != OS_NO_ERR) {
			safe_print(std::cout << get_semaphore_description() << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__ << " Semaphore Error: "	<< semaphore_err << std::endl);
			return RETURN_VAL_ERROR;
		}

		return RETURN_VAL_TRUE;
	} else {
		safe_print(std::cout << get_semaphore_description() << " File: " << __FILE__ << " Line: " << __LINE__ << " Func: " << __func__ <<  " Error: Semaphore is NULL!" << std::endl);
		return RETURN_VAL_FALSE;
	}
	return RETURN_VAL_TRUE;
}
