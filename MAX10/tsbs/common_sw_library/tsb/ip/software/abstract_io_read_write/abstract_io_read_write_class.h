#ifndef ABSTRACT_IO_READ_WRITE_CLASS_H
#define ABSTRACT_IO_READ_WRITE_CLASS_H

class abstract_io_read_write_class
{
public:
  virtual unsigned long read(unsigned long addr) = 0;
  virtual void write (unsigned long addr, unsigned long data) = 0;
  
	virtual void turn_on_bit(unsigned long addr, unsigned long bit){
		unsigned long  val;
		val = read(addr);
		val = val | (((unsigned long)1) << bit);
		write(addr,val);
	};

	virtual void turn_off_bit(unsigned long addr, unsigned long bit){
		unsigned long  val;
		val = read(addr);
		val = val & (~(((unsigned long)1) << bit));
		write(addr,val);
	};

	virtual unsigned long get_bit(unsigned long addr, unsigned long bit){
		unsigned long  val;
		val = read(addr);
		return ((val & (((unsigned long)1) << bit)) != 0);
	}

	virtual unsigned long extract_bits(unsigned long addr, short lsb,short msb){
		unsigned long  val;
		val = read(addr);
		val = val >> lsb;
		val = val & (~(0xFFFFFFFFUL << (msb - lsb + 1)));
		return val;
	}

	virtual void replace_bit_range(unsigned long addr, unsigned short lsb, unsigned short msb, unsigned long the_new_data)
	{
		unsigned long the_data = read(addr);
		unsigned long sanitized_data = the_new_data & (~(0xFFFFFFFFUL << (msb - lsb + 1)));
		unsigned long new_data_mask = (~(0xFFFFFFFFUL << (msb - lsb + 1))) << lsb;
		the_data = (the_data & (~(new_data_mask))) | (sanitized_data << lsb);
		write(addr,the_data);
	}
};

#endif
