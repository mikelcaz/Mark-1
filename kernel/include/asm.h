// Copyright © 2019-2020 Mikel Cazorla Pérez
// This file is part of Mark 1,
// licensed under the terms of GPLv2.

void cli(void);
void sti(void);

void halt(void);

uint_fast8_t inb(uint_fast16_t port);
void outb(uint_fast16_t port, uint_fast8_t data);
