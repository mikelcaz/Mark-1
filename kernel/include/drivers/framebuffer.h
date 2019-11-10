void frmbuf_scanlines(uint_fast8_t first, uint_fast8_t last);
void frmbuf_hide();
void frmbuf_goto(uint_fast16_t to);
void frmbuf_nl();
uint_fast16_t frmbuf_at();

void frmbuf_scroll(size_t rows, uint_fast8_t color);
void frmbuf_ncpy(size_t at, char const *str, uint_fast8_t color, size_t n);
void frmbuf_cpy(size_t at, char const *str, uint_fast8_t color);

void frmbuf_nprint(char const *str, uint_fast8_t color, size_t n);
void frmbuf_print(char const *str, uint_fast8_t color);
