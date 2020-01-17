; Copyright © 2019-2020 Mikel Cazorla Pérez
; This file is part of Mark 1,
; licensed under the terms of GPLv2.

[bits 16]

enforce_tty_video_mode:
; Ensures the default TTY video mode (0x03) is set.
; Returns:
;	AL = 'B' (if the video mode was already right).
;	AL = 'V' (if it was necessary to change it).
	push BX
	mov BL, AH

	; Getting the video mode.
	; Returns:
	;	AL = Video mode.
	;	AH = Number char columns.
	;	BH = Active page.
	mov AH, 0x0F
	int 0x10

	cmp AL, 0x03
	jne .non_set
	.already_set:
		mov AL, 'B'
		jmp .endif
	.non_set:
		call set_tty_video_mode
	.endif:

	mov AH, BL
	pop BX
	ret

set_tty_video_mode:
; Modifies AX.
; Returns:
;	AL = 'V'.

	; AH = 0x00 Set video mode.
	; AL = 0x03 Text default mode.
	mov AX, 0x0003
	int 0x10

	mov AL, 'V'
	ret
