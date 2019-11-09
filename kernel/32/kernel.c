#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <drivers/io_b.h>
#include <string.h>

size_t print_to_video_mem(size_t from, char const *msg, uchar fmt);

void kmain() {
	// size_t next = 2 * 80 * 24;
	// next = print_to_video_mem(next, "32-bit mode kernel", 0xF9);

	uint_fast16_t to;
	outb(0x3D4, 0x0F);
	to = inb(0x3D5);
	outb(0x3D4, 0x0E);
	to |= ((uint_fast16_t)inb(0x3D5)) << 8;

	print_to_video_mem(2 * to, "32-bit mode kernel", 0xF9);

	to += strlen("32-bit mode kernel");
	outb(0x3D4, 0x0F);
	outb(0x3D5, to & 0xFF);
	outb(0x3D4, 0x0E);
	outb(0x3D5, to >> 8);
}

size_t print_to_video_mem(size_t from, char const *msg, uchar fmt) {
	char * const video_mem = (char *)0xB8000;
	while (*msg != '\0') {
		video_mem[from] = *msg;
		video_mem[from + 1] = fmt;
		++msg;
		from += 2;
	}

	return from;
}
