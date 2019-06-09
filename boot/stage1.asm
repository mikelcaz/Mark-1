[bits 16]

; The binary is expected to be loaded at 0x07C00, though.
[org 0x0000]

stage_1:
	; CS:IP canonization.
	jmp 0x07C0:.after_canonization
	.after_canonization:

	; Data segment initialization.
	mov AX, 0x07C0
	mov DS, AX

	; BIOS stores the boot drive in this register.
	; 0x80 and 0x00 are the only expected values.
	mov [.boot_drive], DL

	mov AH, 0x0E
	xor BX, BX

	mov AL, 'H'
	int 0x10
	mov AL, 'e'
	int 0x10
	mov AL, 'l'
	int 0x10
	mov AL, 'l'
	int 0x10
	mov AL, 'o'
	int 0x10
	mov AL, ','
	int 0x10
	mov AL, ' '
	int 0x10
	mov AL, 'W'
	int 0x10
	mov AL, 'o'
	int 0x10
	mov AL, 'r'
	int 0x10
	mov AL, 'l'
	int 0x10
	mov AL, 'd'
	int 0x10
	mov AL, '!'
	int 0x10
	mov AL, 0xD
	int 0x10
	mov AL, 0xA
	int 0x10

	jmp $

; It must be loaded at runtime.
.boot_drive db 0x00

times (0x200 - 72) - ($ - $$) nop

mbr_payload:

; Disk signature.
	.signature dd 0xBEBAFECA ; 0xCAFEBABE.
	.reserved dw 0x0000 ; 0x5A5A for read-only drives.

; Partition table.
	.part_1 dq 0x0000000000000000, 0x0000000000000000
	.part_2 dq 0x0000000000000000, 0x0000000000000000
	.part_3 dq 0x0000000000000000, 0x0000000000000000
	.part_4 dq 0x0000000000000000, 0x0000000000000000

times (0x200 - 2) - ($ - $$) nop
dw 0xAA55
