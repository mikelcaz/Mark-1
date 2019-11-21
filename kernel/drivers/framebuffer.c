#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <drivers/framebuffer.h>
#include <drivers/cursor.h>
#include <string.h>

#define VideoMem ((uchar *)0xB8000)
#include "framebuffer_macros.h"

uint_fast8_t fb_default_color = 0x07;
uint_fast8_t tabstops = 5;

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
