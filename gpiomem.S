// Justine Le and Tyler Kulikowski
// Written by Stephen Smith, Justine Le, and Tyler Kulikowski
// CS3B - gpiomem - yippie io 4 
// 5/6/25
// ********************************************************************
// Various macros to access the GPIO pins on the Raspberry Pi. Macros
// besides GPIODirectionIn and GPIOReadLevelBit were created by
// Stephen Smith. 
// ********************************************************************

#include "fileio.S"

.equ	pagelen, 4096
.equ	setregoffset, 28
.equ    clrregoffset, 40
.equ 	levelregoffset, 52	// GPLEV0 = GPIO Pin Level 0
.equ	PROT_READ, 1
.equ	PROT_WRITE, 2
.equ	MAP_SHARED, 1

// Macro to map memory for GPIO Registers
.macro mapMem
	openFile	devmem, O_RDWR // open /dev/mem
	ADDS		X4, XZR, X0	// fd for memmap
	// check for error and print error msg if necessary
	B.PL		1f  // pos number file opened ok
	MOV		X1, #1  // stdout
	LDR		X2, =memOpnsz	// Error msg
	LDR		W2, [X2]
	writeFile	X1, memOpnErr, X2 // print the error
	B		_end

// Setup can call the mmap2 Linux service
1:	ldr		X5, =gpioaddr	// address we want / 4096
	ldr		X5, [X5]	// load the address
	mov		X1, #pagelen	// size of mem we want
	mov		X2, #(PROT_READ + PROT_WRITE) // mem protection options
	mov		X3, #MAP_SHARED	// mem share options
	mov		X0, #0		// let linux choose a virtual address
	mov		X8, #__NR_mmap	// mmap service num
	svc		0		// call service
	ADDS		X9, XZR, X0	// keep the returned virtual address
	// check for error and print error msg if necessary
	B.PL		2f  // pos number file opened ok
	MOV		X1, #1  // stdout
	LDR		X2, =memMapsz	// Error msg
	LDR		W2, [X2]
	writeFile	X1, memMapErr, X2 // print the error
	B		_end
2:
.endm

// Macro nanoSleep to sleep .1 second
// Calls Linux nanosleep entry point which is function 162.
// Pass a reference to a timespec in both X0 and X1
// First is input time to sleep in seconds and nanoseconds.
// Second is time left to sleep if interrupted (which we ignore)
.macro  nanoSleep
        ldr         X0, =timespecsec
        ldr         X1, =timespecsec
        mov         X8, #__NR_nanosleep
        svc         0
.endm

.macro  GPIODirectionOut   pin
	ldr	X2, =\pin	// offset of select register
	ldr	W2, [X2]	// load the value
        ldr	W1, [X9, X2]    // address of register
	ldr	X3, =\pin	// address of pin table
	add	X3, X3, #4	// load amount to shift from table
	ldr	W3, [X3]	// load value of shift amt
	mov	X0, #0b111	// mask to clear 3 bits
	lsl	X0, X0, X3	// shift into position
	bic	X1, X1, X0	// clear the three bits
	mov	X0, #1		// 1 bit to shift into pos
	lsl	X0, X0, X3	// shift by amount from table
	orr	X1, X1, X0	// set the bit
	str	W1, [X9, X2]    // save it to register to do work   
.endm

//*****************************************************************************
// GPIODirectionIn
// Macro GPIODirectionIn: Configures the specified GPIO pin as an input by
// clearing the 3-bit function select field for the pin in the GPIO register.
//
// X0: Used as a bitmask to clear the function bits in X1
// X1: Loaded with the current value of the GPIO function select register
// X2: Loaded with the offset of the GPIO function select register from the pin table
// X3: Points to the pin table and then to the shift amount entry
// W2: Holds the raw offset value read from the pin table (not used directly)
// W3: Contains the shift amount to position the function bits for the pin
//
// Updated register value is written back to GPIO function select register 
//	using STR W1, [X9, X2]
//*****************************************************************************
.MACRO  GPIODirectionIn   pin
	LDR	X2, =\pin		// offset of select register
	LDR	W2, [X2]		// load the value
    LDR	W1, [X9, X2]    // address of register
	LDR	X3, =\pin		// address of pin table
	ADD	X3, X3, #4		// load amount to shift from table
	LDR	W3, [X3]		// load value of shift amt
	MOV	X0, #0b111		// mask to clear 3 bits
	LSL	X0, X0, X3		// shift into position
	BIC	X1, X1, X0		// clear the three bits
	MOV	X0, #0			// 0 bit to shift into pos
	LSL	X0, X0, X3		// shift by amount from table
	ORR	X1, X1, X0		// set the bit
	STR	W1, [X9, X2]    // save it to register to do work   
.ENDM

//*****************************************************************************
// GPIOReadLevelBit
// Macro GPIOReadLevelBit: Reads the logic level (0 or 1) of a specified GPIO
// input pin and places the result in W0.
//
// X0: Bitmask (1 shifted to the pin's bit position)
// X2: Base address of GPIO, offset to GPLEV (GPIO Pin Level) register
// X3: Points to the pin definition table, loads shift amount
// W0: Result of isolating the pin's bit (either 0 or 1)
// W1: Holds the full 32-bit GPIO level register value
// W3: Contains the bit shift amount for the pin
//*****************************************************************************
.MACRO GPIOReadLevelBit pin
	MOV	X2, X9		// base address of GPIO registers
	ADD	X2, X2, #levelregoffset	// offset to the GPLEV register
	MOV	X0, #1		// mask to isolate the pin bit
	LDR	X3, =\pin	// load pin info or shift amount for the pin
	ADD X3, X3, #8	// offset shift amount in the pin info table
	LDR	W3, [X3]	// load shift amount for this pin into W3
	LSL	X0, X0, X3	// shift the mask into thecorrect bit position
	LDR	W1, [X2]	// read the current state of GPIO levels
	AND	W0, W1, W0	// isolate the bit for the pin
	LSR	W0, W0, W3	// shift the results back to the lowest bit position
.ENDM

.macro  GPIOTurnOn   pin, value
	mov	X2, X9		// address of gpio regs
	add	X2, X2, #setregoffset // off to set reg
	mov	X0, #1		// 1 bit to shift into pos
	ldr	X3, =\pin	// base of pin info table
	add	X3, X3, #8	// add offset for shift amt
	ldr	W3, [X3]        // load shift from table
	lsl	X0, X0, X3	// do the shift
	str	W0, [X2]	// write to the register
.endm

.macro  GPIOTurnOff   pin, value
	mov	X2, X9		// address of gpio regs
	add	X2, X2, #clrregoffset // off set of clr reg
	mov	X0, #1		// 1 bit to shift into pos
	ldr	X3, =\pin	// base of pin info table
	add	X3, X3, #8    // add offset for shift amt
	ldr	W3, [X3]        // load shift from table
	lsl	X0, X0, X3	// do the shift
	str	W0, [X2]	// write to the register
.endm

	.data
timespecsec:   .dword   0
timespecnano:  .dword   100000000
devmem:	       .asciz  "/dev/gpiomem"
//devmem:	       .asciz  "/dev/mem"
memOpnErr:     .asciz  "Failed to open /dev/mem\n"
memOpnsz:      .word  .-memOpnErr 
memMapErr:     .asciz  "Failed to map memory\n"
memMapsz:      .word  .-memMapErr 
	       	   .align  4 // relign after strings
gpioaddr:      .dword   0x0	// mem address of gpio registers
//gpioaddr:      .dword   0xFE200000	// mem address of gpio registers


pin4:	   .word   0   // offset to select register
	       .word   12  // bit offset in select register
	       .word   4   // bit offset in set & clr register

pin17:	   .word   4   // offset to select register
	       .word   21  // bit offset in select register
	       .word   17  // bit offset in set & clr register

pin22:	   .word   8   // offset to select register
	       .word   6   // bit offset in select register
	       .word   22  // bit offset in set & clr register

pin27:	   .word   8   // offset to select register
	       .word   21  // bit offset in select register
	       .word   27  // bit offset in set & clr register

pin18:	   .word   4   // offset to select register
	       .word   24  // bit offset in select register
	       .word   18  // bit offset in set & clr register

pin23:	   .word   8   // offset to select register
	       .word   9   // bit offset in select register
	       .word   23  // bit offset in set & clr register

pin24:	   .word   8   // offset to select register
	       .word   12  // bit offset in select register
	       .word   24  // bit offset in set & clr register

pin25:	   .word   8   // offset to select register
	       .word   15  // bit offset in select register
	       .word   25  // bit offset in set & clr register

	.text
