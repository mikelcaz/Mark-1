#include <limits.h>
#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <asm.h>
#include <drivers/idt.h>
#include <drivers/cursor.h>
#include <drivers/framebuffer.h>
#include <drivers/pic.h>
#include <drivers/timer.h>
#include <string.h>

extern uchar idt_;
extern uchar handler_0;
extern uchar isrt_handlers_;

// TODO: Remove fw declarations when done.
#include "../drivers/isr.h"
extern ISR(unhandled_interrupt);
extern ISR(timer_tick);

void kmain(void) {
	char const kernel_msg[] = "32-bit mode kernel";
	fb_ncpy(80 * 24, 0xF9, kernel_msg, strlen(kernel_msg));
	fb_nl();

	idt_reset();
	pic_reset();
	timer_install(20);

	sti();

	fb_print("IDT: %10P\n", &idt_);
	fb_print("Table of handlers: %10P\n", &isrt_handlers_);
	fb_print("Table of raw functions: %10P\n", (uintptr_t)&isrt_handlers_ + 0x400);
	fb_print("Unhandled interrupt fn: %10P\n", unhandled_interrupt);
	fb_print("Timer tick fn: %10P\n", timer_tick);

	// int a = 42 / 0;
	for (;;) ;
}
