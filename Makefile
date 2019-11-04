.PHONY: all clean nuke

TARG=\
	boot.img\
	kernel.img\

BOOT_LAYOUT=\
	boot/stage1.bin\
	boot/stage2.bin\

KERNEL_LAYOUT=\
	kernel32/entry.bin\
	kernel32/kernel.bin\

OKERNEL=\
	kernel32/kernel.o\

all: $(TARG)

clean:
	@rm -vf $(BOOT_LAYOUT) $(KERNEL_LAYOUT) $(OKERNEL)

nuke: clean
	@rm -vf $(TARG)

boot.img: $(BOOT_LAYOUT)
	cat $^ > $@

kernel.img: $(KERNEL_LAYOUT)
	cat $^ > $@

%.bin: %.asm
	nasm -f bin -w+orphan-labels -o $@ $<

kernel32/kernel.bin: kernel32/kernel.o
	$(XCC) $(XLDFLAGS) -Ttext 0x0D00 -o $@ $^ $(XLDLIBS)

%.o: %.c
	$(XCC) $(XCFLAGS) -c -o $@ $<

XCC?=your-cross-gcc
XCFLAGS=-ffreestanding -mno-red-zone
XLDFLAGS=-nostdlib -Wl,--oformat,binary
XLDLIBS=-lgcc
