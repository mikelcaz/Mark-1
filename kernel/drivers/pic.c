// IRQ0-7 are mapped to 0x08-0x0F interrupt vectors by default.
// These IVs overlap with architecture-defined exceptions
// (which take 0x00-0x1F IVs), whereas 0x20-0xFF are free to use.
// Note IRQ8-F are mapped to 0x70-0x77 IVs by default.

#include <stdint.h>
//
#include <drivers/io_b.h>
#include <drivers/pic.h>

#define PIC1_CMD 0x20
#define PIC2_CMD 0xA0
#define PIC1_DATA (PIC1_CMD + 1)
#define PIC2_DATA (PIC2_CMD + 1)

#define PIC1_OFFSET 0x20
#define PIC2_OFFSET (PIC1_OFFSET + 8)

// Initialization Command (8-bit) words
#define ICW1 0x11 // Cascade mode.
#define ICW4 0x01 // 8086/88 mode.

#include "pic_macros.h"

// The caller of this function must set the mask at the end.
static void
raw_remap(void)
{
	outb(PIC1_CMD, ICW1);
	outb(PIC2_CMD, ICW1);

	outb(PIC1_DATA, PIC1_OFFSET);
	outb(PIC2_DATA, PIC2_OFFSET);

	// Slave PIC at IRQ2.
	outb(PIC1_DATA, 0x1 << 2);
	// Is slave through IRQ2.
	outb(PIC2_DATA, 0x02);

	outb(PIC1_DATA, ICW4);
	outb(PIC2_DATA, ICW4);
}

void
pic_reset(void)
{
	raw_remap();

	// Disable all IRQs interrupts.
	outb(PIC1_DATA, 0xFF);
	outb(PIC2_DATA, 0xFF);
}

void
pic_remap(void)
{
	uint_fast8_t const m1 = inb(PIC1_DATA);
	uint_fast8_t const m2 = inb(PIC2_DATA);

	raw_remap();

	outb(PIC1_DATA, m1);
	outb(PIC2_DATA, m2);
}

void
pic_ack_irq(uint_fast8_t irq)
{
	if (irq < 0x8)
		outb(PIC1_CMD, 0x20);
	else if (irq < 0x10)
		outb(PIC2_CMD, 0x20);
}

void
pic_enable_irq(uint_fast8_t irq)
{
	if (irq < 0x8) {
		outb(PIC1_DATA, inb(PIC1_DATA) & ~(1 << irq));
	} else if (irq < 0x10) {
		outb(PIC2_DATA, inb(PIC2_DATA) & ~(1 << (irq - 0x8)));
		outb(PIC1_DATA, inb(PIC1_DATA) & ~IRQ_PIC2);
	}
}
