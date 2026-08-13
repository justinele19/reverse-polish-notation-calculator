// Justine Le
// CS3B - lab1-2 - putch
// 1/24/25
//
// Function putch: Provided a pointer to a char, putch will
// output the char on the console
//
// Algorithm/Pseudocode:
//    SET     registers for the pointer to the char
//    SET     Linux registers to call
//    CALL    Linux to write char
//    RETURN  to calling function 
//    
// ************************************************************
// X0: Must point to a char in memory
// LR: Must contain the return address (automatic when BL
//     is used for the call)
// All register except X0, X1, X2, X8 are preserved
// ************************************************************

.global putch  // Provide function starting address

putch:

    .text  // code section

// Setup the parameters to print the character
// and then call Linux to do it.
    MOV X1, X0       // Set X1 to be the pointer to the char
    MOV X2, #1       // Set the character length 
    MOV X0, #1	     // Stdout=1 (return code)
    MOV X8, #64	     // Linux write system call
    SVC 0            // Call Linux to output the char

    RET              // Return to calling function 

.end   // end of function
