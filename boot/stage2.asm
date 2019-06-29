[bits 16]

[org 0x0000]

stage_2:
.begin:
	xor BX, BX
	mov AH, 0x0E
	mov AL, ':'
	int 0x10
	mov AH, 0x0E
	mov AL, ')'
	int 0x10
