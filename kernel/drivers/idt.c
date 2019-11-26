#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <asm.h>
#include <drivers/idt.h>

extern uchar idt_;
extern uchar isrt_handlers_;
extern void load_idt(void);

#define CODE_SEL 0x8

void
idt_reset(void)
{
	uchar *isrt = &isrt_handlers_;

	for (size_t i = 0; i < 256; ++i) {
		idt_install_isr(i, *(uintptr_t *)isrt);
		isrt += 4;
	}

	load_idt();
}

void
idt_install_isr(uint_fast8_t i, uintptr_t isr_addr)
{
	// TODO: Potential warnings in some compilers/platforms?
	if (256 <= i)
		return;

	uchar * const idt = &idt_ + 8 * (uintptr_t)i;

	// Lower offset
	idt[0] = isr_addr & 0xFF;
	idt[1] = isr_addr >> 8 & 0xFF;

	// Selector
	idt[2] = CODE_SEL;
	idt[3] = 0x00;

	// Reserved
	idt[4] = 0x00;

	// P, DPL, S and Type
	idt[5] = 0x8E;

	// Higher offset
	idt[6] = isr_addr >> 16 & 0xFF;
	idt[7] = isr_addr >> 24 & 0xFF;
}
