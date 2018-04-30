//add a bram
#include <stdio.h>
#include "382dma.h"

#define DMA_ADDR 0x40400000
#define BRAM_ADDR 0x43c00000
#define SRC_ADDR 0x1ffff000
#define CP_W 32
#define CP_LEN (CP_W * 4)

int main() {
    int dh = open("/dev/mem", O_RDWR | O_SYNC); // Open /dev/mem which represents the whole physical memory
    unsigned int* va_dma_cntl = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, DMA_ADDR); // Memory map AXI Lite register block
    unsigned int* va_src_addr  = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, SRC_ADDR); // Memory map source address
    unsigned int* va_bram_addr  = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, BRAM_ADDR); // Memory map source address

    //initializing 
    printf("Resetting DMA\n");
    dma_set(va_dma_cntl, MM2S_CONTROL_REGISTER, 4);
    dma_mm2s_status(va_dma_cntl);

    printf("Halting DMA\n");
    dma_set(va_dma_cntl, MM2S_CONTROL_REGISTER, 0);
    dma_mm2s_status(va_dma_cntl);
       
    //write src data
    int i;
    for(i=0;i< CP_W ;i++){
        //va_src_addr[i]= i+1;
        //va_src_addr[i]= 0xffffffff;
        va_src_addr[i]= i+1;
    }

    for(i=0;i< CP_W ;i++){
        va_bram_addr[i]= 0;
    }
   
    printf("the initial bram data is \n");
    for(i=0;i<CP_W;i++){
        printf("%d ", va_bram_addr[i]);;
    }
    printf("\n");


    //printf("Writing source address...\n");
    dma_set(va_dma_cntl, MM2S_START_ADDRESS, SRC_ADDR); // Write source address
    printf("this is the status after src address\n");
    dma_mm2s_status(va_dma_cntl);

    //printf("Starting MM2S channel with all interrupts masked...\n");
    dma_set(va_dma_cntl, MM2S_CONTROL_REGISTER, 0xf001);
    dma_mm2s_status(va_dma_cntl);

    //printf("Writing MM2S transfer length...\n");
    dma_set(va_dma_cntl, MM2S_LENGTH, CP_LEN);
    printf("mm2s length setting\n");
    dma_mm2s_status(va_dma_cntl);

    //printf("Waiting for MM2S synchronization...\n");
    dma_mm2s_sync(va_dma_cntl);
    
   // scanf("%d\n", &temp);

    printf("the final bram data is \n");
    for(i=0;i<CP_W;i++){
        printf("%d ", va_bram_addr[i]);;
    }
    printf("\n");
    return 0;
}
