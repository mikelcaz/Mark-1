[bits 16]

stage_1:
	jmp $
times (0x200 - 2) - ($ - $$) nop
dw 0xAA55
