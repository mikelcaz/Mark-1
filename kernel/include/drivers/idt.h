// Copyright © 2019-2020 Mikel Cazorla Pérez
// This file is part of Mark 1,
// licensed under the terms of GPLv2.

void idt_reset(void);
void idt_install_isr(uint_fast8_t i, uintptr_t isr_addr);
