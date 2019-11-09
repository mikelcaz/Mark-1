#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <string.h>

int
memcmp(void const *a, void const *b, size_t n)
{
	uint8_t const *x = a;
	uint8_t const *y = b;

	for (; 0 < n; --n) {
		if (*y < *x)
			return 1;
		if (*x < *y)
			return -1;

		++x;
		++y;
	}

	return 0;
}

void *
memcpy(void *dst, void const *src, size_t n)
{
	return memmove(dst, src, n);
}

void *
memmove(void *dst, void const *src, size_t n)
{
	uchar *d = dst;
	uchar const *s = src;

	if (d < s) {
		for (; 0 < n; --n)
			*d++ = *s++;
	} else if (s < d) {
		for (; 0 < n; --n)
			d[n - 1] = s[n - 1];
	}

	return dst;
}

void *
memset(void *mem, int val, size_t n)
{
	uint8_t *m = mem;
	uint8_t const v = val & 0xFF;

	for (; 0 < n; --n)
		*(uchar *)m++ = v;

	return mem;
}
