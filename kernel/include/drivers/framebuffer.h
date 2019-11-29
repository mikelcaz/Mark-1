extern uint_fast8_t fb_default_color;

uint_fast8_t fb_tabstops(void);
void fb_set_tabstops(uint_fast8_t width);

void fb_set(size_t at, uint_fast8_t color, char c, size_t n);
void fb_ncpy(size_t at, uint_fast8_t color, char const *str, size_t n);
void fb_scroll(size_t n);

void fb_nl(void);
void fb_putchar(uint_fast8_t color, char c);
void fb_nprint(uint_fast8_t color, char const *fmt, size_t n, ...);
void fb_print(uint_fast8_t color, char const *fmt, ...);
