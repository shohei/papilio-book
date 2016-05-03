/* 
 * Copyright (C) 1999, 2000, 2001, 2002 Stephane Carrez (stcarrez@nerim.fr)	
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions. No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
 */


	.text
	
	.global	setjmp
	.globl	longjmp


setjmp:
	; jmp_buff[0] = return address
	; jmp_buff[1] = frame pointer
	; jmp_buff[2] = current stack pointer

			; sp+0-> return address
			; sp+4-> 1st argument(pointer to jmp_buff)

	loadsp	0
	loadsp	8			;jmp_buff[0]
	store				; return address

	im		_memreg + 12
	load				; frame pointer
	loadsp	8
	im		4
	add					;jmp_buff[1]
	store

	pushsp				; current stack pointer pointer
	loadsp	8
	im		8
	add					; jmp_buff[2]
	store

	im		0			; return value
	nop
	im		_memreg
	store

	poppc


	; arguments are buffer + return value
longjmp:
	; jmp_buff[0] = return address
	; jmp_buff[1] = frame pointer
	; jmp_buff[2] = current stack pointer

			; sp+0-> return address
			; sp+4-> 1st argument(pointer to jmp_buff)
			; sp+8-> return value for setjmp()

	loadsp	8				; return value for setjmp()
	im		_memreg
	store

	loadsp	4
	im		4
	add
	load					; saved frame pointer
	im		_memreg + 12
	store

	loadsp	4
	im		8
	add
	load					; saved stack pointer

	loadsp	8
	load					; saved return address
	loadsp	4				; saved stackpointer
	store

	popsp
	poppc
