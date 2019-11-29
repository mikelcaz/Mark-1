#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <asm.h>
#include <drivers/framebuffer.h>
#include "isr.h"

ISR(unhandled_interrupt)
{
	fb_print(0x4E, "Interrupt vector: 0x%2X (%u), Error code: 0x%2X (%u)\n", index, index, error, error);
	fb_print(0x4E, "CS: 0x%8X, EIP: 0x%8X, EFLAGS: 0x%8X\n", cs, eip, eflags);
	// fb_print(0x4E, "Old SS: 0x%8X (%u), Old ESP: 0x%8X (%u)\n", old_ss, old_ss, old_esp, old_esp);
	fb_print(0x4E, "EAX: 0x%8X (%u)\n", eax, eax);
	fb_print(0x4E, "ECX: 0x%8X (%u)\n", ecx, ecx);
	fb_print(0x4E, "EDX: 0x%8X (%u)\n", edx, edx);
	fb_print(0x4E, "EBX: 0x%8X (%u)\n", ebx, ebx);
	fb_print(0x4E, "ESP: 0x%8X (%u)\n", esp, esp);
	fb_print(0x4E, "EBP: 0x%8X (%u)\n", ebp, ebp);
	fb_print(0x4E, "ESI: 0x%8X (%u)\n", esi, esi);
	fb_print(0x4E, "EDI: 0x%8X (%u)\n", edi, edi);
	fb_print(0x4E, " DS: 0x%8X (%u)\n", ds, ds);
	fb_print(0x4E, " ES: 0x%8X (%u)\n", es, es);
	fb_print(0x4E, " FS: 0x%8X (%u)\n", fs, fs);
	fb_print(0x4E, " GS: 0x%8X (%u)\n", gs, gs);
	fb_print(0x4E, " SS: 0x%8X (%u)\n", ss, ss);
	halt();
}
