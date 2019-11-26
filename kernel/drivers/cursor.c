#include <stddef.h>
#include <stdint.h>
//
#include <asm.h>
#include <drivers/cursor.h>

#include "framebuffer_macros.h"

uint_fast16_t
cursor_at(void)
{
	uint_fast16_t to;

	outb(0x3D4, 0x0F);
	to = inb(0x3D5);
	outb(0x3D4, 0x0E);
	to |= ((uint_fast16_t)inb(0x3D5)) << 8;

	return to;
}

void
cursor_goto(uint_fast16_t to)
{
	if (Cells <= to)
		return;

	outb(0x3D4, 0x0F);
	outb(0x3D5, to & 0xFF);
	outb(0x3D4, 0x0E);
	outb(0x3D5, to >> 8);
}

void
cursor_hide(void)
{
	outb(0x3D4, 0x0A);
	outb(0x3D5, inb(0x3D5) | 0x20);
}

void
cursor_show(void)
{
	outb(0x3D4, 0x0A);
	outb(0x3D5, inb(0x3D5) & ~0x20);
}

uint_fast8_t
cursor_upper_scanline(void)
{
	outb(0x3D4, 0x0A);
	return inb(0x3D5) & 0x1F;
}

uint_fast8_t
cursor_lower_scanline(void)
{
	outb(0x3D4, 0x0B);
	return inb(0x3D5) & 0x1F;
}

void
cursor_set_scanlines(uint_fast8_t upper, uint_fast8_t lower)
{
	upper &= 0x1F;
	lower &= 0x1F;

	outb(0x3D4, 0x0A);
	outb(0x3D5, (inb(0x3D5) & 0xC0) | upper);
	outb(0x3D4, 0x0B);
	outb(0x3D5, (inb(0x3D5) & 0xE0) | lower);
}
