// Justine Le and Tyler Kulikowski
// CS3B - getkey - yippie io 4 
// 5/6/25
// ******************************************************************************
// Function getkey: This function gets the user input from the 4x4 hex keypad.
//                  This function always runs in blocking mode, continuously 
//                  running until a key is entered. The function will
//                  return the key pressed (1-16).                 
//
// X0: Contains the return key value (1-16)
// LR: Contains the return address (automatic when BL is used)
// Registers X0 - X8 are modified and not preserved
// ******************************************************************************
// Algorithm/Pseudocode
//  STORE               the mode on the stack
//  CALL MACROS         to set the pins as output or input
//  POP                 the mode from the stack and check what mode it is in
//  IF BLOCKING         loop until bool isKeyPressed == true
//    CALL MACRO        CHECK_KEY_IS_ON which turns on each row and checks if any of
//                      the columns are also high by calling macro GPIOReadLevelBit
//                      for each input pin 
//      CALL MACRO      GET_KEY_NUM if a column was detected to be high then store
//                      the correlated key in a register 
//  ELSE NON-BLOCKING   
//    INITIALIZE        key = 0
//    SAME MACRO        calling logic as in the blocking mode
//  RETURN              the key pressed in X0
// ******************************************************************************

#include "gpiomem.S"

.global getkey // Program starting address

.MACRO CHECK_KEY_IS_ON 
    GPIOTurnOn    pin4			// turn on row 1
    nanoSleep		            // time delay		
	GPIOReadLevelBit pin18		// check if col 1 is high
    MOV X5, #1                  // move key parameter
    GET_KEY_NUM X5              // call macro to load key if on            
	GPIOReadLevelBit pin23		// check if col 2 is high
    MOV X5, #2                  // load key parameter
    GET_KEY_NUM X5              // call macro to load key if on   
	GPIOReadLevelBit pin24		// check if col 3 is high
    MOV X5, #3                  // load key parameter
    GET_KEY_NUM X5              // call macro to load key if on   
    GPIOReadLevelBit pin25		// check if col 4 is high
    MOV X5, #4                  // load key parameter
    GET_KEY_NUM X5              // call macro to load key if on   
	nanoSleep		            // time delay		
	GPIOTurnOff   pin4	        // turn off row 1

	GPIOTurnOn    pin17         // turn on row 2
    nanoSleep		            // time delay		
    GPIOReadLevelBit pin18		// check if col 1 is high
    MOV X5, #5                  // move key parameter
    GET_KEY_NUM X5              // call macro to load key if on            
	GPIOReadLevelBit pin23		// check if col 2 is high
    MOV X5, #6                  // load key parameter
    GET_KEY_NUM X5              // call macro to load key if on   
	GPIOReadLevelBit pin24		// check if col 3 is high
    MOV X5, #7                  // load key parameter
    GET_KEY_NUM X5              // call macro to load key if on   
    GPIOReadLevelBit pin25		// check if col 4 is high
    MOV X5, #8                  // load key parameter
    GET_KEY_NUM X5              // call macro to load key if on   
    nanoSleep                   // time delay
    GPIOTurnOff   pin17         // turn off row 2

    GPIOTurnOn    pin27         // turn on row 3
    nanoSleep		            // time delay		
	GPIOReadLevelBit pin18		// check if col 1 is high
    MOV X5, #9                  // move key parameter
    GET_KEY_NUM X5              // call macro to load key if on            
	GPIOReadLevelBit pin23		// check if col 2 is high
    MOV X5, #10                 // load key parameter
    GET_KEY_NUM X5              // call macro to load key if on   
	GPIOReadLevelBit pin24		// check if col 3 is high
    MOV X5, #11                 // load key parameter
    GET_KEY_NUM X5              // call macro to load key if on   
    GPIOReadLevelBit pin25		// check if col 4 is high
    MOV X5, #12                 // load key parameter
    GET_KEY_NUM X5              // call macro to load key if on     
    nanoSleep                   // time delay
    GPIOTurnOff   pin27         // turn off row 3
		
    GPIOTurnOn    pin22         // turn on row 4
    nanoSleep		            // time delay		
	GPIOReadLevelBit pin18		// check if col 1 is high
    MOV X5, #13                 // move key parameter
    GET_KEY_NUM X5              // call macro to load key if on            
	GPIOReadLevelBit pin23		// check if col 2 is high
    MOV X5, #14                 // load key parameter
    GET_KEY_NUM X5              // call macro to load key if on   
	GPIOReadLevelBit pin24		// check if col 3 is high
    MOV X5, #15                 // load key parameter
    GET_KEY_NUM X5              // call macro to load key if on   
    GPIOReadLevelBit pin25		// check if col 4 is high
    MOV X5, #16                 // load key parameter
    GET_KEY_NUM X5              // call macro to load key if on   
    nanoSleep                   // time delay 
    GPIOTurnOff   pin22         // turn off row 4
.ENDM

// macro to get the key 
.MACRO GET_KEY_NUM key
    CMP X0, #0			// check if column (input) is high
	B.EQ 1f				// branch and don't print if not high

    MOV X6, \key        // else load in key
    MOV X7, #1          // set isKeyPressed == true 
1:
.ENDM

getkey:

    .text // Code section
    
    mapMem                  // macro call to map memory for GPIO Registers
    nanoSleep               // time delay

	GPIODirectionOut pin4   // pin 4 = output
    GPIODirectionOut pin17  // pin 17 = output
    GPIODirectionOut pin27  // pin 27 = output
    GPIODirectionOut pin22  // pin 22 = output

	GPIODirectionIn pin18	// pin 18 = input
	GPIODirectionIn pin23	// pin 23 = input
	GPIODirectionIn pin24	// pin 24 = input
	GPIODirectionIn pin25	// pin 25 = input


    MOV X7, #0              // initialize bool isKeyPressed == false

blocking_loop:
    CMP X7, #1              // check if key is pressed
    B.EQ end_getkey         // if key is pressed, branch to end

    CHECK_KEY_IS_ON         // check if a key is on 
   
    B blocking_loop         // loop again

end_getkey:
    MOV X0, X6      // move returning key into X0   
    RET             // return to caller 

    .data // Data section

.end
