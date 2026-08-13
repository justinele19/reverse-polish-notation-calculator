// Justine Le and Tyler Kulikowski
// CS3B - stack.s - clac (Yippie IO Part 5)
// 5/13/25
// ***************************************************************************
// Program Description:
// This file implements a dynamic stack for use with a reverse Polish 
// notation calculator. The stack supports double-precision floating 
// point values and provides the five core stack operations: constructor, 
// destructor, push, pop, and delete. It uses malloc and free for memory 
// management and protects against stack overflow and underflow conditions.
//
// The stack is dynamically allocated based on a provided size and stores 
// 8-byte doubles. Overflow results in the push being ignored (and returning 0), 
// while popping from an empty stack returns 0.0. This stack is used in 
// conjunction with a driver or higher-level RPN logic.
// ***************************************************************************
// Algorithm/Pseudocode
//  FUNCTION: stackConstructor(stackSize, dataSize)
//    CALCULATE     total memory needed = stackSize * dataSize
//    CALL          malloc to allocate memory
//    STORE         result in basePtr and initialize stackPtr = basePtr
//    SAVE          stackSize and dataSize to globals
//
//  FUNCTION: stackDestructor()
//    LOAD          basePtr
//    CALL          free(basePtr)
//
//  FUNCTION: push(double value)
//    CHECK         if stackPtr >= basePtr + stackSize * dataSize → overflow
//    STORE         value at current stackPtr
//    INCREMENT     stackPtr by dataSize
//    RETURN        1 on success, 0 on overflow
//
//  FUNCTION: pop()
//    CHECK         if stackPtr == basePtr → underflow
//    DECREMENT     stackPtr by dataSize
//    LOAD          and return double value from stack
//    RETURN        0.0 on underflow
//
//  FUNCTION: delete()
//    RESET         stackPtr = basePtr
// ***************************************************************************

.global stackConstructor
.global stackDestructor
.global push
.global pop
.global delete

    .text                        // Begin code section

//*****************************************************************************
// stackConstructor(int stackSize, int dataSize)
// Allocates memory for the stack.
// X0 = stackSize, X1 = dataSize
//*****************************************************************************
stackConstructor:
    STP X29, X30, [SP, #-16]!    // Save frame pointer and link register onto stack
    MOV X20, X0                   // X2 = stackSize (save for later)
    MOV X21, X1                   // X3 = dataSize (save for later)

    MUL X4, X0, X1               // X4 = total size of stack = stackSize * dataSize
    MOV X0, X4                   // Prepare malloc(size) call
    BL malloc                    // Allocate memory; result (pointer) in X0

    LDR X5, =basePtr             // Load address of basePtr variable
    STR X0, [X5]                 // Store malloc result in basePtr

    LDR X6, =stackPtr            // Load address of stackPtr variable
    STR X0, [X6]                 // Initialize stackPtr = basePtr

    LDR X7, =stackSize           // Load address of stackSize variable
    STR X20, [X7]                 // Save stackSize

    LDR X8, =dataSize            // Load address of dataSize variable
    STR X21, [X8]                 // Save dataSize

    LDP X29, X30, [SP], #16      // Restore frame pointer and link register
    RET                          // Return from function

//*****************************************************************************
// stackDestructor()
// Frees the stack memory allocated by malloc
//*****************************************************************************
stackDestructor:
    STP X29, X30, [SP, #-16]!    // Save frame and link register

    LDR X0, =basePtr             // Load address of basePtr
    LDR X0, [X0]                 // Load actual base pointer (malloc result)
    BL free                      // Free the memory

    LDP X29, X30, [SP], #16      // Restore frame and link
    RET                          // Return from function

//*****************************************************************************
// int push(double value)
// D0 = double value to push
// Returns X0 = 1 if success, 0 if overflow
//*****************************************************************************
push:
    STP X29, X30, [SP, #-16]!        // Save frame pointer and return address

    LDR X1, =basePtr                 // Load address of basePtr
    LDR X1, [X1]                     // X1 = basePtr

    LDR X2, =stackPtr                // Load address of stackPtr
    LDR X2, [X2]                     // X2 = stackPtr

    LDR X3, =stackSize               // Load address of stackSize
    LDR X3, [X3]                     // X3 = stackSize

    LDR X4, =dataSize                // Load address of dataSize
    LDR X4, [X4]                     // X4 = dataSize

    MUL X5, X3, X4                   // X5 = max size in bytes
    ADD X6, X1, X5                   // X6 = basePtr + (stackSize * dataSize)

    CMP X2, X6                       // Compare stackPtr to maxPtr
    B.GE push_overflow               // If stack is full, skip push

    STR D0, [X2]                     // Store the double value into memory at stackPtr

    ADD X2, X2, X4                   // stackPtr += dataSize
    LDR X7, =stackPtr
    STR X2, [X7]                     // Update stackPtr

    MOV X0, #1                       // Return success
    LDP X29, X30, [SP], #16          // Restore frame and return
    RET

push_overflow:
    MOV X0, #0                       // Return failure
    LDP X29, X30, [SP], #16
    RET

//*****************************************************************************
// double pop()
// Returns D0 = double value from top of stack
//*****************************************************************************
pop:
    STP X29, X30, [SP, #-16]!        // Save frame and return address

    LDR X1, =basePtr                 // Load address of basePtr
    LDR X1, [X1]                     // X1 = basePtr

    LDR X2, =stackPtr                // Load address of stackPtr
    LDR X2, [X2]                     // X2 = stackPtr

    CMP X2, X1                       // If stackPtr == basePtr, stack is empty
    B.EQ pop_underflow

    LDR X3, =dataSize                // Load address of dataSize
    LDR X3, [X3]                     // X3 = dataSize
    SUB X2, X2, X3                   // Move pointer down one double

    LDR X4, =stackPtr
    STR X2, [X4]                     // Update stackPtr

    LDR D0, [X2]                     // Load double value into D0 to return
    LDP X29, X30, [SP], #16
    RET

pop_underflow:
    FMOV D0, XZR                     // Return 0.0 if underflow
    LDP X29, X30, [SP], #16
    RET                              // Return

//*****************************************************************************
// delete()
// Resets stackPtr = basePtr
//*****************************************************************************
delete:
    STP X29, X30, [SP, #-16]!    // Save frame and link

    LDR X0, =basePtr             // Load address of basePtr
    LDR X0, [X0]                 // X0 = basePtr

    LDR X1, =stackPtr            // Load address of stackPtr
    STR X0, [X1]                 // stackPtr = basePtr

    LDP X29, X30, [SP], #16      // Restore frame and link
    RET                          // Return

//*****************************************************************************
// Static data for global variables
//*****************************************************************************
    .data

basePtr:     .quad 0             // Pointer to bottom of stack memory
stackPtr:    .quad 0             // Pointer to top of current stack
stackSize:   .quad 0             // Total stack capacity (in elements)
dataSize:    .quad 0             // Size of each stack element (in bytes)

.end                              // End of source file
