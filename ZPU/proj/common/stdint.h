#ifndef _STDINT_H
#define _STDINT_H	1

/* Signed.  */
typedef signed char		int8_t;
typedef short int		int16_t;
typedef int			int32_t;

/* Unsigned.  */
typedef unsigned char		uint8_t;
typedef unsigned short int	uint16_t;
typedef unsigned int		uint32_t;


typedef int                     intptr_t;
typedef unsigned int            uintptr_t;


/* Limits of integral types.  */
/* Minimum of signed integral types.  */
# define INT8_MIN		(-128)
# define INT16_MIN		(-32767-1)
# define INT32_MIN		(-2147483647-1)
/* Maximum of signed integral types.  */
# define INT8_MAX		(127)
# define INT16_MAX		(32767)
# define INT32_MAX		(2147483647)

/* Maximum of unsigned integral types.  */
# define UINT8_MAX		(255)
# define UINT16_MAX		(65535)
# define UINT32_MAX		(4294967295U)

# define SIZE_MAX              (4294967295U)


#endif /* stdint.h */
