#include<stdio.h>
#include<stdlib.h>
#include<linux/nvme_ioctl.h>
#include<sys/ioctl.h>
#include<fcntl.h>
#include<time.h>
#include<string.h>




int main(int argc, char* argv[]){
	int fd = 0;

	struct nvme_passthru_cmd nvme_cmd;
	memset(&nvme_cmd,0,sizeof(nvme_cmd));
	
	fd = open("/dev/nvme1n1",O_RDWR);
 	// fd = open("/dev/nvme0n1p1",O_RDWR);

	nvme_cmd.opcode = 0x12;
	nvme_cmd.addr =0;
	nvme_cmd.nsid = 1;
	nvme_cmd.data_len = 0;
	nvme_cmd.cdw10 = 0;
	nvme_cmd.cdw11 = 0;
	nvme_cmd.cdw12 = 0;

	

	int ret;
	ret = ioctl(fd,NVME_IOCTL_IO_CMD,&nvme_cmd);
	

	if(ret==0)printf("successful\n");
		else printf("failed %d\n",ret); 

return 0;
}
