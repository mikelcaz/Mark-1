[bits 16]

a20:
.signature_offset EQU 0x1FE
.ensure_enabled:
	call a20.check
	jne .enabled
		call a20.BIOS_enable
		call a20.check
		jne .enabled

		mov SI, .disabled_error
		jmp .print_error
	.enabled:
	ret

.check:
; Sets ZF if A20 line is disabled, cleans it otherwise.
	push ES
	push AX

	mov AX, 0xFFFF
	mov ES, AX

	mov AX, [DS:.signature_offset]
	cmp AX, 0xAA55
	je .signature_found
		mov SI, .missing_signature_error
		jmp .print_error

	.signature_found:
	cmp AX, [ES:0x0010 + 0x7DFE]
	jne .checked

	rol AX, 8
	mov [DS:.signature_offset], AX

	cmp AX, [ES:0x0010 + 0x7DFE]
	rol AX, 8
	mov [DS:.signature_offset], AX

	.checked:
	pop AX
	pop ES
	ret

.BIOS_disable:
	push AX
	mov AX, 0x2400
	int 0x15
	pop AX
	ret

.BIOS_enable:
	push AX
	mov AX, 0x2401
	int 0x15
	pop AX
	ret

.print_error:
	mov AH, 0x0E
	xor BX, BX
	call print_string
	jmp $

.disabled_error db "!A20", 0
.missing_signature_error db "!SIG", 0
