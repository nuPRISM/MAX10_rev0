#ifndef UART_BASED_IO_READ_WRITE_CLASS_H
#define UART_BASED_IO_READ_WRITE_CLASS_H
#include "uart_register_file.h"
#include "regfile_io_rw_class.h"

class uart_based_io_read_write_class : public regfile_io_rw_class
{
protected:
   unsigned long secondary_uart_num;
   uart_register_file* uart_ptr;
public:
   uart_based_io_read_write_class() {};
   uart_based_io_read_write_class(uart_register_file* uart_ptr, 
   unsigned long secondary_uart_num = 0) {
     this->uart_ptr = uart_ptr;
     this->secondary_uart_num = secondary_uart_num;
   };
   
   virtual unsigned long read(unsigned long addr) ;
   virtual void write (unsigned long addr, unsigned long data);
   virtual unsigned long read_status(unsigned long addr);

};



#endif
