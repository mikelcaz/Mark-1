; Copyright © 2019-2020 Mikel Cazorla Pérez
; This file is part of Mark 1,
; licensed under the terms of GPLv2.

[bits 16]

print_string:
; Preconditions:
;	AH = 0x0E.
;	BX is properly set.
;	DF flag is properly set.
; Argument: [DS:SI].
	push SI
	push AX

	jmp .init
	.loop:
		int 0x10
	.init:
		lodsb
		cmp AL, 0
	jne .loop

	pop AX
	pop SI
	ret
