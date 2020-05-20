
#ifndef REGFILE_IO_RW_CLASS_H_
#define REGFILE_IO_RW_CLASS_H_
#include "abstract_io_read_write_class.h"
#include <io.h>


class  regfile_io_rw_class : public abstract_io_read_write_class {
protected:
	unsigned long status_base;
	unsigned long control_base;
public:

	regfile_io_rw_class() {};
	regfile_io_rw_class(unsigned long controlBase,
			unsigned long statusBase) {
		this->set_control_base(controlBase);
		this->set_status_base(statusBase);

	}
    virtual ~regfile_io_rw_class();

	unsigned long get_control_base() const {
		return control_base;
	}

	void set_control_base(unsigned long controlBase) {
		control_base = controlBase;
	}

	unsigned long get_status_base() const {
		return status_base;
	}

	void set_status_base(unsigned long statusBase) {
		status_base = statusBase;
	}

	virtual unsigned long read(unsigned long addr) ;
	virtual void write (unsigned long addr, unsigned long data);
    virtual unsigned long read_status(unsigned long addr);


	virtual unsigned long get_status_bit(unsigned long addr, unsigned long bit){
		unsigned long  val;
		val = read_status(addr);
		return ((val & (((unsigned long)1) << bit)) != 0);
	}

	virtual unsigned long extract_status_bits(unsigned long addr, short lsb,short msb){
		unsigned long  val;
		val = read_status(addr);
		val = val >> lsb;
		val = val & (~(0xFFFFFFFF << (msb - lsb + 1)));
		return val;
	}


};

#endif 
