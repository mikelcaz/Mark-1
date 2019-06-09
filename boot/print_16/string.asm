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
