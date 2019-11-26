[bits 32]
[extern unhandled_interrupt]

align 4

global isrt_handlers_

%macro handler_base 1
	push %1 ; Using the IV index.
	jmp handler_common
%endmacro

%macro handler_symbol 1
	; To avoid decimal-hexadecimal inconsistencies,
	; the number is first loaded into a macro.
	%assign index %1
	global handler_%[index]
	handler_%[index]:
%endmacro

%macro handler_simple 1
	handler_symbol %1
	push 0
	handler_base %1
%endmacro

%macro handler_with_errcode 1
	handler_symbol %1
	handler_base %1
%endmacro

handler_common:
	pusha
	push DS
	push ES
	push FS
	push GS
	push SS

	; TODO: Don't hardcode the data selector.
	mov EAX, 0x10
	mov DS, EAX
	mov ES, EAX
	mov FS, EAX
	mov GS, EAX
	mov SS, EAX

	cld
	mov EAX, [ESP + 52]
	mov BL, 4
	mul BL
	add EAX, isrt.raw_func
	call [EAX]

	pop SS
	pop GS
	pop FS
	pop ES
	pop DS
	popa
	; Discard the error code and the IV index.
	add ESP, 2 * 4
	iret

isrt_handlers_:
isrt:
.handlers:
	%assign i 0
	%rep 256
		dd handler_%[i]
	%assign i (i + 1)
	%endrep
.raw_func:
	times 256 - ($ - isrt.raw_func) / 4 dd unhandled_interrupt

handler_simple 0x00
handler_simple 0x01
handler_simple 0x02
handler_simple 0x03
handler_simple 0x04
handler_simple 0x05
handler_simple 0x06
handler_simple 0x07
handler_with_errcode 0x08
handler_simple 0x09
handler_with_errcode 0x0A
handler_with_errcode 0x0B
handler_with_errcode 0x0C
handler_with_errcode 0x0D
handler_with_errcode 0x0E
handler_simple 0x0F

handler_with_errcode 0x10
handler_simple 0x11
handler_simple 0x12
handler_simple 0x13
handler_simple 0x14
handler_simple 0x15
handler_simple 0x16
handler_simple 0x17
handler_simple 0x18
handler_simple 0x19
handler_simple 0x1A
handler_simple 0x1B
handler_simple 0x1C
handler_simple 0x1D
handler_simple 0x1E
handler_simple 0x1F

%assign i 0x20
%rep 256 - i
	handler_simple i
%assign i (i + 1)
%endrep
