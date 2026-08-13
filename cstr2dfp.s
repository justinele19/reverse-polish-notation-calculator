// Justine Le
// CS3B - lab12-2 - Double Dutch 
// 4/18/25
// *****************************************************************************
// Function cstr2dfp: Provided a pointer to a C-String representing a valid 
//                    floating point number, converts it to a double floating
//                    point value. 
//
// X0: Must point to a null terminated string that is a valid signed floating
//     point number.
// D0: signed double floating point result
// LR: Contains the return address (automatic when BL is used)
// Registers X0 - X8 are modified and not preserved
// *****************************************************************************
// Algorithm/Pseudocode
//  INITIALIZE  accumulator = 0 
//  CHECK       1st char for negative sign '-'
//  IF          negative sign  
//      SET         negative flag
//  LOOP (whole) through cstring until decimal is found
//    CONVERT      char->int and add int to accumulator 
//    INCRMENT     to next char
//    IF           NULL is read 
//     RETURN        the integer whole number 
//  LOOP DONE (whole)
//  INCREMENT   pointer to point one pass the decimal 
//  INITIALIZE  divisor = 10
//  LOOP (fraction) until end of fractional part 
//    CONVERT       char->int and divide by divisor
//    ADD           int to accumulator    
//    MULTIPLY      divisor by 10
//    INCREMENT     pointer to next char and check for NULL
//      IF    NULL
//          branch 
//      ELSE  loop again 
//  LOOP DONE (fraction)
//  CHECK   negative flag 
//      IF  negative flag set
//         NEGATE decimal integer 
//      ELSE branch 
//  RETURN 
// *****************************************************************************

.global cstr2dfp // Program starting address

cstr2dfp:

    .text // Code section

    MOV X6, X0          // copy pointer to cstring into X5
    MOV X0, #0          // initialize accumulator to 0
    SCVTF D0, X0        // signed integer to double FP
    FMOV D4, #10        // holds constant 10.0 
    MOV X7, #0          // initialize negative flag 

    LDRB W1, [X6]       // load 1 byte of cstring
    CMP W1, #'-'        // check if 1st char is the negative sign
    B.NE whole_loop     // if not equal, branch to start converting whole number part of cstring

    MOV X7, #1          // set negative flag 
    ADD X6, X6, #1      // increment cstring pointer 

whole_loop:
    LDRB W1, [X6]          // load the next char after negative sign 
    FMOV D3, #10           // initialize constant value

mult_loop:
    FMUL D0, D0, D3        // res *= 10.0
    SUB W1, W1, #'0'       // digit = char - '0'
    SCVTF D1, X1           // convert int to double FP
    FADD D0, D0, D1        // res += digit 

    ADD X6, X6, #1         // increment pointer
    LDRB W1, [X6]          // load next char into temp register 
    CMP W1, #'.'           // check if decimal is reached
    B.EQ whole_loopdone    // if equal, branch

    CMP W1, #0             // check if NULL is met
    B.EQ check_neg         // branch if NULL is met

    B mult_loop            // continue looping

whole_loopdone:
    ADD X6, X6, #1      // increment pointer to one pass the decimal 
    LDRB W1, [X6]       // load in next char 
    FMOV D3, D4         // divisor = 10.0

fraction_loop:
    SUB W1, W1, #'0'    // digit = char - '0'
    SCVTF D1, X1        // convert digit to single precision floating point

    FDIV D5, D1, D3     // fraction = digit / divisor
    FADD D0, D0, D5     // accumulator += fraction 
    FMUL D3, D3, D4     // multiply divisor by 10.0

    ADD X6, X6, #1      // increment pointer
    LDRB W1, [X6]       // load next char into temp register 
    CMP W1, #0          // check if NULL is reached
    B.EQ check_neg      // branch if equal 

    B fraction_loop     // loop again 

check_neg:
    CMP X7, #1          // check if negative flag is set
    B.NE function_end   // branch if flag is not set 
    FNEG D0, D0         // negate decimal  

function_end:
    RET         // return to caller

.end
