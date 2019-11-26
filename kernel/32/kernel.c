#include <limits.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <drivers/cursor.h>
#include <drivers/framebuffer.h>
#include <drivers/pic.h>
#include <string.h>

void kmain(void) {
	char const kernel_msg[] = "32-bit mode kernel";
	fb_ncpy(80 * 24, 0xF9, kernel_msg, strlen(kernel_msg));
	fb_nl();

	pic_reset();
}
