#!/usr/sbin/dtrace -s

#pragma D option quiet

syscall::open*:entry
/execname=="iozone" & uid==29214/
{
	self->path = copyinstr(arg1);
}

syscall::open*:return
/self->path=="iozone.tmp"/
{
	total_time=0;
	size = 0;
	flag = 1; 
}

syscall::write:entry
/flag == 1/
{
	self->start_time = timestamp;
	self->w_size = arg1;	
	size = size + self->w_size;
}

syscall::write:return
/self->start_time > 0 & self->w_size > 0/
{
	self->stop_time = timestamp;
	self->elapsed = self->stop_time - self->start_time;
	total_time = total_time + self->elapsed; 
}


syscall::close*:entry
/self->path=="iozone.tmp"/
{
	printf("Size: %d\nElapsed Time: %d\n",size,total_time);
	flag = 0;
}
