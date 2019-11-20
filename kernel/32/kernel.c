#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <drivers/framebuffer.h>
#include <string.h>

void kmain(void) {
	frmbuf_cpy(80 * 24, "32-bit mode kernel", 0xF9);
	frmbuf_nl();
	frmbuf_print("Hello, World!", 0xF9);
}
