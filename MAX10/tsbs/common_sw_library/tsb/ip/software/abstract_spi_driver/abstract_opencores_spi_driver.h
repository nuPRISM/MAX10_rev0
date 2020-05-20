#ifndef ABSTRACT_OPENCORES_SPI_DRIVER_H
#define ABSTRACT_OPENCORES_SPI_DRIVER_H

#define SPI_CTRL_LSB_FIRST         0x800            /**< Endianess. Use big-endianess for multi-byte writes */
#define SPI_CTRL_INITIATE_TRANSFER 0x100

#define SPI_STAT_BUSY       0x100            /**< Controller busy status flag. Set while a transfer is underway (FSM has left the IDLE state) */
#define DRV_SPI_INSTANCE_CHANNELS_MAX 8
#define DRV_SPI_INSTANCE_COUNT 1


class abstract_opencores_spi_driver
{
protected:
    virtual void SPI_DATA32_READ(unsigned long BASE)=0;
    virtual unsigned long  SPI_DATA32_WRITE(unsigned long BASE,unsigned long data) = 0;
    
    virtual void  SPI_CTRL_WRITE(unsigned long BASE,unsigned long data)     = 0; /**< Control register */
    virtual void  SPI_CDIV_WRITE(unsigned long BASE,unsigned long data)     = 0;  /**< Clock divisor register */
    virtual void  SPI_CS_WRITE(unsigned long  BASE,unsigned long data)       = 0;  /**< Chip Select output pins */
    
    virtual unsigned long  SPI_CTRL_READ(unsigned long BASE)   =0; /**< Control register */
    virtual unsigned long  SPI_STAT_READ(unsigned long BASE)   =0;   /**< Status register */
    virtual unsigned long  SPI_CDIV_READ(unsigned long BASE)   =0;  /**< Clock divisor register */
    virtual unsigned long  SPI_CS_READ  (unsigned long BASE)   =0;/**< Chip Select output pins */


    unsigned long   base_clock_rate;
    unsigned long   baseaddress;
	bool            use_sdio_helper;
	virtual unsigned long  spi_calc_cdiv(unsigned long baudrate);
	void threadwait();
	bool spi_busy();
	unsigned long spi_transceive32(unsigned long val);
	unsigned long spi_received32();
	void spi_readblock(uint8_t* buf, int bufsize);
	void spi_writeblock(uint8_t* buf, int bufsize);
	std::string description;
public:
	void init_base_addr_and_clock_rate(unsigned long the_base_address,
			unsigned long the_base_clock_rate) {
		set_baseaddress(the_base_address);
		set_base_clock_rate(the_base_clock_rate);
	}

	;

	opencores_spi_driver()  : semaphore_locking_class() {
	}

	;

	opencores_spi_driver(unsigned long the_base_address,
			unsigned long the_base_clock_rate)  : semaphore_locking_class() {
		init_base_addr_and_clock_rate(the_base_address, the_base_clock_rate);
	}

	virtual void spi_open( unsigned long CTRL_SETTINGS, unsigned baudrate) = 0;
	virtual void spi_set_baudrate(unsigned long baudrate);
	virtual unsigned long spi_get_baudrate();
	virtual void spi_set_endianess(bool endianess);

	virtual unsigned long SPI_TransferData( unsigned long cs_word, char txSize, char* txBuf, char rxSize,
			char* rxBuf,  bool sdio_en_control = 0, int byte_to_switch_in = 100);


	
	virtual void set_base_clock_rate(unsigned long baseClockRate) {
		base_clock_rate = baseClockRate;
	}

	virtual void set_baseaddress(unsigned long baseaddress) {
		this->baseaddress = baseaddress;
	}

	virtual void set_cs_word(unsigned cs_word) = 0;
	virtual unsigned long get_cs_word(unsigned cs_word) = 0;

	std::string get_description() const {
		return description;
	}

	void set_description(std::string description) {
		this->description = description;
	}

};

#endif