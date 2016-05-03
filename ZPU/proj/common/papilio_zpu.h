// clock frequency
#define		CLOCK_FREQ		96000000UL
// bit position macro
#define		BIT(x)			(1<<(x))

// GPIO pin
#define	GPIO_SPICS			48		// SPI CS
#define	GPIO_LED			49		// on board LED

// Base address for I/O
#define		SPI_BASE		0x08000000		// IO_SLOT_0
#define		UART_BASE		0x08800000		// IO_SLOT_1
#define		GPIO_BASE		0x09000000		// IO_SLOT_2
#define		TIMER_BASE		0x09800000		// IO_SLOT_3
#define		INTR_BASE		0x0a000000		// IO_SLOT_4


// SPI registers
#define		SPICTL			(*(volatile unsigned long*)(SPI_BASE + 0x00000000))
#define		SPIDATA			(*(volatile unsigned long*)(SPI_BASE + 0x00000004))
// SPI register bit name
#define		SPIREADY		0 /* SPI ready */
#define		SPICP0			1 /* Clock prescaler bit 0 */
#define		SPICP1			2 /* Clock prescaler bit 1 */
#define		SPICP2			3 /* Clock prescaler bit 2 */
#define		SPICPOL			4 /* Clock polarity */
#define		SPISRE			5 /* Sample on Rising Edge */
#define		SPIEN			6 /* SPI Enabled (gpio acquire) */
#define		SPIBLOCK		7
#define		SPITS0			8
#define		SPITS1			9

// UART registers
#define		UARTDATA		(*(volatile unsigned long*)(UART_BASE + 0x00000000))
#define		UARTCTL			(*(volatile unsigned long*)(UART_BASE + 0x00000004))
#define		UARTSTATUS		(*(volatile unsigned long*)(UART_BASE + 0x00000004))

// GPIO registers
#define		GPIODATA(x)		(*(volatile unsigned long*)(GPIO_BASE + 0x0000 + ((x)*4)))
#define		GPIOTRIS(x)		(*(volatile unsigned long*)(GPIO_BASE + 0x0010 + ((x)*4)))
#define		GPIOPPSMODE(x)	(*(volatile unsigned long*)(GPIO_BASE + 0x0020 + ((x)*4)))

#ifdef	SUPPORT_GPIO_SET_REG
#define		GPIOSET(x)		(*(volatile unsigned long*)(GPIO_BASE + 0x0040 + ((x)*4)))
#define		GPIOCLR(x)		(*(volatile unsigned long*)(GPIO_BASE + 0x0050 + ((x)*4)))
#define		GPIOTGL(x)		(*(volatile unsigned long*)(GPIO_BASE + 0x0060 + ((x)*4)))
#endif	/* SUPPORT_GPIO_SET_REG */

// TIMER registers
#define		TMR0CTL			(*(volatile unsigned long*)(TIMER_BASE + 0x00000000))
#define		TMR0CNT			(*(volatile unsigned long*)(TIMER_BASE + 0x00000004))		// 16bit counter
#define		TMR0CMP			(*(volatile unsigned long*)(TIMER_BASE + 0x00000008))
#define		TMR0TSC			(*(volatile unsigned long*)(TIMER_BASE + 0x0000000c))

#define		TMR1CTL			(*(volatile unsigned long*)(TIMER_BASE + 0x00000100))
#define		TMR1CNT			(*(volatile unsigned long*)(TIMER_BASE + 0x00000104))		// 16bit counter
#define		TMR1CMP			(*(volatile unsigned long*)(TIMER_BASE + 0x00000108))
#define		TMR1TSC			(*(volatile unsigned long*)(TIMER_BASE + 0x0000010c))


#define		TMREN			0						/* Timer Enable.*/
#define		TMRCCM			1						/* Timer Clear on Compare Match. */
#define		TMRDIR			2						/* Timer count direction. */
#define		TMRIEN			3						/* Timer Interrupt Enable. */
#define		TMRINTR			7						/* Timer Interrupt. */
#define		TMRPRES(prs)	((prs & 0x07) << 4)		/* Timer prescaler. */

// INTR registers
#define		INTRCTL			(*(volatile unsigned long*)(INTR_BASE + 0x00000000))
#define		INTRMASK		(*(volatile unsigned long*)(INTR_BASE + 0x00000004))
#define		INTRSERVED		(*(volatile unsigned long*)(INTR_BASE + 0x00000008))
#define		INTRLEVEL		(*(volatile unsigned long*)(INTR_BASE + 0x0000000c))

#define		INTRLINE_TIMER0		3
#define		INTRLINE_TIMER1		4

// initialize, etc
#define	GPIO_OUTPUTMODE(pin)	do {\
									GPIOTRIS((pin)/32) &= ~BIT((pin)%32);\
								} while(0)

#define	GPIO_INPUTMODE(pin)		do {\
									GPIOTRIS((pin)/32) |=  BIT((pin)%32);\
								} while(0)

#ifdef	SUPPORT_GPIO_SET_REG
#define	GPIO_CLRDATA(pin)		do {\
									GPIOCLR((pin)/32) = BIT((pin)%32);\
								} while(0)
#define	GPIO_SETDATA(pin)		do {\
									GPIOSET((pin)/32) =  BIT((pin)%32);\
								} while(0)
#define	GPIO_TGLDATA(pin)		do {\
									GPIOTGL((pin)/32) =  BIT((pin)%32);\
								} while(0)
#else	// SUPPORT_GPIO_SET_REG
#define	GPIO_CLRDATA(pin)		do {\
									GPIODATA((pin)/32) &= ~BIT((pin)%32);\
								} while(0)
#define	GPIO_SETDATA(pin)		do {\
									GPIODATA((pin)/32) |=  BIT((pin)%32);\
								} while(0)
#define	GPIO_TGLDATA(pin)		do {\
									GPIODATA((pin)/32) ^=  BIT((pin)%32);\
								} while(0)
#endif	//SUPPORT_GPIO_SET_REG

#define	SPI_INIT()				do {\
									GPIO_OUTPUTMODE(GPIO_SPICS);\
									GPIO_SETDATA(GPIO_SPICS);\
									SPICTL=BIT(SPICPOL)|BIT(SPICP0)|BIT(SPISRE)|BIT(SPIEN)|BIT(SPIBLOCK);\
								} while(0)

#define	UART_INIT(bps)			do {\
									UARTCTL = ((CLOCK_FREQ / (bps) / 16) | 0x00010000);\
								} while(0)

#define	SPI_ENABLE()			GPIO_CLRDATA(GPIO_SPICS)
#define	SPI_DISABLE()			GPIO_SETDATA(GPIO_SPICS)
