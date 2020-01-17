; Copyright © 2019-2020 Mikel Cazorla Pérez
; This file is part of Mark 1,
; licensed under the terms of GPLv2.

; G(ranularity, *4KiB)
; D/B (default operation size, 0 means 16 bits, 1 means 32 bits.)
; L(ong mode, i.e. 64-bit code descriptor, reserved for data segments.)
; AVL (whatever the OS wants.)

; P(resent)
; DPL[2] (Descriptor Privilege Level)
; S (0 means "system", 1 means "code or data".)
; TYPE bits:
;	#3: Code
;	#2: Conforming
;	#1: Readable (0 means "execute-only".)
;	#0: Accessed (set by the CPU when the segment is accessed.)

gdt:
	.code_sel EQU gdt.code - gdt.begin
	.data_sel EQU gdt.data - gdt.begin

.begin:
	; The first segment descriptor must be a null descriptor.
	dq 0x0000000000000000

.code:
	dw 0xFFFF ; Limit least significant bits (16/20)
	dw 0x0000 ; Base least significant bits (16/32)
	db 0x00 ; Base middle bits (8/32)
	db 10011010b ; P, DPL, S, Type
	db 11001111b ; G, D/B, L, AVL, Limit most significant bits (4/20)
	db 0x00 ; Base most significant bits (8/32)

.data:
	dw 0xFFFF ; Limit least significant bits (16/20)
	dw 0x0000 ; Base least significant bits (16/32)
	db 0x00 ; Base middle bits (8/32)
	db 10010010b ; P, DPL, S, Type
	db 11001111b ; G, D/B, L, AVL, Limit most significant bits (4/20)
	db 0x00 ; Base most significant bits (8/32)

.end:

; Must be loaded to the GDTR.
gdt_descriptor:
	.size dw gdt.end - gdt.begin - 1
	.start dd gdt.begin ; Be careful with the offset!
