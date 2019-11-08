#include <stddef.h>
#include "u.h"

size_t print_to_video_mem(size_t from, char const *msg, uchar fmt);

void kmain() {
	size_t next = 2 * 80 * 24;
	next = print_to_video_mem(next, "32-bit mode kernel", 0xF9);
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
