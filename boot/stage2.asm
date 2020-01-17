; Copyright © 2019-2020 Mikel Cazorla Pérez
; This file is part of Mark 1,
; licensed under the terms of GPLv2.

[bits 16]

[org 0x0000]

; The first stage must load as many sectors
; as the size of this one.
s2_sectors EQU 0x04

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

	call check_magic

	; The MBR should be at 0x7C00 already.
	call copy_mbr_payload

	; Retrieving drive geometry for further use.
	mov DL, [.boot_drive]
	call drive_geom
	jc .drive_geom_failure
	mov [.heads], DH
	mov [.sectors_and_cylinders], CX

	xor BX, BX
	mov AH, 0x0E
	mov SI, .end_boot_msg
	call print_string

	jmp bootmonitor
.drive_geom_failure:
	mov SI, .drive_geom_error
	call print_fatal

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
	; Ensure blinking is disabled (favouring color intensity).
	mov AX, 0x1003
	mov BH, 0x0000 + 0x00
	int 0x10
	call check_magic

	; MBR reloading.

	mov DL, [.boot_drive]
	mov DH, 0x00
	mov CX, 0x0001
	mov AL, 0x01

	; [ES:BX] destination.
	mov BX, 0x07C0
	mov ES, BX
	mov BX, 0x0000

	call load_ck
	call copy_mbr_payload

	jmp bootmonitor

.boot_drive db 0x00 ; It must be loaded at runtime.
; Boot drive geometry
.heads db 0x00
.sectors_and_cylinders dw 0x0000

.boot_drive_error db "!BOOTDRIVE:", 0
.incomplete_error db "!INCOMPLETE", 0
.drive_geom_error db "!DRIVE_GEOM", 0

%include 'boot/video_16.asm'
%include 'boot/print_16/hex.asm'
%include 'boot/print_16/string.asm'
%include 'boot/load_16.asm'
%include 'boot/load_ck_16.asm'
%include 'boot/drive_geom.asm'

check_magic:
	; Checking that the whole stage was loaded/overwritten.
	cmp word [s2_magic_number], 0xABD5
	je .ready
	.incomplete_load:
		mov AH, 0x0E
		mov SI, stage_2.incomplete_error
		call print_string
		jmp $
	.ready:
	ret

copy_mbr_payload:
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

zero_sized:
	mov SI, bootmonitor.f7_zero_size_error
	jmp print_fatal

print_fatal:
	mov AH, 0x0E
	xor BX, BX
	call print_string
	jmp $

times (0x200 - 72) - ($ - $$) nop

; All this must be loaded at runtime.
s2_mbr_payload:

; Disk signature.
	.signature dd 0x00000000
	.reserved dw 0x0000

; Partition table.
	.part_1 dq 0x000000000000000, 0x000000000000000
	.part_2 dq 0x000000000000000, 0x000000000000000
	.part_3 dq 0x000000000000000, 0x000000000000000
	.part_4 dq 0x000000000000000, 0x000000000000000

times (0x200 - 2) - ($ - $$) nop
dw 0x0000

%include 'boot/lba_chs.asm'

bootmonitor:
	.boot_indicator EQU +0
	.type_descriptor EQU +4
	.starting_sector EQU +8
	.part_size EQU +12

	.f7_first EQU +8
	.f7_size EQU +12
	.f7_padding EQU +16
	.f7_slots_1 EQU +19
	.f7_bitmap EQU +22

.begin:
	mov CX, 0
	mov BX, s2_mbr_payload.part_1

.search_f7:
	cmp CX, 4
	mov SI, .f7_not_found_error
	je print_fatal

	cmp byte [BX + .type_descriptor], 0xF7
	je .f7_found

	inc CX
	add BX, 16
	jmp .search_f7

.f7_found:
	mov AX, [BX + .part_size]
	cmp AX, 0
	jne .non_zero_sized
	mov AX, [BX + .part_size + 2]
	cmp AX, 0
	jne .non_zero_sized

	jmp zero_sized

.non_zero_sized:
	mov AX, [BX + .starting_sector]
	mov DX, [BX + .starting_sector + 2]

	push BX

	; F7h header loading.

	mov BL, [stage_2.heads]
	mov CX, [stage_2.sectors_and_cylinders]
	call lba2chs
	mov DL, [stage_2.boot_drive]
	mov AL, 0x01

	; [ES:BX] destination.
	mov BX, 0x07C0
	mov ES, BX
	mov BX, 0x0000

	call load_ck

	mov SI, .f7_signature
	xor DI, DI
	mov CX, .f7_signature_size

.check_signature:
	lodsb
	cmp AL, [ES:DI]
	jne .no_signature
	inc DI
	loop .check_signature

	pop BX

	; Note the number of free sectors is not actually integer.
	; The remainder is discarded here.
	mov EAX, (stage_2.stack_segment - 0x50) * 0x10 / 0x200 - s2_sectors
	cmp EAX, [ES:.f7_size]
	jae .slots_fit_in_memory
	mov SI, .f7_mem_oversize_error
	call print_fatal
.slots_fit_in_memory:

	xor EDX, EDX
	mov DX, [ES:.f7_padding]
	add EDX, [ES:.f7_size] ; Every = Size + Padding
	jc .overwrap
	mov EAX, [ES:.f7_first]

	xor CX, CX
	mov CL, [ES:.f7_slots_1]
	and CL, 0x0F
	call .compute_padding

	add EAX, [ES:.f7_size]
	jc .overwrap

	cmp EAX, [BX + .part_size]
	jbe .size_ok
	mov SI, .f7_part_oversize_error
	call print_fatal

.size_ok:
	add EAX, [BX + .starting_sector]
	jc .overwrap

	xor AX, AX
	mov AL, [ES:.f7_slots_1]
	and AL, 0x0F
	inc AX
	xor CX, CX
.find_first_active_slot:
	mov DX, [ES:.f7_bitmap]
	shr DX, CL
	and DX, 0x1
	jnz .found_active

	inc CX
	dec AX
	jnz .find_first_active_slot

	mov SI, .f7_no_active_slot_found
	call print_fatal

.found_active:
.check_load_0:
	xor AL, AL
	cmp AL, [ES:.f7_size]
	jb .check_load_255
	mov SI, .load_0_error
	call print_fatal
.check_load_255:
	mov AL, 0xFF
	cmp AL, [ES:.f7_size]
	jae .loadable_size
	mov SI, .load_255_error
	call print_fatal
.loadable_size:
	xor EDX, EDX
	mov DX, [ES:.f7_padding]
	add EDX, [ES:.f7_size] ; Every = Size + Padding
	xor EAX, EAX
	mov EAX, [ES:.f7_first]
	call .compute_padding
	add EAX, [BX + .starting_sector]

	push EAX
	pop AX
	pop DX
	mov BL, [stage_2.heads]
	mov CX, [stage_2.sectors_and_cylinders]
	call lba2chs
	mov DL, [stage_2.boot_drive]
	mov EAX, [ES:.f7_size]

	; [ES:BX] destination.
	mov BX, CS
	add BX, s2_sectors * 0x20
	mov ES, BX
	xor BX, BX

	call load_ck
	mov [.kernel_dest_offset], BX
	mov [.kernel_dest_segment], ES
	jmp far [.kernel_dest]

.compute_padding:
	; CX must be set.
	cmp CX, 0
	je .compute_padding_skip
	.compute_padding_loop:
		add EAX, EDX
		jc .overwrap
		loop .compute_padding_loop
	.compute_padding_skip:
	ret

.no_signature:
	mov SI, .f7_header_not_found_error
	call print_fatal

.overwrap:
	mov SI, .overwrap_error
	call print_fatal

.kernel_dest:
	; Order matters.
	.kernel_dest_offset dw 0x0000
	.kernel_dest_segment dw 0x0000

.overwrap_error db "Overwraps", 0
.ok_msg db "ok", 0
.load_0_error db "Cannot load 0 sectors", 0
.load_255_error db "Cannot load more than 255 sectors", 0

.f7_not_found_error db "Mark 1 partition not found", 0
.f7_zero_size_error db "Mark 1 partition size is 0", 0
.f7_header_not_found_error db "Mark 1 header not found", 0
.f7_mem_oversize_error db "Not enough safe memory for such slots", 0
.f7_part_oversize_error db "Slots exceed the Mark 1 partition size", 0
.f7_no_active_slot_found db "No active slot found", 0

.f7_signature_size EQU 8
.f7_signature db 0xF7, 0x00, "SYSIMG"

times (s2_sectors * 0x200 - 2) - ($ - $$) nop
s2_magic_number dw 0xABD5 ; 1010 101[1 1]101 0101
