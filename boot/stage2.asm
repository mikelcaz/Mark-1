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

.entrypoints:
	jmp short .softreset
	times (1 * 0x2) - ($ - $$) nop
	jmp short .bootstrap
	times (2 * 0x2) - ($ - $$) nop

.bootstrap:
	; The stack was set up by the first stage.

	xor BX, BX
	mov AX, 0x0E00 + 'o'
	int 0x10

	; Data segment initialization.
	mov AX, CS
	mov DS, AX

	; BIOS stores the boot drive in this register.
	mov [.boot_drive], DL

	; DF flag was properly set by the first stage.

	test DL, ~0x80
	jz .it_seems_a_valid_drive_number
	.not_a_valid_drive_number:
		mov SI, .boot_drive_error
		call print_string
		call print_hex_b
		jmp $
	.it_seems_a_valid_drive_number:

	call .check_magic

	; The MBR should be at 0x7C00 already.
	call .copy_mbr_payload

	xor BX, BX
	mov AH, 0x0E
	mov AL, 't'
	int 0x10

	; TODO: Remove when done.
	jmp .softreset

	jmp $

.softreset:
	; Stack setup for stage 2.
	mov BP, .stack_segment
	mov SS, BP
	mov SP, 0xFFFF

	; Data segment initialization.
	mov AX, CS
	mov DS, AX

	cld
	xor BX, BX

	call enforce_tty_video_mode
	call .check_magic
	; TODO: reload the MBR.
	;call .copy_mbr_payload

	; TODO: Remove when done.
	xor BX, BX
	mov AH, 0x0E
	mov AL, 'X'
	int 0x10

	jmp $

.boot_drive db 0x00 ; It must be loaded at runtime.

.boot_drive_error db "!BOOTDRIVE:", 0
.incomplete_error db "!INCOMPLETE", 0

.check_magic:
	; Checking that the whole stage was loaded/overwritten.
	cmp word [s2_magic_number], 0xABD5
	je .ready
	.incomplete_load:
		mov AH, 0x0E
		mov SI, .incomplete_error
		call print_string
		jmp $
	.ready:
	ret

.copy_mbr_payload:
	; Copying the MBR payload from its copy at 0x7C00.
	; The MBR has to be reloaded in soft reset mode,
	; but it is already there when coming from stage 1.
	mov CX, 0x07C0
	mov DS, CX
	mov SI, 0x200 - 72

	mov CX, CS
	mov ES, CX
	mov DI, s2_mbr_payload

	mov CX, (70 - 2) / 4
	rep movsd
	movsw ; Copies the last two bytes.

%include 'boot/video_16.asm'
%include 'boot/print_16/hex.asm'
%include 'boot/print_16/string.asm'

times (0x200 - 72) - ($ - $$) nop

; All this must be loaded at runtime.
s2_mbr_payload:

; Disk signature.
	.signature dd 0x7ADAEDFE ; 0xFEEDDA7A.
	.reserved dw 0xEDFE ; FEED.

; Partition table.
	.part_1 dq 0x7ADAEDFE7ADAEDFE, 0x7ADAEDFE7ADAEDFE
	.part_2 dq 0x7ADAEDFE7ADAEDFE, 0x7ADAEDFE7ADAEDFE
	.part_3 dq 0x7ADAEDFE7ADAEDFE, 0x7ADAEDFE7ADAEDFE
	.part_4 dq 0x7ADAEDFE7ADAEDFE, 0x7ADAEDFE7ADAEDFE

times (0x200 - 2) - ($ - $$) nop
second_sector:

times (s2_sectors * 0x200 - 2) - ($ - $$) nop
s2_magic_number dw 0xABD5 ; 1010 101[1 1]101 0101
