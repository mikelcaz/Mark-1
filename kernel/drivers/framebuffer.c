#include <limits.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <drivers/framebuffer.h>
#include <drivers/framebuffer_va.h>
#include <drivers/cursor.h>
#include <string.h>

#define VideoMem ((uchar *)0xB8000)
#include "framebuffer_macros.h"

static uint_fast8_t tabstops = 5;
uint_fast8_t fb_default_color = 0x07;

// Callers of "raw_*" functions are trusted not to mess around with 'at'.

static size_t
raw_putchar(size_t at, uint_fast8_t color, char c)
{
	if (c == '\t') {
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

static size_t
raw_putdigit(size_t at, uint_fast8_t color, uint d, int lo_case)
{
	char c;

	do {
		if (d < 0xA)
			c = '0' + d;
		else if (d <= 0xF)
			c = (lo_case? 'a': 'A') - 0xA + d;
		else
			break;

		at = raw_putchar(at, color, c);
	} while (0);

	return at;
}

static size_t
raw_putstring(size_t at, uint_fast8_t color, char const *str)
{
	size_t len = strlen(str);
	for (; 0 < len; --len)
		at = raw_putchar(at, color, *str++);

	return at;
}

// Note this accounts EOLs (as 1-wide).
static size_t
raw_strnwidth(size_t off, char const *str, size_t n)
{
	size_t i = 0;
	size_t width = 0;
	while (i < n && width < SIZE_MAX) {
		if (str[i] != '\t' || off % tabstops == tabstops - 1)
			++i;
		++width;
		off = (off + 1) % Columns;
	}

	return width;
}

// Note this accounts EOLs (as 1-wide).
static size_t
raw_strwidth(size_t off, char const *str)
{
	return raw_strnwidth(off, str, strlen(str));
}

uint_fast8_t
fb_tabstops(void)
{
	return tabstops;
}

void
fb_set_tabstops(uint_fast8_t width)
{
	if (0 < width && width <= 8)
		tabstops = width;
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
fb_vnprint(uint_fast8_t color, char const *fmt, size_t n, va_list ap)
{
	if (n == 0)
		return;

	size_t at = cursor_at();

	size_t fw;
	size_t i = 0;
	while (i < n) {
		if (fmt[i] != '%') {
			at = raw_putchar(at, color, fmt[i]);
			++i;
			continue;
		}

		fw = i + 1;
		if (n <= fw)
			goto bad_format;

		if (fmt[fw] == '%') {
			at = raw_putchar(at, color, fmt[fw]);
			i += 2;
			continue;
		}

		uint min_width = 0; // Zero == ignored
		uint len_mod = 0;

		// # Minimum width

		if (fmt[fw] == '*') {
			++fw;
			if (n <= fw)
				goto bad_format;
			// Zero is allowed in this variant.
			min_width = va_arg(ap, uint);
		} else for (;;) {
			uint d = (uint)fmt[fw] - '0';
			if (9 < d)
				break;

			++fw;
			d += min_width * 10;
			// Checks also for wrapping and initial zeros.
			if (n <= fw || d <= min_width)
				goto bad_format;
			min_width = d;
		}

		// # Length modifier

		switch (fmt[fw]) {
		case 'h':
		case 'l':
		case 'j':
		case 'z':
		case 't':
			len_mod = fmt[fw];
			++fw;
			if (n <= fw)
				goto bad_format;
			break;
		}

		switch (fmt[fw]) {
		case 'h':
		case 'l':
			if (len_mod == (uint)fmt[fw]) {
				// Double -letter-.
				len_mod |= 0x100;
				++fw;
				if (n <= fw)
					goto bad_format;
			}
			break;
		}

		// # Specifier

		char const spec = fmt[fw];
		++fw;

		switch (spec) {
		case 'c': {
			if (len_mod)
				goto bad_format;

			char c = va_arg(ap, int);

			if (min_width) {
				uint const width =
					c == '\t'
					? tabstops - at % tabstops
					: 1;
				for (; width < min_width; --min_width)
					at = raw_putchar(at, color, ' ');
			}

			at = raw_putchar(at, color, c);
		} break;
		case 's': {
			if (len_mod)
				goto bad_format;

			char const *str = va_arg(ap, char const *);
			if (str == nil)
				str = "(nil)";

			for (; raw_strwidth(at, str) < min_width; --min_width)
				at = raw_putchar(at, color, ' ');

			at = raw_putstring(at, color, str);
		} break;
		default: {
			int const lower = spec & 0x20;
			uint base = 10;
			uintmax_t num;

			do {
				if (spec == 'u') {
				} else if (spec == 'd') {
					intmax_t snum;

					switch (len_mod) {
					case 't':
						snum = va_arg(ap, ptrdiff_t);
						break;
					case 'z':
						goto bad_format;
					case 'j':
						snum = va_arg(ap, intmax_t);
						break;
					case 'l' | 0x100:
						snum = va_arg(ap, vlong);
						break;
					case 'l':
						snum = va_arg(ap, long);
						break;
					default:
					// case 0:
					// case 'h' | 0x100:
					// case 'h':
						snum = va_arg(ap, int);
						break;
					}

					if (snum < 0) {
						at = raw_putchar(at, color, '-');
						num = INTMAX_MIN - snum;
						num += (uintmax_t)INTMAX_MIN;
					} else {
						num = snum;
					}

					break;
				} else if ((spec & ~0x20) == 'P') {
					base = 16;

					if (len_mod)
						goto bad_format;

					num = (uintptr_t)va_arg(ap, void *);
					at = raw_putstring(at, color, "0x");
					if (2 < min_width)
						min_width -= 2;
					else
						min_width = 0;

					break;
				} else if ((spec & ~0x20) == 'X') {
					base = 16;
				} else if (spec == 'o') {
					base = 8;
				} else {
					goto bad_format;
				}

				switch (len_mod) {
				case 't':
					goto bad_format;
				case 'z':
					num = va_arg(ap, size_t);
					break;
				case 'j':
					num = va_arg(ap, uintmax_t);
					break;
				case 'l' | 0x100:
					num = va_arg(ap, uvlong);
					break;
				case 'l':
					num = va_arg(ap, ulong);
					break;
				default:
				// case 0:
				// case 'h' | 0x100:
				// case 'h':
					num = va_arg(ap, uint);
					break;
				}
			} while (0);

			uintmax_t div = 1;
			{
				uintmax_t d = 1;
				uintmax_t cpy = num;
				while (0 < (cpy /= base)) {
					++d;
					div *= base;
				}
				for (; d < min_width; ++d)
					at = raw_putchar(
						at
						, color
						, '0'
					);
			}

			for (; 1 < div; div /= base) {
				at = raw_putdigit(
					at
					, color
					, num / div % base
					, lower
				);
			}
			at = raw_putdigit(at, color, num % base, lower);
		} break;
		}

		i = fw;
		continue;
		bad_format:
			for (; i < fw; ++i)
				at = raw_putchar(at, color, fmt[i]);
	}

	cursor_goto(at);
}

void
fb_nprint(uint_fast8_t color, char const *fmt, size_t n, ...)
{
	va_list ap;
	va_start(ap, n);
	fb_vnprint(color, fmt, n, ap);
	va_end(ap);
}

void
fb_vprint(uint_fast8_t color, char const *fmt, va_list ap)
{
	fb_vnprint(color, fmt, strlen(fmt), ap);
}

void
fb_print(uint_fast8_t color, char const *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);
	fb_vprint(color, fmt, ap);
	va_end(ap);
}
