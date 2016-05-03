#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "papilio_zpu.h"


extern void outbyte(int c);

void
InitIntervalTimer0(unsigned int msec, int interrupt)
{
	unsigned int	tmp;

	tmp =  TMRPRES(0x07) 		// fclk/1024
			 | BIT(TMRDIR)		// count up
			 | BIT(TMRCCM)		// clear on compare match
			 | BIT(TMREN);		// timer enable

	if (interrupt) {
		tmp |= BIT(TMRIEN);		// interrupt enable
	}
	// TOMER0 setting
	TMR0CNT = 0;									// clear counter
	TMR0CMP	= msec * (CLOCK_FREQ / 1024 / 1000);	// interval
	TMR0CTL = tmp;
}




int __attribute__((noreturn)) 
main(int argc, char **argv)
{
	printf("LED blink\n");

	// GPIO init
	GPIO_CLRDATA(GPIO_LED);			// LED OFF

	// timer init
	InitIntervalTimer0(500, 1);

	while (1) {
		while (!(TMR0CTL & BIT(TMRINTR))) { }
		TMR0CTL &= ~BIT(TMRINTR);			// clear interrupt request
		GPIO_SETDATA(GPIO_LED);				// LED ON
		outbyte('#');
		while (!(TMR0CTL & BIT(TMRINTR))) { }
		TMR0CTL &= ~BIT(TMRINTR);			// clear interrupt request
		GPIO_CLRDATA(GPIO_LED);				// LED OFF
		outbyte('%');
	}
}
