.PHONY: all clean nuke

TARG=\
	boot.img\
	kernel.img\

BOOT_LAYOUT=\
	boot/stage1.bin\
	boot/stage2.bin\

KERNEL_LAYOUT=\
	kernel32/kernel.bin\

# The 'entry' point must go first.
OKERNEL=\
	kernel32/entry.o\
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

kernel32/kernel.bin: $(OKERNEL)
	$(XCC) $(XLDFLAGS) -Ttext 0x0B00 -o $@ $^ $(XLDLIBS)

%.o: %.asm
	nasm -f elf -w+orphan-labels -o $@ $<

%.o: %.c
	$(XCC) $(XCFLAGS) -c -o $@ $<

CFLAGS=-Wall -Wextra -pedantic
XCC?=your-cross-gcc
XCFLAGS=-ffreestanding -mno-red-zone $(CFLAGS)
XLDFLAGS=-nostdlib -Wl,--oformat,binary
XLDLIBS=-lgcc
