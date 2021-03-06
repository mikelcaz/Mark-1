; Copyright © 2019-2020 Mikel Cazorla Pérez
; This file is part of Mark 1,
; licensed under the terms of GPLv2.

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

	; Stack setup for stage 1.
	mov BP, .stack_segment
	mov SS, BP
	mov SP, 0xFFFF

	; Data segment initialization.
	mov AX, 0x07C0
	mov DS, AX

	; BIOS stores the boot drive in this register.
	mov [.boot_drive], DL

	cld
	xor BX, BX

	call enforce_tty_video_mode
	mov AH, 0x0E
	int 0x10

	; Ensure blinking is disabled (favouring color intensity).
	mov AX, 0x1003
	mov BH, 0x0000 + 0x00
	int 0x10

	; Now that it is possible to show errors,
	; the boot drive number can be checked.
	; 0x80 and 0x00 are the only expected values.
	mov DL, [.boot_drive]
	test DL, ~0x80
	jz .it_seems_a_valid_drive_number
	.not_a_valid_drive_number:
		mov SI, .boot_drive_error
		call print_string
		call print_hex_b
		jmp $
	.it_seems_a_valid_drive_number:

	call a20.ensure_enabled

	; Second stage load.

	mov DL, [.boot_drive]
	mov DH, [.s2_head]
	mov CX, [.s2_cylinder_and_sector]
	mov AL, [.s2_insectors]

	; [ES:BX] destination.
	mov BX, [.s2_dest_segment]
	mov ES, BX
	mov BX, [.s2_dest_offset]

	call load_ck

	xor BX, BX
	mov AH, 0x0E
	mov AL, 'o'
	int 0x10

	; The second stage starts with a table of entry points.
	; Each entry in the table takes 2 bytes (short jmp).
	; The bootstrap entry point is the second in the table.
	mov BX, [.s2_dest_offset]
	add BX, 1 * 0x2
	mov [.s2_dest_offset], BX

	mov DL, [.boot_drive]
	jmp far [.s2_dest]

.boot_drive db 0x00 ; It must be loaded at runtime.
.s2_head db 0x00
.s2_cylinder_and_sector dw 0x0002
.s2_insectors db 0x04
.s2_dest:
	; Order matters.
	.s2_dest_offset dw 0x0000
	.s2_dest_segment dw 0x0050

.boot_drive_error db "!BOOTDRIVE:", 0

%include 'boot/video_16.asm'
%include 'boot/print_16/hex.asm'
%include 'boot/print_16/string.asm'
%include 'boot/load_16.asm'
%include 'boot/load_ck_16.asm'
%include 'boot/a20.asm'

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
dw 0xAA55 ; 1010 101[0 0]101 0101
