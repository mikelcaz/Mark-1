#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <drivers/framebuffer.h>
#include <drivers/io_b.h>
#include <string.h>

static uchar * const video_mem = (uchar *)0xB8000;
static size_t const fb_cols = 80;
static size_t const fb_rows = 25;
static size_t const fb_size = fb_cols * fb_rows;

void
frmbuf_scanlines(uint_fast8_t first, uint_fast8_t last)
{
	outb(0x3D4, 0x0A);
	outb(0x3D5, (inb(0x3D5) & 0xC0) | first);
	outb(0x3D4, 0x0B);
	outb(0x3D5, (inb(0x3D5) & 0xE0) | last);
}

void
frmbuf_hide()
{
	outb(0x3D4, 0x0A);
	outb(0x3D5, 0x20);
}

void
frmbuf_goto(uint_fast16_t to)
{
	if (fb_size <= to)
		return;

	outb(0x3D4, 0x0F);
	outb(0x3D5, to & 0xFF);
	outb(0x3D4, 0x0E);
	outb(0x3D5, to >> 8);
}

void
frmbuf_nl()
{
	uint_fast16_t at = frmbuf_at();
	uint_fast16_t line = at / fb_cols + 1;
	if (fb_rows <= line) {
		frmbuf_scroll(1, 0x07);
		--line;
	}
	frmbuf_goto(line * fb_cols);
}

uint_fast16_t
frmbuf_at()
{
	uint_fast16_t to;

	outb(0x3D4, 0x0F);
	to = inb(0x3D5);
	outb(0x3D4, 0x0E);
	to |= ((uint_fast16_t)inb(0x3D5)) << 8;

	return to;
}

void
frmbuf_scroll(size_t rows, uint_fast8_t color)
{
	if (rows == 0)
		return;

	if (fb_rows < rows)
		rows = fb_rows;

	memmove(
		video_mem
		, video_mem + 2 * rows * fb_cols
		, 2 * (fb_rows - rows) * fb_cols
	);

	uchar * const mem = video_mem + 2 * (fb_rows - rows) * fb_cols;

	for (size_t i = 0; i < rows * fb_cols; ++i) {
		mem[2 * i] = ' ';
		mem[2 * i + 1] = color;
	}
}

void
frmbuf_ncpy(size_t at, char const *str, uint_fast8_t color, size_t n)
{
	for (size_t i = 0; i < n; ++i) {
		if (fb_size <= at)
			at = 0;

		video_mem[2 * at] = str[i];
		video_mem[2 * at + 1] = color;
		++at;
	}
}

void
frmbuf_cpy(size_t at, char const *str, uint_fast8_t color)
{
	frmbuf_ncpy(at, str, color, strlen(str));
}

void
frmbuf_nprint(char const *str, uint_fast8_t color, size_t n)
{
	if (n == 0)
		return;

	size_t at = frmbuf_at();
	size_t const margin = fb_size - at;
	size_t const at_row = at / fb_cols;

	size_t i = 0;
	if (margin <= n) {
		size_t const out = n - margin;
		size_t rows = 1 + out / fb_cols;

		if (at_row < rows) {
			i = n - out % fb_cols - (fb_rows - 1) * fb_cols;
			at = 0;
		} else {
			at -= rows * fb_cols;
		}

		frmbuf_scroll(rows, 0x07);
	}
	frmbuf_ncpy(at, &str[i], color, n - i);
	frmbuf_goto(at + n - i);
}

void
frmbuf_print(char const *str, uint_fast8_t color)
{
	frmbuf_nprint(str, color, strlen(str));
}
