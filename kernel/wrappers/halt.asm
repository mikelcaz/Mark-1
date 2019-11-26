[bits 32]

align 4

global halt

halt:
	cli
	hlt
	jmp $
