#include <stdio.h>
#include <errno.h>
#include <sys/stat.h>

#include "papilio_zpu.h"

extern unsigned int __bss_start__,__bss_end__;
extern unsigned int ___ctors, ___ctors_end;
extern char __end__;

extern void _init(void);
extern int main(int atgc, char** argv);

/* 
 * For Heap memory operation 
 */
static char *start_brk = &__end__;
void *sbrk(int inc)
{
	char*	tmp_p;
	tmp_p = start_brk;
	start_brk+=inc;
	return tmp_p;
}

/* 
 * Input one character from the serial port 
 */
int
inbyte()  
{
	while (1) {
		if ((UARTSTATUS & 0x01) != 0) {
			return UARTDATA & 0xff;
		}
	}
}



/* 
 * Output one character to the serial port 
 */
void
outbyte(int c)  
{
	/* Wait for space in FIFO */
	while ((UARTSTATUS & 0x02) != 0);
	UARTDATA = c;
}


/* 
 * Clear .bss section
 */
void
___clear_bss()
{
	unsigned int *ptr =  &__bss_start__;
	while (ptr < &__bss_end__) {
		*ptr = 0;
		ptr++;
	}
}

void __attribute__((noreturn)) 
_premain(void)
{
	// clear .bss section
	___clear_bss();

	// initialize runtime library
	_init();

	// init UART
	UART_INIT(115200);

	// jump to mainroutine
	main(0, 0);

	while(1);
}



