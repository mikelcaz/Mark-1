[bits 16]

; The binary is expected to be loaded at 0x07C00, though.
[org 0x0000]

stage_1:
	; The stack spans over the last _ensured_ free segment
	; (i.e., 64 KiB from 0x70000 to 0x80000 - 1)
	; before the EBDA (Extended BIOS Data Area).
	.stack_segment EQU 0x7000
.begin:
	; CS:IP canonization.
	jmp 0x07C0:.after_canonization
	.after_canonization:

	; Data segment initialization.
	mov AX, 0x07C0
	mov DS, AX

	; BIOS stores the boot drive in this register.
	mov [.boot_drive], DL

	; Stack setup for stage 1.
	mov BP, .stack_segment
	mov SS, BP
	mov SP, 0xFFFF

	cld
	xor BX, BX

	call enforce_tty_video_mode
	mov AH, 0x0E
	int 0x10

	mov SI, .hello
	mov DL, 0x12
	call print_string
	call print_hex_b

	jmp $

; It must be loaded at runtime.
.boot_drive db 0x00

.hello db 'Hello, World!', 0

%include 'boot/video_16.asm'
%include 'boot/print_16/hex.asm'
%include 'boot/print_16/string.asm'

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
