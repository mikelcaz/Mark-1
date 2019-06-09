[bits 16]

stage_1:
	jmp $

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
