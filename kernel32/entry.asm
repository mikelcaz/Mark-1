[bits 16]
[extern kmain]

global _start

; The origin is at 'correction'. It is relevant for the 32-bit part.
; However, the 16-bit part is reached as [XXXXh:0000h],
; hence the need of accounting it.
s2_sectors EQU 3
correction EQU 0x0500 + s2_sectors * 0x200

_start:
	jmp entry_16

entry_32_addr:
	; Order matters.
	.offset dw entry_32 ; Be careful with the offset!
	.segment dw gdt.code_sel

%include 'kernel32/gdt.asm'

entry_16:
	mov AX, 0x0E00 + 'K'
	xor BX, BX
	int 0x10

	mov AX, CS
	mov DS, AX

	cli
	lgdt [gdt_descriptor - correction]

	mov EAX, CR0
	or EAX, 0x1
	mov CR0, EAX

	jmp far [entry_32_addr - correction]


[bits 32]

entry_32:
	.video_mem EQU 0xB8000
	.white_on_black EQU 0x07
	.blue_on_white EQU 0xF9
.begin:
	mov AX, gdt.data_sel
	mov DS, AX
	mov ES, AX
	mov FS, AX
	mov GS, AX
	mov SS, AX

	; TODO: Limit the stack growing in the GDT.
	mov EBP, 0x70000
	mov ESP, EBP

	call kmain
	jmp $
