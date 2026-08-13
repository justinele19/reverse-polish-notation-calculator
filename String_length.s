// Justine Le
// CS3B - lab4-1 - String length
// 2/6/25
// 
// Function String_length: Provided a pointer to a null
// terminated pointer string in X0, will return the 
// string's length in X0
// 
// Algorithm/Pseudocode:
//    SET     register for the pointer to the string 
//    SET     string length counter 
//    WHILE   string length is NOT null
//      INCR  string pointer 
//      INCR  length by 1
//    SET     returning register with string length
//    RETURN  to call function 
//
// ************************************************************
// X0: Must point to a null terminated string
// LR: Must contain the return address (automatic when BL
//     is used for the call)
// All registers except X0, X1, and X2 are preserved
// ************************************************************

.global String_length  // Provide function starting address

String_length: 

    .EQU SYS_exit, 93  // exit() supervisor call code

    .text  // code section
  
    MOV X1, X0    // copy string pointer into X1
    MOV X2, #0    // initialize string length counter

loop:
    LDRB W0, [X1], #1    // load a byte into W0 and advance pointer
    CMP W0, #0           // compare with NULL (zero)
    B.EQ loopdone        // branch if the pointer reaches a NULL
    ADD X2, X2, #1       // increment length counter
    B loop               // loop again

loopdone:
    MOV X0, X2    // move string length into X0 (return value)

    RET           // return to calling function
   
.end  // end of function


