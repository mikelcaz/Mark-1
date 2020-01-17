; Copyright © 2019-2020 Mikel Cazorla Pérez
; This file is part of Mark 1,
; licensed under the terms of GPLv2.

[bits 16]

lba2chs:
; Converts a LBA to a CHS address.
; Arguments:
;	DX = LBA most significant bytes.
;	AX = LBA least significant bytes.
;	BL = HPC-1
;	CX[0-5] = SPT
; Returns:
;	CF flag set on error, clear on success.
;	DH = head.
;	CL
;		0-5 = sector (in base 1).
;		6-7 = cylinder most significant bits (2/10).
;	CH = cylinder least significant bits (8/10).
;
	MAX_LBA EQU 0xFBFFF

	push BP
	push BX
	push DX
	push AX

	mov BP, SP
	xor BH, BH
	inc BX
	and CX, 0x3F

	; Precomputing HPC * SPT.
	mov AX, CX
	mul BX
	push DX
	push AX

	push CX

;	C = LBA / (HPC * SPT);
	mov EAX, [BP]
	cmp EAX, MAX_LBA
	ja .error

	xor EDX, EDX
	mov EBX, [BP - 4] ; HPC * SPT
	div EBX

	mov CH, AL
	mov CL, AH
	shl CL, 6

;	S = (LBA % SPT) + 1;
;	H = (LBA / SPT) % HPC;

	mov EAX, [BP]
	xor EDX, EDX

	mov BX, [BP - 6] ; SPT
	and EBX, 0x3F
	div EBX

	inc DL
	or CL, DL

	xor EDX, EDX

	mov BX, [BP + 4] ; HPC
	and EBX, 0xFF
	inc EBX
	div EBX

	shl DX, 8
	clc
.return:
	; Discard SPT, (HPC * SPT) and DX:AX.
	add SP, 2 + 2 * 4

	pop BX
	pop BP
	ret

.error:
	stc
	jmp .return
