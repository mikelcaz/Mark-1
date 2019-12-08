#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <asm.h>
#include <drivers/framebuffer.h>
#include <drivers/paging.h>

// TODO: Do not hardcode the max number of memory map entries.
#define MaxEntries 12
#define RawSize 24
#define LastAddress 0xFFFFFFFF

extern uchar smap_;

enum {
	MemUsable = 1,
	MemReserved = 2,
	// Other values are possible. Preserve them if you can.
};

typedef struct {
	uint64_t base;
	uint64_t len;
	uint32_t type;
	uint32_t protective;
} MemEntry;

static uint32_t
read_uint32_t(uchar **raw)
{
	uint32_t v = 0;

	for (size_t i = 0; i < 4; i++)
		v |= (uint32_t)(*raw)[i] << i * 8;
	*raw += 4;

	return v;
}

static uint64_t
read_uint64_t(uchar **raw)
{
	uint64_t v = 0;

	for (size_t i = 0; i < 8; i++)
		v |= (uint64_t)(*raw)[i] << i * 8;
	*raw += 8;

	return v;
}

static void
write_uint32_t(uchar **raw, uint32_t v)
{
	for (size_t i = 0; i < 4; i++) {
		**raw = (v >> i * 8) & 0xFF;
		++*raw;
	}
}

static void
write_uint64_t(uchar **raw, uint64_t v)
{
	for (size_t i = 0; i < 8; i++) {
		**raw = (v >> i * 8) & 0xFF;
		++*raw;
	}
}

static MemEntry
read_entry(uchar *raw)
{
	MemEntry e;

	e.base = read_uint64_t(&raw);
	e.len = read_uint64_t(&raw);
	e.type = read_uint32_t(&raw);
	e.protective = read_uint32_t(&raw);

	return e;
}

static void
write_entry(uchar *raw, MemEntry const *e)
{
	write_uint64_t(&raw, e->base);
	write_uint64_t(&raw, e->len);
	write_uint32_t(&raw, e->type);
	write_uint32_t(&raw, e->protective);
}

void
mem_normalize(void)
{
	uchar *ptr = &smap_;

	size_t count;
	for (count = 0; count < MaxEntries; ++count) {
		MemEntry e = read_entry(&ptr[count * RawSize]);
		if (e.len == 0)
			break;
	}

	// This avoids potential overwrappings ensuring ranges
	// can't extend themselves beyond the addressable memory.
	// TODO: Revise LastAddress corner case (cannot be inside ranges).
	for (size_t i = 0; i < count; ++i) {
		MemEntry e = read_entry(&ptr[i * RawSize]);

		if (e.base < LastAddress) {
			if (e.len <= LastAddress - e.base)
				continue;

			e.len = LastAddress - e.base;
			if (0 < e.len) {
				write_entry(&ptr[i * RawSize], &e);
				continue;
			}
		}

		// Remove entry.
		for (size_t j = i + 1; j < count; ++j) {
			e = read_entry(&ptr[j * RawSize]);
			write_entry(&ptr[(j - 1) * RawSize], &e);
		}
		--count;
		--i;
	}

	for (size_t j = 0; j < count; ++j)
	for (size_t i = 1; i < count - j; ++i) {
		MemEntry a = read_entry(&ptr[(i - 1) * RawSize]);
		MemEntry b = read_entry(&ptr[i * RawSize]);

		if (b.base < a.base) {
			write_entry(&ptr[(i - 1) * RawSize], &b);
			write_entry(&ptr[i * RawSize], &a);
		}
	}

	for (size_t i = 1; i < count; ++i) {
		MemEntry a = read_entry(&ptr[(i - 1) * RawSize]);
		MemEntry b = read_entry(&ptr[i * RawSize]);

		if (b.base < a.base + a.len) {
			// TODO: Resolve overlapping entries from memory map.
			fb_printc(0x4E, "Overlapping memory entries\n");
			halt();
		}
	}
}
