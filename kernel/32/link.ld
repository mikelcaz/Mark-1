OUTPUT_FORMAT("binary")

SECTIONS {
	. = 0x0B00;

	.start . :
	{
		kernel/32/entry.o(.text);
	}

	.text :
	{
		*(.text)
	}

	.rodata :
	{
		*(.rodata)
	}

	.data :
	{
		*(.data)
	}

	.bss :
	{
		*(COMMON)
		*(.bss)
	}

	_kernel_end = .;
}
