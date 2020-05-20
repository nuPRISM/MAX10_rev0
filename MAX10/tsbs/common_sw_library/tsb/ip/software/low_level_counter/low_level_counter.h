/*
 * low_level_counter.h
 *
 *  Created on: Jun 29, 2017
 *      Author: user
 */

#ifndef LOW_LEVEL_COUNTER_H_
#define LOW_LEVEL_COUNTER_H_

#include <string>

namespace llvcnt {

class low_level_counter {

protected:
	unsigned long base;
    std::string name;

public:
	low_level_counter();
	low_level_counter(std::string name, unsigned long base);
	unsigned long long get_timestamp();
	virtual ~low_level_counter();

	unsigned long get_base() const {
		return base;
	}

	void set_base(unsigned long base) {
		this->base = base;
	}

	const std::string& get_name() const {
		return name;
	}

	void set_name(const std::string& name) {
		this->name = name;
	}
};

} /* namespace llvcnt */

#endif /* LOW_LEVEL_COUNTER_H_ */
