#include <limits.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <asm.h>
#include <drivers/idt.h>
#include <drivers/cursor.h>
#include <drivers/framebuffer.h>
#include <drivers/pic.h>
#include <string.h>

extern uchar idt_;
extern uchar handler_0;
extern uchar isrt_handlers_;

// TODO: Remove fw declaration when done.
#include "../drivers/isr.h"
extern ISR(unhandled_interrupt);

void kmain(void) {
	char const kernel_msg[] = "32-bit mode kernel";
	fb_ncpy(80 * 24, 0xF9, kernel_msg, strlen(kernel_msg));
	fb_nl();

	idt_reset();
	pic_reset();

	sti();

	fb_print(0x07, "IDT: %10P\n", &idt_);
	fb_print(0x07, "Table of handlers: %10P\n", &isrt_handlers_);
	fb_print(0x07, "Table of raw functions: %10P\n", (uintptr_t)&isrt_handlers_ + 0x400);
	fb_print(0x07, "Unhandled interrupt fn: %10P\n", unhandled_interrupt);

	int a = 42 / 0;
}
