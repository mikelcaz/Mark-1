// Copyright © 2019-2020 Mikel Cazorla Pérez
// This file is part of Mark 1,
// licensed under the terms of GPLv2.

#include <stdint.h>
//
#include <u.h>
#include <asm.h>
#include <drivers/pic.h>
#include <drivers/timer.h>
#include "pic_macros.h"

// The PIT actually counts with 3 channels (from 0 to 2),
// but channels 1 and 2 were meant for legacy features
// and are ignored here.

#define CHAN_0 (0 << 6)
#define PORT_CHAN_0 0x40
#define PORT_CTRL 0x43

#define OP_SQR_WAV (0x3 << 1)
#define ACC_L_THEN_H (0x3 << 4)

#define PIT_FREQUENCY 1193180

static volatile uint timer;

void
timer_install(uint hz)
{
	timer = 0;

	if (hz < 20 || PIT_FREQUENCY < hz)
		return;

	uint const div = PIT_FREQUENCY / hz;

	outb(PORT_CTRL, CHAN_0 | OP_SQR_WAV | ACC_L_THEN_H);
	outb(PORT_CHAN_0, div & 0xFF);
	outb(PORT_CHAN_0, div >> 8);

	pic_enable_irq(IRQ_SYSTIMER);
}

#include "isr.h"

#include <stddef.h>
//
#include <drivers/framebuffer.h>
#include "framebuffer_macros.h"

ISR(timer_tick)
{
	++timer;

	char c = "|/-\\"[timer % 4];
	fb_ncpy(Columns - 1, 0x4E, &c, 1);
	pic_ack_irq(IRQ_SYSTIMER);

	(void)ss;
	(void)gs;
	(void)fs;
	(void)es;
	(void)ds;
	(void)edi;
	(void)esi;
	(void)ebp;
	(void)esp;
	(void)ebx;
	(void)edx;
	(void)ecx;
	(void)eax;
	(void)index;
	(void)error;
	(void)eip;
	(void)cs;
	(void)eflags;
}
