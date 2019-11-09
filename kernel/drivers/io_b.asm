[bits 32]

align 4

global inb
global outb

inb:
	mov DX, [esp + 4 + 0 * 4]
	xor EAX, EAX
	in AL, DX
	ret

outb:
	mov AL, [esp + 4 + 1 * 4]
	mov DX, [esp + 4 + 0 * 4]
	out DX, AL
	ret
