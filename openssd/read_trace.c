#include<stdio.h>
#include<stdlib.h>
#include<linux/nvme_ioctl.h>
#include<sys/ioctl.h>
#include<fcntl.h>
#include<time.h>
#include<string.h>


#define TOTAL             128
#define SECTORS           4
#define SIZE              (4096 * SECTORS)
#define SIZE_PER_BLOCK    (SIZE * TOTAL)
// #define MB_PER_BLOCK SIZE_PER_BLOCK/(1024*1024)

#pragma pack(push, 1)
typedef struct ENTRY{
  unsigned int lpa : 32;
  unsigned int ppa : 32;
  long long unsigned int timestamp : 60;
  unsigned int cache_hit_miss : 1;
  unsigned int request_type : 2;
  unsigned int empty : 1;
} TRACE_ENTRY, *P_ENTRY;
#pragma pack(pop)

#define IO_TRACE_SIZE (sizeof(TRACE_ENTRY))
#define TRACE_NUM_PER_BLOCK ((2 * SIZE_PER_BLOCK / IO_TRACE_SIZE) / 2)

typedef struct _ENTRY_LIST{
    TRACE_ENTRY entry[TRACE_NUM_PER_BLOCK];
} TRACE_LIST, *P_LIST;


int main(int argc, char* argv[]){
  // printf("each trace has size %d\n", IO_TRACE_SIZE);
  int fd = 0;

  struct nvme_passthru_cmd nvme_cmd;
  memset(&nvme_cmd,0,sizeof(nvme_cmd));

  unsigned char buffer[SIZE_PER_BLOCK];
  unsigned int lba_max = atoi(argv[1]);
  
  fd = open("/dev/nvme1n1", O_RDWR);

  for (unsigned int lba = 0; lba < lba_max; lba++) {
    for (unsigned int i = 0; i < 128; i++) {
      nvme_cmd.opcode = 0x10;
      nvme_cmd.addr = buffer + i * SIZE;
      nvme_cmd.nsid = 1;
      nvme_cmd.data_len = SIZE;
      nvme_cmd.cdw10 = lba * 128 + i;
      nvme_cmd.cdw11 = 0;
      nvme_cmd.cdw12 = SECTORS - 1;
      
      int ret;
      ret = ioctl(fd, NVME_IOCTL_IO_CMD, &nvme_cmd);
      if (ret == 0) printf("%d successful\n", i);
      else printf("%d failed %d\n", i, ret); 
    }
  
    P_LIST a = (P_LIST)(buffer);
    for (unsigned int i = 0; i < TRACE_NUM_PER_BLOCK; i++) {
        TRACE_ENTRY b = a->entry[i];
        printf("%d TIME:%llu LPA:%u PPA:%u TYPE:%u HIT:%u\n", i, b.timestamp, b.lpa, b.ppa, b.request_type, b.cache_hit_miss);
    }
  }
  return 0;
}
