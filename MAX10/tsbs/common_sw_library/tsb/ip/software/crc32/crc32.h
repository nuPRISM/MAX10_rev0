#ifndef CRC32_SIMPLE_CLASS_H
#define CRC32_SIMPLE_CLASS_H

#include <stdint.h>
#include <string>
class Crc32
{
public:
    Crc32();
    ~Crc32();
    void Reset();
    void AddData(const uint8_t* pData, const uint32_t length);
    const uint32_t GetCrc32();
	static uint32_t get_string_crc(std::string str);

private:
    uint32_t _crc;
};
#endif
