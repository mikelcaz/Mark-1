smap:
.entries EQU 12
.table EQU .phys_table - correction
.phys_table:
	%rep .entries
		dq 0x0000000000000000 ; Base address.
		dq 0x0000000000000000 ; Length (ignore if the value is 0).
		dd 0x00000000 ; Type.
		; Only 20 bytes are actually used by the OS.
		; This ensures compatibility with 24-byte ACPI 3.X entries.
		dd 0x00000001 ; ACPI 3.0 Extended Attributes.
	%endrep

.SMAP EQU 'PAMS'

.read:
; Caution: registers not preserved.
	mov AX, DS
	mov ES, AX
	mov DI, .table

	xor EBX, EBX
	mov EDX, .SMAP
	mov EAX, 0xE820
	mov ECX, 24

	.next:
	.skip:
		int 0x15

		jc .done
		test EBX, EBX
		je .done

		; It could be trashed on some implementations.
		cmp EDX, .SMAP

		cmp EAX, EDX
		jne .eax_error

		mov EAX, 0xE820
		mov ECX, 24

		mov EBP, [ES:DI + 8 + 0]
		or EBP, [ES:DI + 8 + 4]
		test EBP, EBP
		je .skip

		cmp DI, .table + (.entries - 1) * 24
		je .not_enough_entries

		add DI, 24
	jmp .next

	.done:
		cmp DI, .table
		je .not_supported ; or single entry
	ret

.eax_error:
.not_supported:
.not_enough_entries:
	xor BX, BX
	mov AX, 0x0E00 + 'M'
	int 0x10
	cli
	hlt
	jmp $
