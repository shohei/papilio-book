#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "papilio_zpu.h"


extern void (*ivector)(void);
extern void outbyte(int c);

void
SetInterruptHandler(void (*pFunc)(void))
{
	ivector = pFunc;
}


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


void
IntHandler(void)
{
	static int led = 0;
	if (TMR0CTL & BIT(TMRINTR)) {
		TMR0CTL &= ~BIT(TMRINTR);			// clear interrupt
		if (led) {
			led = 0;
			GPIO_CLRDATA(GPIO_LED);			// LED OFF
		}
		else {
			led = 1;
			GPIO_SETDATA(GPIO_LED);			// LED ON
		}
		outbyte('#');
	}
}


int __attribute__((noreturn)) 
main(int argc, char **argv)
{
	printf("LED blink by interrupt\n");

	SetInterruptHandler(&IntHandler);

	// GPIO init
	GPIO_CLRDATA(GPIO_LED);			// LED OFF

	// timer init
	InitIntervalTimer0(500, 1);

	INTRMASK = BIT(INTRLINE_TIMER0);	// Enable timer 0 interrupt on mask
	INTRCTL = 1; 						// Globally enable interrupts

	while (1) {	}
}
