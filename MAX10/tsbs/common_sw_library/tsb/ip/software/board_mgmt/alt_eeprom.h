
typedef struct device {
	unsigned long BaseAdress;
	unsigned long i2c_3bit_address;
	unsigned long i2c_7bit_address;
    int bytes_to_read;
    int size;
    int writeControlByte;
    int readControlByte;
} mem_device;

int readRandom_using_opencores_i2c(struct device *device, unsigned int address, unsigned char *buf, int len);
int writeRandom_using_opencores_i2c(struct device *device, unsigned int address, unsigned char *buf, int len);
/*
 void hexdump_eeprom(char *buf, int len, int offset);
*/
