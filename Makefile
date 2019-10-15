.PHONY: all clean nuke

NAME=mark1

TARG=\
	boot.img\
#	$(NAME).img\

BOOT_LAYOUT=\
	boot/stage1.bin\
	boot/stage2.bin\

all: $(TARG)

clean:
	@rm -vf $(BOOT_LAYOUT)

nuke: clean
	@rm -vf $(TARG)

boot.img: $(BOOT_LAYOUT)
	cat $^ > $@

%.bin: %.asm
	nasm -f bin -w+orphan-labels -o $@ $<
