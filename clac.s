// Justine Le and Tyler Kulikowski
// CS3B - clac - yippie io 5
// 5/13/25
// **************************************************************************************
// Program Description: This program implements a reverse polish notation
//                      calculator that reads user floating point operands
//                      and operators from the hex keypad and displays the
//                      user input and resulting calculations on the console.               
// **************************************************************************************
// Algorithm/Pseudocode
//  INITIALIZE          needed registers
//  CALL FNC            stackConstructor to allocate memory
//  KEYPAD LOOP
//      CALL FNC    getkey to get the key pressed
//      MACRO CALL  to map the input to the actual calculator value
//      CALL FNC    putch to print char to console
//      CHECK NEG   if key entered is the minus sign, check for negative operand input       
//          CALL FNC    getkey to get the next key pressed
//          MACRO CALL  to map the input to the actual calculator value 
//          CALL FNC    putch to print char to console
//          IF          next input is an enter, then branch out of CHECK NEG
//                      to perform input as a subtraction
//          ELSE        next input is a digit, then set the negative flag, and branch 
//                      out of CHECK NEG to continue building the operand 
//      NOT NEG     else, key is not minus sign, so check if the key is an operand/operator
//          IF          an operator, branch to perform the arithmetic on the operands
//          ELSE        its a digit, so branch to store the digit
//      STORE DIGIT in operand buffer      
//          CALL FNC    getkey to get the key pressed
//          MACRO CALL  to map the input to the actual calculator value
//          CALL FNC    putch to print char to console 
//          IF          next input is an enter, then branch to push the operand
//          ELSE        loop to STORE DIGIT
//      PUSH
//          CALL FNC    cstr2dfp to convert cstring operand to a dfp
//          CHECK       if the negative flag was set, and negate the dfp if set 
//          CALL FNC    push to push the dfp to the stack
//          LOOP        back to KEYPAD LOOP
//  OPERATOR
//      CALL FNC    getkey to get the enter (1st enter) in order to start doing calculations
//      MACRO CALL  to map the input to the actual calculator value
//      CALL FNC    putch to print char to console 
//      POP         2nd operand off stack and store
//      POP         1st operand off stack and store
//      PERFORM     specified operator on the two operands 
//      PUSH        result to the stack
//      CALL FNC    getkey to get next input
//      MACRO CALL  to map the input to the actual calculator value 
//      IF          another enter (2nd enter), printf the result to the console
//          CALL FNC    getkey to get the enter (1st enter) in order to start doing calculations
//          MACRO CALL  to map the input to the actual calculator value
//          IF          input is enter (3rd enter), branch out 
//          ELSE        branch back to KEYPAD LOOP
//      ELSE        call putch to print out next input and loop back to KEYPAD LOOP
//      CALL FNC    getkey to get the enter (1st enter) in order to start doing calculations
//  THIRD ENTER     
//      CALL FNC    delete
//      CALL FNC    stackDestructor
//  END PROGRAM 
// **************************************************************************************

.global _start // Program starting address

// passed in the key in X0 from getkey, this macro maps the key 
// to its actual ASCII value on the keypad 
.MACRO MAP_KEY 
    MOV X1, X0      // copy key to X1

    LDR X0, =sz1    // load in ASCII 1
    MOV X3, #0      // initialize w/ 0 indicating key is a digit or '.'
    MOV X2, #1      // load in key value being compared to 
    CMP X1, X2      // compare key input to 1
    B.EQ 1f         // branch if equal    

    LDR X0, =sz2    // load in ASCII 2
    MOV X3, #0      // initialize w/ 0 indicating key is a digit or '.'
    MOV X2, #2      // load in key value being compared to 
    CMP X1, X2      // compare key input to 2
    B.EQ 1f         // branch if equal    

    LDR X0, =sz3    // load in ASCII 3
    MOV X3, #0      // initialize w/ 0 indicating key is a digit or '.'
    MOV X2, #3      // load in key value being compared to 
    CMP X1, X2      // compare key input to 3
    B.EQ 1f         // branch if equal    

    LDR X0, =szDiv  // load in ASCII /
    MOV X3, #1      // initialize w/ 1 indicating key is an operator
    MOV X2, #4      // load in key value being compared to 
    CMP X1, X2      // compare key input to 4
    B.EQ 1f         // branch if equal    

    LDR X0, =sz4    // load in ASCII 4
    MOV X3, #0      // initialize w/ 0 indicating key is a digit or '.'
    MOV X2, #5      // load in key value being compared to 
    CMP X1, X2      // compare key input to 5
    B.EQ 1f         // branch if equal    

    LDR X0, =sz5    // load in ASCII 5
    MOV X3, #0      // initialize w/ 0 indicating key is a digit or '.'
    MOV X2, #6      // load in key value being compared to 
    CMP X1, X2      // compare key input to 6
    B.EQ 1f         // branch if equal    

    LDR X0, =sz6    // load in ASCII 6
    MOV X3, #0      // initialize w/ 0 indicating key is a digit or '.'
    MOV X2, #7      // load in key value being compared to 
    CMP X1, X2      // compare key input to 7
    B.EQ 1f         // branch if equal 

    LDR X0, =szMult // load in ASCII x
    MOV X3, #1      // initialize w/ 1 indicating key is an operator
    MOV X2, #8      // load in key value being compared to 
    CMP X1, X2      // compare key input to 8
    B.EQ 1f         // branch if equal    

    LDR X0, =sz7    // load in ASCII 7
    MOV X3, #0      // initialize w/ 0 indicating key is a digit or '.'
    MOV X2, #9      // load in key value being compared to 
    CMP X1, X2      // compare key input to 9
    B.EQ 1f         // branch if equal    

    LDR X0, =sz8    // load in ASCII 8
    MOV X3, #0      // initialize w/ 0 indicating key is a digit or '.'
    MOV X2, #10     // load in key value being compared to 
    CMP X1, X2      // compare key input to 10
    B.EQ 1f         // branch if equal    

    LDR X0, =sz9    // load in ASCII 9
    MOV X3, #0      // initialize w/ 0 indicating key is a digit or '.'
    MOV X2, #11     // load in key value being compared to 
    CMP X1, X2      // compare key input to 11
    B.EQ 1f         // branch if equal    

    LDR X0, =szSub  // load in ASCII -
    MOV X3, #1      // initialize w/ 1 indicating key is an operator
    MOV X2, #12     // load in key value being compared to 
    CMP X1, X2      // compare key input to 12
    B.EQ 1f         // branch if equal    

    LDR X0, =szDec  // load in ASCII .
    MOV X3, #0      // initialize w/ 0 indicating key is a digit or '.'
    MOV X2, #13     // load in key value being compared to 
    CMP X1, X2      // compare key input to 13
    B.EQ 1f         // branch if equal    

    LDR X0, =sz0    // load in ASCII 0
    MOV X3, #0      // initialize w/ 0 indicating key is a digit or '.'
    MOV X2, #14     // load in key value being compared to 
    CMP X1, X2      // compare key input to 14
    B.EQ 1f         // branch if equal    

    LDR X0, =szEnter// load in ASCII " "
    MOV X3, #1      // initialize w/ 1 indicating key is an operator
    MOV X2, #15     // load in key value being compared to 
    CMP X1, X2      // compare key input to 15
    B.EQ 1f         // branch if equal    

    LDR X0, =szAdd  // load in ASCII +
    MOV X3, #1      // initialize w/ 1 indicating key is an operator
    MOV X2, #16     // load in key value being compared to 
    CMP X1, X2      // compare key input to 16
    B.EQ 1f         // branch if equal    
1:
.ENDM 

    .EQU STACK_SZ, 100  // stack size
    .EQU DATA_SZ, 8     // data size

    .EQU SYS_exit, 93 // exit() supervisor call code

_start:

    .text // Code section

    MOV X22, #0                 // initialize 'Enter' count to 0
    MOV X24, #0                 // negative flag (not set)
   
    MOV X0, #STACK_SZ           // load in stack size
    MOV X1, #DATA_SZ            // load in size of data
    BL stackConstructor         // fnc call to allocate space for the stack

keypadLoop:
    BL getkey           // call function to get key pressed  
    MAP_KEY             // call macro to map key to keyboard input    
    MOV X4, X2          // store raw key code (1-16)
    MOV X9, X0          // save pointer to keyboard input
    BL putch            // print input to console 

    // check for negative
    CMP X4, #12         // check for negative
    B.NE notNeg         // if equal jump to check if the value is negative
    MOV X25, X4         // save possible operator 

checkNeg:
    BL getkey           // call function to get key pressed  
    MAP_KEY             // call macro to map key to keyboard input    
    MOV X4, X2          // store raw key code (1-16)
    MOV X9, X0          // save the value
    BL putch            // print input to console 

    CMP X4, #15         // check if it is enter
    B.EQ notNeg         // branch to perform operation
    
    MOV X24, #1              // set negative flag
    B storeDigit             // branch to store the digit

notNeg:
    CMP X3, #0          // check if input is a digit or '.'
    B.NE operator       // branch if not equal (input is an operator or enter)  

storeDigit:
    LDR X19, =szOperandBuff  // load in buffer to store operand
    MOV X23, X19             // save the base pointer 
    LDRB W0, [X9]            // deref 
    STRB W0, [X23], #1       // store digit or '.' in buffer and increment pointer in buff

buildOperand:  
    BL getkey           // call function to get key pressed  
    MAP_KEY             // call macro to map key to keyboard input  
    MOV X4, X2          // save raw input key  
    MOV X9, X0          // save keyboard input
    BL putch            // print input to console 

    CMP X4, #15         // check if input is an enter 
    B.EQ enterOperand   // branch if an enter

    LDRB W0, [X9]       // deref     
    STRB W0, [X23], #1  // store digit or '.' in buffer and increment pointer in buff
    B buildOperand      // else loop again 

// this pushes the operand (dfp) onto the stack if there is an enter
enterOperand: 
    STRB WZR, [X23]     // null terminate the cstring
    MOV X0, X19         // load in base pointer to the operand buffer
    BL cstr2dfp         // convert cstring double to dfp
    
    CMP X24, #1         // check if neg flag set
    B.NE continuePush   // branch if not equal

    FNEG D0, D0         // if negative, negate value 

continuePush:
    BL push             // fnc call to push operand onto stack 

    MOV X24, #0         // reset negative flag
    B keypadLoop        // loop to get next input

operator:
    CMP X4, #15         // check if input is an enter 
    B.EQ enter1         // branch if equal

    MOV W25, W4         // save operator 

    // get enter to perform operator calculation 
    BL getkey           // call function to get key pressed  
    MAP_KEY             // call macro to map key to keyboard input    
    MOV X4, X2          // save raw input key
    MOV X9, X0          // save keyboard input
    BL putch            // print input to console 

    MOV X0, X9          // rstore keyboard input
    CMP X4, #15         // check if input is an enter 
    B.EQ enter1         // branch if equal
    B keypadLoop        // else loop again to get next input

enter1:
    ADD X22, X22, #1    // increment enter counter
    CMP X22, #1         // check if this is the 1st enter
    B.GT enter2         // branch if greater than 1 enter

    BL pop              // pop rhs operator 
    FMOV D2, D0         // save rhs operator
    BL pop              // pop lhs operator
    FMOV D1, D0         // save the lhs

    CMP W25, #16        // check if addition
    B.NE subtract       // branch if not addition

    // ADD
    FADD D0, D1, D2     // sum = lhs + rhs
    BL push             // push result to the stack            
    B checkEnter2       // branch to check for a 2nd enter

subtract:
    CMP W25, #12        // check if subtraction
    B.NE multiply       // branch if not subtraction

    // SUBTRACT
    FSUB D0, D1, D2     // difference = lhs - rhs
    BL push             // push result to the stack            
    B checkEnter2       // branch to check for a 2nd enter

multiply:
    CMP W25, #8         // check if multiplication
    B.NE divide         // branch if not multiplication

    // MULTIPLY 
    FMUL D0, D1, D2    // product = lhs * rhs
    BL push             // push result to the stack            
    B checkEnter2       // branch to check for a 2nd enter

divide:
    // DIVIDE 
    FDIV D0, D1, D2     // quotient = lhs / rhs
    BL push             // push result to the stack            

checkEnter2:
    BL getkey           // call function to get key pressed  
    MAP_KEY             // call macro to map key to keyboard input    
    
    CMP X2, #15         // check if input is an enter 
    B.EQ beforeEnter2   // branch if an enter

    MOV X22, #0         // else, reset enter count to 0 
    B keypadLoop        // loop to get next input

beforeEnter2:
    ADD X22, X22, #1    // increment enter count to 2

enter2:
    CMP X22, #2         // check if this is the 2nd enter
    B.GT enter3         // branch if greater than 2 enters

    BL pop              // pop result from the stack
    FMOV D8, D0         // save the result 
    LDR X0, =szFmt      // load in formatting
    BL printf           // print result 
    FMOV D8, D16         // move back the result
    BL push             // push result back
    
    // check for 3rd enter 
    BL getkey           // call function to get key pressed  
    MAP_KEY             // call macro to map key to keyboard input    
    
    CMP X2, #15        // check if input is an enter 
    B.EQ enter3         // branch if it is the 3rd enter

    MOV X22, #0         // else, reset enter count to 0 
    B keypadLoop        // loop to get next input

enter3:
    BL delete           // fnc call to reset the stack pointer
    BL stackDestructor  // fnc call to stack destructor

terminate:
    // terminate program
    MOV X0, #0           // load 0 (exit okay)
    MOV X8, #SYS_exit    // syscall to exit 
    SVC 0                // Linux call

    .data // Data section
szOperandBuff:    .skip 64

szFmt:  .asciz  "%.20f\n"
sz1:    .asciz  "1"
sz2:    .asciz  "2"
sz3:    .asciz  "3"
sz4:    .asciz  "4"
sz5:    .asciz  "5"
sz6:    .asciz  "6"
sz7:    .asciz  "7"
sz8:    .asciz  "8"
sz9:    .asciz  "9"
sz0:    .asciz  "0"
szDiv:    .asciz  "/"
szMult:   .asciz  "x"
szSub:    .asciz  "-"
szAdd:    .asciz  "+"
szEnter:  .asciz  " "
szDec:    .asciz  "."


.end

