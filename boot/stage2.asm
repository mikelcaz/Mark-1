[bits 16]

[org 0x0000]

; The first stage must load as many sectors
; as the size of this one.
s2_sectors EQU 0x01

stage_2:
	; The stack spans over the last _ensured_ free segment
	; (i.e., 64 KiB from 0x70000 to 0x80000 - 1)
	; before the EBDA (Extended BIOS Data Area).
	.stack_segment EQU 0x7000
.begin:
	; For the time being,
	; the TTY video mode is taken for granted.

	; Data segment initialization.
	mov AX, CS
	mov DS, AX

	xor BX, BX
	mov AX, 0x0E00 + 'o'
	int 0x10

	; BIOS stores the boot drive in this register.
	mov [.boot_drive], DL

	; Stack setup for stage 2.
	mov BP, .stack_segment
	mov SS, BP
	mov SP, 0xFFFF

	cld
	xor BX, BX

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

	; Checking that the whole stage was loaded.
	cmp dword [s2_magic_number], 0x1DACED1C
	je .ready
	.incomplete_load:
		xor BX, BX
		mov AH, 0x0E
		mov SI, .incomplete_error
		call print_string
		jmp $
	.ready:

	xor BX, BX
	mov AH, 0x0E
	mov AL, 't'
	int 0x10

	jmp $

.boot_drive db 0x00 ; It must be loaded at runtime.

.boot_drive_error db "!BOOTDRIVE:", 0
.incomplete_error db "!INCOMPLETE", 0

%include 'boot/print_16/hex.asm'
%include 'boot/print_16/string.asm'

times (s2_sectors * 0x200 - 4) - ($ - $$) nop
s2_magic_number dd 0x1DACED1C ; 0x1CEDAC1D
