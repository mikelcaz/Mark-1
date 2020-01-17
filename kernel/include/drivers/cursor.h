// Copyright © 2019-2020 Mikel Cazorla Pérez
// This file is part of Mark 1,
// licensed under the terms of GPLv2.

uint_fast16_t cursor_at(void);
void cursor_goto(uint_fast16_t to);

void cursor_hide(void);
void cursor_show(void);

// Scanline values should normally be between 0 and 15
// (and they cannot be greater than 31).
// Setting the scanlines enables the cursor automatically.
uint_fast8_t cursor_upper_scanline(void);
uint_fast8_t cursor_lower_scanline(void);
void cursor_set_scanlines(uint_fast8_t upper, uint_fast8_t lower);
