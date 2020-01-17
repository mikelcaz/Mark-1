// Copyright © 2019-2020 Mikel Cazorla Pérez
// This file is part of Mark 1,
// licensed under the terms of GPLv2.

void pic_reset(void);
void pic_remap(void);

void pic_ack_irq(uint_fast8_t irq);
void pic_enable_irq(uint_fast8_t irq);
