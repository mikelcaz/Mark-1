[bits 16]

lba2chs:
; Converts a LBA to a CHS address.
; Arguments:
;	DX = LBA most significant bytes.
;	AX = LBA least significant bytes.
; Returns:
;	CF flag set on error, clear on success.
;	DH = head.
;	CL
;		0-5 = sector (in base 1).
;		6-7 = cylinder most significant bits (2/10).
;	CH = cylinder least significant bits (8/10).
	HPC EQU 16
	SPT EQU 63
	MAX_LBA EQU 0xFBFFF

	push BP
	push BX
	push DX
	push AX

	mov BP, SP

;	C = LBA / (HPC * SPT);
	mov EAX, [BP]
	cmp EAX, MAX_LBA
	ja .error

	xor EDX, EDX
	mov EBX, (HPC * SPT)
	div EBX

	mov CH, AL
	mov CL, AH
	shl CL, 6

;	S = (LBA % SPT) + 1;
;	H = (LBA / SPT) % HPC;

	mov EAX, [BP]
	xor EDX, EDX

	mov EBX, SPT
	div EBX

	inc DL
	or CL, DL

	xor EDX, EDX

	mov EBX, HPC
	div EBX

	shl DX, 8
	clc
.return:
	add SP, 4 ; Discard DX:AX
	pop BX
	pop BP
	ret

.error:
	stc
	jmp .return
