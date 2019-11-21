#include <stddef.h>
#include <stdint.h>
//
#include <u.h>
#include <drivers/framebuffer.h>
#include <string.h>

void kmain(void) {
	char const kernel_msg[] = "32-bit mode kernel";
	fb_ncpy(80 * 24, 0xF9, kernel_msg, strlen(kernel_msg));
	fb_nl();

	char const hello[] = "Hello, World!";
	fb_print(0xF9, hello);

	char const test[] =
		"DEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH00"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH01"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH02"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH03"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH04"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH05"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH06"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH07"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH08"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH09"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH10"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH11"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH12"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH13"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH14"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH15"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH16"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH17"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH18"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH19"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH20"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH21"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH22"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH23"
		"0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789ABCDEFGH24"
	;

	fb_print(0xF9, test);
}
