.PHONY: all clean nuke

TARG=mark1

LAYOUT=\
	boot/stage1.bin\

all: $(TARG).img

clean:
	@rm -vf $(TARG).bin $(TARG).tmp $(LAYOUT)

nuke: clean
	@rm -vf $(TARG).img

$(TARG).img: $(TARG).bin
	dd if=/dev/zero of=$@.tmp bs=1k count=1440
	dd conv=notrunc if=$< of=$@.tmp
	@mv -v $@.tmp $@

$(TARG).bin: $(LAYOUT)
	cat $^ > $@

%.bin: %.asm
	nasm -f bin -w+orphan-labels -o $@ $<

include dev.make
