.PHONY: run run64

run: $(TARG).img
	qemu-system-i386 $<

run64: $(TARG).img
	qemu-system-x86_64 $<
