#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <drivers/framebuffer.h>
#include <drivers/io_b.h>
#include <string.h>

#define VideoMem ((uchar *)0xB8000)
#define Columns 80
#define Rows 25
#define Cells (Columns * Rows)

uint_fast8_t fb_default_color = 0x07;
uint_fast8_t tabstops = 5;

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

// The caller of this function is trusted not to mess around with 'at'.
static size_t
raw_putchar(size_t at, uint_fast8_t color, char c)
{
	if (c == '\t') {
		if (tabstops == 0)
			tabstops = 1;
		else if (8 < tabstops)
			tabstops = 8;

		size_t const off = at % Columns % tabstops;
		size_t const width = tabstops - off;
		for (size_t i = 0; i < width; ++i)
			at = raw_putchar(at, color, ' ');
		return at;
	}

	if (c == '\n') {
		at = (at / Columns + 1) * Columns;
	} else {
		VideoMem[2 * at] = c;
		VideoMem[2 * at + 1] = color;
		++at;
	}

	if (Cells <= at) {
		at -= Columns;
		fb_scroll(1);
	}

	return at;
}

void
fb_set(size_t at, uint_fast8_t color, char c, size_t n)
{
	for (; 0 < n; --n) {
		at %= Cells;

		VideoMem[2 * at] = c;
		VideoMem[2 * at + 1] = color;
		++at;
	}
}

void
fb_ncpy(size_t at, uint_fast8_t color, char const *str, size_t n)
{
	for (size_t i = 0; i < n; ++i) {
		at %= Cells;

		VideoMem[2 * at] = str[i];
		VideoMem[2 * at + 1] = color;
		++at;
	}
}

void
fb_scroll(size_t n)
{
	if (n == 0)
		return;

	if (Rows < n)
		n = Rows;

	memmove(
		VideoMem
		, VideoMem + 2 * n * Columns
		, 2 * (Rows - n) * Columns
	);

	fb_set((Rows - n) * Columns, fb_default_color, ' ', n * Columns);
}

void
fb_nl(void)
{
	uint_fast16_t at = cursor_at();
	uint_fast16_t to_line = at / Columns + 1;
	if (Rows <= to_line) {
		fb_scroll(1);
		--to_line;
	}
	cursor_goto(to_line * Columns);
}

void
fb_putchar(uint_fast8_t color, char c)
{
	size_t at = raw_putchar(cursor_at(), color, c);
	cursor_goto(at);
}

void
fb_nprint(uint_fast8_t color, char const *str, size_t n)
{
	if (n == 0)
		return;

	size_t at = cursor_at();

	for(size_t i = 0; i < n; ++i)
		at = raw_putchar(at, color, str[i]);

	cursor_goto(at);
}

void
fb_print(uint_fast8_t color, char const *str)
{
	fb_nprint(color, str, strlen(str));
}
