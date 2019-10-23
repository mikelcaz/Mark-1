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
	mov SI, .end_boot_msg
	call print_string

	jmp .bootmonitor
.end_boot_msg db 't', 0xD, 0xA, 0

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

	; MBR reloading.

	mov DL, [.boot_drive]
	mov DH, 0x00
	mov CX, 0x0001
	mov AL, 0x01

	; [ES:BX] destination.
	mov BX, 0x07C0
	mov ES, BX
	mov BX, 0x0000

	call load

	mov BX, 0x0000 ; xor does not preserve CF.

	jnc .successful_load
	.load_failed:
		mov DX, AX
		mov AH, 0x0E
		mov SI, .drive_error
		call print_string
		rol DX, 8
		call print_hex_b
		rol DX, 8
		call print_hex_b
		jmp $

	.successful_load:
	call .copy_mbr_payload

	jmp .bootmonitor

.bootmonitor:
	jmp $

.boot_drive db 0x00 ; It must be loaded at runtime.

.boot_drive_error db "!BOOTDRIVE:", 0
.drive_error db "!DRIVE:", 0
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
	push AX
	mov AX, DS

	mov CX, 0x07C0
	mov DS, CX
	mov SI, 0x200 - 72

	mov CX, CS
	mov ES, CX
	mov DI, s2_mbr_payload

	mov CX, (70 - 2) / 4
	rep movsd
	movsw ; Copies the last two bytes.

	mov DS, AX
	pop AX
	ret

%include 'boot/video_16.asm'
%include 'boot/print_16/hex.asm'
%include 'boot/print_16/string.asm'
%include 'boot/load_16.asm'

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
