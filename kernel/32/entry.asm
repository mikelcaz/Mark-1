; Copyright © 2019-2020 Mikel Cazorla Pérez
; This file is part of Mark 1,
; licensed under the terms of GPLv2.

[bits 16]
[extern kmain]
[extern halt]

align 4

global _start
global idt_
global smap_
global load_idt

; The origin is at 'correction'. It is relevant for the 32-bit part.
; However, the 16-bit part is reached as [XXXXh:0000h],
; hence the need of accounting it.
s2_sectors EQU 4
correction EQU 0x0500 + s2_sectors * 0x200

_start:
	jmp entry_16

entry_32_addr:
	; Order matters.
	.offset dw entry_32 ; Be careful with the offset!
	.segment dw gdt.code_sel

times (8 - ($ - $$) % 8) db 0x00
idt_:
%include 'kernel/32/idt.asm'

times (8 - ($ - $$) % 8) db 0x00
%include 'kernel/32/gdt.asm'

times (8 - ($ - $$) % 8) db 0x00
smap_:
%include 'kernel/32/smap.asm'

entry_16:
	mov AX, 0x0E00 + 'K'
	xor BX, BX
	int 0x10

	mov AX, CS
	mov DS, AX

	call smap.read

	cli
	lgdt [gdt_descriptor - correction]

	mov EAX, CR0
	or EAX, 0x1
	mov CR0, EAX

	jmp far [entry_32_addr - correction]


[bits 32]

entry_32:
.begin:
	mov EAX, gdt.data_sel
	mov DS, EAX
	mov ES, EAX
	mov FS, EAX
	mov GS, EAX
	mov SS, EAX

	; TODO: Limit the stack growing in the GDT.
	mov ESP, 0x70000

	call kmain
	jmp halt

load_idt:
	lidt [idt_descriptor]
	ret
