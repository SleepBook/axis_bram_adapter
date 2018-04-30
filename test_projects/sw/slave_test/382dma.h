#ifndef _382_DMA_H_
#define _382_DMA_H_

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/mman.h>

#define MM2S_CONTROL_REGISTER 0x00
#define MM2S_STATUS_REGISTER 0x04
#define MM2S_START_ADDRESS 0x18
#define MM2S_LENGTH 0x28

#define S2MM_CONTROL_REGISTER 0x30
#define S2MM_STATUS_REGISTER 0x34
#define S2MM_DESTINATION_ADDRESS 0x48
#define S2MM_LENGTH 0x58

unsigned int dma_set(unsigned int* dma_virtual_address, int offset, unsigned int value);

unsigned int dma_get(unsigned int* dma_virtual_address, int offset);

void dma_s2mm_status(unsigned int* dma_virtual_address);

void dma_mm2s_status(unsigned int* dma_virtual_address);

int dma_mm2s_sync(unsigned int* dma_virtual_address);

int dma_s2mm_sync(unsigned int* dma_virtual_address);

void memdump(void* virtual_address, int byte_count);

#endif
