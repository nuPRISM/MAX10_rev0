
#include "uart_based_io_read_write_class.h"


   unsigned long uart_based_io_read_write_class::read(unsigned long addr) {
     return ((unsigned long) (uart_ptr->read_control_reg(addr,secondary_uart_num,NULL)));
   };
   void uart_based_io_read_write_class::write (unsigned long addr, unsigned long data){
        uart_ptr->write_control_reg(addr,data,secondary_uart_num,NULL);
   };

   unsigned long uart_based_io_read_write_class::read_status(unsigned long addr) {
       return ((unsigned long) (uart_ptr->read_status_reg(addr,secondary_uart_num,NULL)));
   };


