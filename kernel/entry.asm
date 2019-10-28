[bits 16]

mov AX, 0x0E00 + 'K'
xor BX, BX
int 0x10
jmp $
