; Copyright © 2019-2020 Mikel Cazorla Pérez
; This file is part of Mark 1,
; licensed under the terms of GPLv2.

idt:
.begin:
	times (256 * 8) db 0x00
.end:

; Must be loaded to the IDTR after setting up the PICs and the IDT.
idt_descriptor:
	.size dw idt.end - idt.begin - 1
	.start dd idt.begin ; Be careful with the offset!
