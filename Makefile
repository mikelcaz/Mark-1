.PHONY: all clean nuke

TARG=\
	boot.img\
	kernel.img\

BOOT_LAYOUT=\
	boot/stage1.bin\
	boot/stage2.bin\

KERNEL_LAYOUT=\
	kernel/entry.bin\

all: $(TARG)

clean:
	@rm -vf $(BOOT_LAYOUT) $(KERNEL_LAYOUT)

nuke: clean
	@rm -vf $(TARG)

boot.img: $(BOOT_LAYOUT)
	cat $^ > $@

kernel.img: $(KERNEL_LAYOUT)
	cat $^ > $@

%.bin: %.asm
	nasm -f bin -w+orphan-labels -o $@ $<
