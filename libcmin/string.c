// Copyright © 2019-2020 Mikel Cazorla Pérez
// This file is part of Mark 1,
// licensed under the terms of GPLv2.

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

size_t
strlen(char const *str)
{
	return strnlen(str, -1);
}

size_t
strnlen(char const *str, size_t maxlen)
{
	size_t n;

	for (n = 0; n < maxlen; ++n)
		if (str[n] == '\0')
			break;

	return n;
}

int
strcmp(char const *a, char const *b)
{
	while (*a != '\0' && *a == *b) {
		++a;
		++b;
	}

	if (*b < *a)
		return 1;
	if (*a < *b)
		return -1;

	return 0;
}

int
strncmp(char const *a, char const *b, size_t upto)
{
	for (size_t i = 0; i < upto; ++i) {
		if (a[i] != '\0' && a[i] == b[i])
			continue;

		if (b[i] < a[i])
			return 1;
		if (a[i] < b[i])
			return -1;

		break;
	}

	return 0;
}

char *
strcpy(char *dst, char const *src)
{
	char * const fw = dst;
	while ((*dst++ = *src++));
	return fw;
}

char *
strncpy(char *dst, char const *src, size_t n)
{
	char * const fw = dst;

	do {
		if (n == 0)
			break;
		--n;
	} while ((*dst++ = *src++));

	for (; 0 < n; --n)
		dst[n - 1] = 0;

	return fw;
}
