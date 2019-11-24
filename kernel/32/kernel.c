#include <limits.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <drivers/cursor.h>
#include <drivers/framebuffer.h>
#include <string.h>

void kmain(void) {
	char const kernel_msg[] = "32-bit mode kernel";
	fb_ncpy(80 * 24, 0xF9, kernel_msg, strlen(kernel_msg));
	fb_nl();

	fb_print(0xF9, "Hello, World!\n");
	fb_print(0xF9, "- Strings and padding: [%8s][%*s].\n", "x", 8, "y");
	fb_print(0xF9, "- Chars and padding [%c|%2c|%*c]!\n", 'a', 'b', 3, 'c');
	fb_print(0xF9, "- Numbers and padding: %*zX %*zX.\n", 2 * sizeof(size_t), (size_t)0x0, 2 * sizeof(size_t), (size_t)0x1);
	fb_print(0xF9, "- Pointers and padding: %10p %10P.\n", nil, (void *)10);
	int n = 15;
	fb_print(0xF9, "- Positives: %d %u %xh %Xh %oo\n", n, n, n, n, n);
	n = -15;
	fb_print(0xF9, "- Negatives: %d %u %xh %Xh %oo\n", n, n, n, n, n);
	fb_nl();

	fb_print(0xF9, "Schar: %zu bytes, [%hhd to %hhd].\n", sizeof(schar), SCHAR_MIN, SCHAR_MAX);
	fb_print(0xF9, "Short: %zu bytes, [%hd to %hd].\n", sizeof(short), SHRT_MIN, SHRT_MAX);
	fb_print(0xF9, "Int: %zu bytes, [%d to %d].\n", sizeof(int), INT_MIN, INT_MAX);
	fb_print(0xF9, "Long: %zu bytes, [%ld to %ld].\n", sizeof(long), LONG_MIN, LONG_MAX);
	fb_print(0xF9, "Vlong: %zu bytes, [%lld to %lld].\n", sizeof(vlong), LLONG_MIN, LLONG_MAX);
	fb_print(0xF9, "Intmax_t: %zu bytes, [%jd to %jd].\n", sizeof(intmax_t), INTMAX_MIN, INTMAX_MAX);
	fb_print(0xF9, "Ptrdiff_t: %zu bytes, [%td to %td].\n", sizeof(ptrdiff_t), PTRDIFF_MIN, PTRDIFF_MAX);
	fb_print(0xF9, "Size_t: %zu bytes, [up to %zu (%zXh)].\n", sizeof(size_t), SIZE_MAX, SIZE_MAX);
}
