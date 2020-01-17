// Copyright © 2019-2020 Mikel Cazorla Pérez
// This file is part of Mark 1,
// licensed under the terms of GPLv2.

int memcmp(void const *a, void const *b, size_t n);
void *memcpy(void *dst, void const *src, size_t n);
void *memmove(void *dst, void const *src, size_t n);
void *memset(void *mem, int val, size_t n);

size_t strlen(char const *str);
size_t strnlen(char const *str, size_t maxlen);
int strcmp(char const *a, char const *b);
int strncmp(char const *a, char const *b, size_t upto);
char *strcpy(char *dst, char const *src);
char *strncpy(char *dst, char const *src, size_t n);
