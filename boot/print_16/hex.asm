[bits 16]

print_hex_b:
; Preconditions:
;	AH = 0x0E.
;	BX is properly set.
; Argument: DL.
; Modifies AL.
	; Most significant nibble.
	mov AL, DL
	shr AL, 4
	call print_hex_nibble

	; Less significant nibble.
	mov AL, DL
	and AL, 0xF
	call print_hex_nibble

	ret

print_hex_nibble:
; Preconditions:
;	AH = 0x0E.
;	BX is properly set.
; Argument: AL.
; Modifies AL.
	and AL, 0x0F
	cmp AL, 10
	jb .is_a_number
	.is_a_letter:
		add AL, 'A' - 10
		jmp .endif
	.is_a_number:
		add AL, '0'
	.endif:
	
	int 0x10
	ret
