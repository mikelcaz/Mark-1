.PHONY: all clean nuke

TARG=\
	boot.img\
	kernel.img\

BOOT_LAYOUT=\
	boot/stage1.bin\
	boot/stage2.bin\

KERNEL_LAYOUT=\
	kernel/32/kernel.bin\

OKERNEL=\
	kernel/32/entry.o\
	kernel/32/kernel.o\
	kernel/drivers/io_b.o\
	kernel/drivers/framebuffer.o\
	kernel/32/libcmin.a\

OLIBCMIN=\
	kernel/32/string.o\
	kernel/32/strings.o\

all: $(TARG)

clean:
	@rm -vf $(BOOT_LAYOUT) $(KERNEL_LAYOUT) $(OKERNEL) $(OLIBCMIN)

nuke: clean
	@rm -vf $(TARG)

boot.img: $(BOOT_LAYOUT)
	cat $^ > $@

kernel.img: $(KERNEL_LAYOUT)
	cat $^ > $@

%.bin: %.asm
	nasm -f bin -w+orphan-labels -o $@ $<

kernel/32/kernel.bin: $(OKERNEL)
	$(XCC) $(XLDFLAGS) -T kernel/32/link.ld -o $@ $^ $(XLDLIBS)

kernel/32/libcmin.a: $(OLIBCMIN)
	ar crsv $@ $^

%.o: %.asm
	nasm -f elf -w+orphan-labels -o $@ $<

kernel/32/%.o: libcmin/%.c
	$(XCC) $(XCFLAGS) -Ilibcmin/include -c -o $@ $<

%.o: %.c
	$(XCC) $(XCFLAGS) -Ikernel/include -Ilibcmin/include -c -o $@ $<

CFLAGS=-Wall -Wextra -pedantic

XCC?=your-cross-gcc
XCFLAGS=-ffreestanding -mno-red-zone $(CFLAGS)
XLDFLAGS=-nostdlib
XLDLIBS=-lgcc
