; Copyright © 2019-2020 Mikel Cazorla Pérez
; This file is part of Mark 1,
; licensed under the terms of GPLv2.

[bits 32]

align 4

global inb

inb:
	mov DX, [esp + 4 + 0 * 4]
	xor EAX, EAX
	in AL, DX
	ret
