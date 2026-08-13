// Justine Le
// CS3B - lab4-1 - putstring
// 2/6/25
// 
// Function putstring: Provided a pointer to a null terminated
// string in X0, will output the string on the console.
//
// Algorithm/Pseudocode:
//   STORE      string pointer 
//   STORE      return address
//   FUNC CALL  to String_length to get string length
//   RESTORE    the string pointer
//   SET        register with the string's length
//   SET        Linux registers to call
//   CALL       Linux to write string
//   RESTORE    string pointer to original register
//   RESTORE    return address         
//   RETURN     to calling function
//
// ************************************************************
// X0: Must point to a null terminated string
// LR: Must contain the return address (automatic when BL
//     is used for the call)
// All registers except X0, X1, X2, X3, and X8 are preserved
// ************************************************************

.global putstring  // Provide function starting address

putstring: 

    .EQU SYS_exit, 93  // exit() supervisor call code

    .text  // code section
  
    MOV X8, X0    // temporarily move pointer into X8
    MOV X3, LR    // temporarily move the return address into X3

    BL String_length    // call String_length, result in X0

    MOV X1, X8    // restore string pointer to X1
    MOV X2, X0    // move string length into X2

    MOV X0, #1    // Stdout=1 (return code)
    MOV X8, #64   // Linux write system call
    SVC 0         // call Linux to output the string 

    MOV X0, X8    // restore X0 (original pointer)
    MOV LR, X3    // restore return address
  
    RET           // return to calling function
   
.end  // end of function



