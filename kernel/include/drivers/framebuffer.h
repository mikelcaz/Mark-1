// Copyright © 2019-2020 Mikel Cazorla Pérez
// This file is part of Mark 1,
// licensed under the terms of GPLv2.

extern uint_fast8_t fb_fill_color;
extern uint_fast8_t fb_print_color;

uint_fast8_t fb_tabstops(void);
void fb_set_tabstops(uint_fast8_t width);

void fb_set(size_t at, uint_fast8_t color, char c, size_t n);
void fb_ncpy(size_t at, uint_fast8_t color, char const *str, size_t n);
void fb_scroll(size_t n);

void fb_nl(void);

void fb_putcharc(uint_fast8_t color, char c);
void fb_nprintc(uint_fast8_t color, char const *fmt, size_t n, ...);
void fb_printc(uint_fast8_t color, char const *fmt, ...);

void fb_putchar(char c);
void fb_nprint(char const *fmt, size_t n, ...);
void fb_print(char const *fmt, ...);
