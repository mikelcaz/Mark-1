[bits 32]

align 4

global inb

inb:
	mov DX, [esp + 4 + 0 * 4]
	xor EAX, EAX
	in AL, DX
	ret
