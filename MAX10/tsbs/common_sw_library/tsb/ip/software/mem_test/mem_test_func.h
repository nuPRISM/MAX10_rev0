#ifndef ____MEM_TEST_H
#define ____MEM_TEST_H

int MemTestDataBus(unsigned int address);
int MemTestAddressBus(unsigned int memory_base, unsigned int nBytes);
int MemTest8_16BitAccess(unsigned int memory_base);
int MemTestDevice(unsigned int memory_base, unsigned int nBytes);

#endif