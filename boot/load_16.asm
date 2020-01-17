; Copyright © 2019-2020 Mikel Cazorla Pérez
; This file is part of Mark 1,
; licensed under the terms of GPLv2.

[bits 16]

load:
; Reads sectors from a drive.
; Arguments:
;	DL = drive number.
;	DH = head.
;	CL
;		0-5 = sector (in base 1).
;		6-7 = cylinder most significant bits (2/10).
;	CH = cylinder least significant bits (8/10).
;	AL = in-sectors.
;	[ES:BX] = destination.
; Returns:
;	CF flag set on error, clear on success.
;	AH = state (zero on success).
;	AL = count of read sectors.
	pusha

	mov BP, SP
	add BP, (8 - 1) * 2
	mov SI, 3
	.loop:
		mov AH, 0x02
		int 0x13
		jnc .something_loaded

		dec SI ; dec preserves CF.
		jz .error

		xor AH, AH
		int 0x13
		jc .error
	jmp .loop

	.something_loaded:
		cmp AL, [BP]
		je .success
		stc

	.unexpected_count:
	.success:
		mov [BP], AX
		popa
		ret

	.error:
		mov AL, 0x00 ; xor does not preserve CF.
		jmp .success
