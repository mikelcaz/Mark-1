[bits 16]

load_ck:
; Like 'load' but prints a message and hangs itself on error.
	call load

	jnc .successful_load
	.load_failed:
		xor BX, BX
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
	ret
.drive_error db "!DRIVE:", 0
