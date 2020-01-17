// Copyright © 2019-2020 Mikel Cazorla Pérez
// This file is part of Mark 1,
// licensed under the terms of GPLv2.

#include <stddef.h>
//
#include <string.h>
#include <strings.h>

void
bcopy(void const *src, void *dst, size_t n)
{
	memcpy(dst, src, n);
}

void
bzero(void *mem, size_t n)
{
	memset(mem, 0, n);
}
