[bits 32]

align 4

global outb

outb:
	mov AL, [esp + 4 + 1 * 4]
	mov DX, [esp + 4 + 0 * 4]
	out DX, AL
	ret
