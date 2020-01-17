; Copyright © 2019-2020 Mikel Cazorla Pérez
; This file is part of Mark 1,
; licensed under the terms of GPLv2.

[bits 16]

drive_geom:
; Arguments:
;	DL = drive number.
; Returns:
;	CF flag set on error, clear on success.
;	DL = number of hard disk drives.
;	DH = last index of heads (in base 0).
;	CL[0-5] = last index of sectors per track (in base 1).
;	Last index of cylinder (in base 0):
;		CL[6-7] = most significant bits (2/10).
;		CH = least significant bits (8/10).
	push AX
	push BX
	push ES
	push DI

	; (To work around buggy BIOS.)
	xor DI, DI
	mov ES, DI
	;
	mov AH, 0x08
	int 0x13

	pop DI
	pop ES
	pop BX
	pop AX
	ret
