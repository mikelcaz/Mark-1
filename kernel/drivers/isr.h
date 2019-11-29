#define ISR(x)\
	void x (\
		uint ss\
		, uint gs\
		, uint fs\
		, uint es\
		, uint ds\
		, uint edi\
		, uint esi\
		, uint ebp\
		, uint esp\
		, uint ebx\
		, uint edx\
		, uint ecx\
		, uint eax\
		, uint index\
		, uint error\
		, uint eip\
		, uint cs\
		, uint eflags\
	)

// These are only pushed on context switches:
// , uint old_esp
// , uint old_ss
