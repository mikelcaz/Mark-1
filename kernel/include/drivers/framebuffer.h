// # Cursor driver

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

// # Framebuffer driver

extern uint_fast8_t fb_default_color;
extern uint_fast8_t tabstops;

void fb_set(size_t at, uint_fast8_t color, char c, size_t n);
void fb_ncpy(size_t at, uint_fast8_t color, char const *str, size_t n);
void fb_scroll(size_t n);

void fb_nl(void);
void fb_putchar(uint_fast8_t color, char c);
void fb_nprint(uint_fast8_t color, char const *str, size_t n);
void fb_print(uint_fast8_t color, char const *str);
