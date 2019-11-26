void idt_reset(void);
void idt_install_isr(uint_fast8_t i, uintptr_t isr_addr);
