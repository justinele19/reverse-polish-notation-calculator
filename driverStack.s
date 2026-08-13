// Justine Le and Tyler Kulikowski
// CS3B - driverStack.s - clac (Yippie IO Part 5)
// 5/13/25
// ***************************************************************************
// Program Description:
// This driver tests the functionality of the dynamic stack implemented 
// in stack.s. It initializes the stack, performs push and pop operations 
// with double values, and outputs the popped results using printf.
//
// The stack size for this driver test is 5, and will show that push, pop,
// delete, and over/under flow detection/protection properly works.
// ***************************************************************************
// Algorithm/Pseudocode
//  CALL            stackConstructor with size 5, dataSize 8
//  LOAD            D0 with 1.0
//  CALL            push(D0) — expect success
//  LOAD            D0 with 2.0
//  CALL            push(D0) — expect success
//  LOAD            D0 with 3.0
//  CALL            push(D0) — expect success
//  LOAD            D0 with 4.0
//  CALL            push(D0) — expect success
//  LOAD            D0 with 5.0
//  CALL            push 6.0 (D0) — expect overflow, return 0
//  CALL            pop() → returns 5.0 in D0
//  LOAD            format string into X0
//  CALL            printf to output 5.0
//  CALL            pop() → returns 4.0 in D0
//  LOAD            format string into X0
//  CALL            printf to output 4.0
//  CALL            pop() → returns 3.0 in D0
//  LOAD            format string into X0
//  CALL            printf to output 3.0
//  CALL            pop() → returns 2.0 in D0
//  LOAD            format string into X0
//  CALL            printf to output 2.0
//  CALL            pop() → returns 1.0 in D0
//  LOAD            format string into X0
//  CALL            printf to output 1.0
//  CALL            pop() → expect underflow, return 0.0
//  CALL            push(9.0) — should succeed after pops
//  CALL            delete() — reset stackPtr to basePtr
//  CALL            pop() → expect underflow, return 0.0
//  CALL            stackDestructor to free memory
//  RETURN          0 from main
// ***************************************************************************


.global _start // Program starting address

    .EQU SYS_exit, 93 // exit() supervisor call code

_start:

    .text // Code section

    MOV X0, #5                    // Set X0 = 5 (stack size = 3 elements)
    MOV X1, #8                    // Set X1 = 8 (data size = 8 bytes per double)
    BL stackConstructor           // Call stackConstructor(3, 8)

    // --- Push 1.0 ---
    FMOV D0, #1                   // Move 1.0 into D0 for pushing
    FMOV D1, D0                    // Save a copy of 1.0 into D1 for printing
    BL push                       // Call push(D0)
    CMP X0, #0                    // Compare return value to 0 (failure)
    B.EQ push1_fail                // If equal, jump to push1_fail
    LDR X0, =pushMsg              // Load address of success message
    FMOV D0, D1                   // Restore 1.0 into D0 for printf
    BL printf                     // Print "Pushed: 1.0"
    B after_push1                 // Skip failure block
push1_fail:                       // Label: push failed (overflow)
    LDR X0, =pushFailMsg          // Load address of overflow message
    FMOV D0, D1                   // Restore 1.0 for printf
    BL printf                     // Print overflow message
after_push1:                      // Label: end of first push block

    // --- Push 2.0 ---
    FMOV D0, #2                   // Move 2.0 into D0
    FMOV D1, D0                    // Save copy into D1
    BL push                       // Call push(D0)
    CMP X0, #0                    // Check result
    B.EQ push2_fail                // Jump to failure if needed
    LDR X0, =pushMsg              // Load success format string
    FMOV D0, D1                   // Restore 2.0 to D0
    BL printf                     // Print "Pushed: 2.0"
    B after_push2                 // Skip failure message
push2_fail:                       // Label: push 2.0 failed
    LDR X0, =pushFailMsg          // Load overflow message
    FMOV D0, D1                   // Restore 2.0
    BL printf                     // Print overflow message
after_push2:                      // Label: end of second push block

    // --- Push 3.0 ---
    FMOV D0, #3                   // Move 3.0 into D0
    FMOV D1, D0                    // Save for printing
    BL push                       // Push it
    CMP X0, #0                    // Check for success
    B.EQ push3_fail                // Branch to failure if needed
    LDR X0, =pushMsg              // Load success format
    FMOV D0, D1                   // Restore 3.0
    BL printf                     // Print message
    B after_push3                 // Skip failure
push3_fail:                       // Label: push 3.0 failed
    LDR X0, =pushFailMsg          // Load failure string
    FMOV D0, D1                   // Restore 3.0
    BL printf                     // Print error
after_push3:                      // Label: done with 3.0 push

    // --- Push 4.0  ---
    FMOV D0, #4                   // Move 4 into D0
    FMOV D1, D0                    // Save value
    BL push                       // Attempt push
    CMP X0, #0                    // Check for failure
    B.EQ push4_fail                // If failed (as expected), handle
    LDR X0, =pushMsg              // (unexpected) success format
    FMOV D0, D1                   // Restore 4.0
    BL printf                     // Print message
    B after_push4                 // Skip failure
push4_fail:                       // Label: overflow occurred (expected)
    LDR X0, =pushFailMsg          // Load message
    FMOV D0, D1                   // Restore 4.0
    BL printf                     // Print overflow message
after_push4:                      // End of push 4.0 test

    // --- Push 5.0  ---
    FMOV D0, #5                   // Move 5 into D0
    FMOV D1, D0                    // Save value
    BL push                       // Attempt push
    CMP X0, #0                    // Check for failure
    B.EQ push5_fail                // If failed (as expected), handle
    LDR X0, =pushMsg              // (unexpected) success format
    FMOV D0, D1                   // Restore 5.0
    BL printf                     // Print message
    B after_push5                 // Skip failure
push5_fail:                       // Label: overflow occurred (expected)
    LDR X0, =pushFailMsg          // Load message
    FMOV D0, D1                   // Restore 5.0
    BL printf                     // Print overflow message
after_push5:                      // End of push 5.0 test

    // --- Push 6.0 (will fail) ---
    FMOV D0, #6                   // Move 6 into D0
    FMOV D1, D0                    // Save value
    BL push                       // Attempt push
    CMP X0, #0                    // Check for failure
    B.EQ push6_fail                // If failed (as expected), handle
    LDR X0, =pushMsg              // (unexpected) success format
    FMOV D0, D1                   // Restore 6.0
    BL printf                     // Print message
    B after_push6                 // Skip failure
push6_fail:                       // Label: overflow occurred (expected)
    LDR X0, =pushFailMsg          // Load message
    FMOV D0, D1                   // Restore 6.0
    BL printf                     // Print overflow message
after_push6:                      // End of push 6.0 test

    // --- Pop 5 values ---
    BL pop                        // Pop (should get 5.0)
    LDR X0, =popMsg               // Load format string
    BL printf                     // Print value

    BL pop                        // Pop (should get 4.0)
    LDR X0, =popMsg               // Load format string
    BL printf                     // Print value

    BL pop                        // Pop (should get 3.0)
    LDR X0, =popMsg               // Load format string
    BL printf                     // Print value

    BL pop                        // Pop (should get 2.0)
    LDR X0, =popMsg               // Load format string
    BL printf                     // Print value

    BL pop                        // Pop (should get 1.0)
    LDR X0, =popMsg               // Load format string
    BL printf                     // Print value

    // --- Pop again (should underflow) ---
    BL pop                        // Attempt to pop (stack is empty)
    FMOV D1, D0                   // Save result
    MOV X2, #0                    // move in 0 into X2
    SCVTF D2, X2                    // signed integer to double FP
    FCMP D1, D2                   // Compare result to 0.0
    B.EQ pop_underflow            // If equal, it underflowed
    LDR X0, =popMsg               // Otherwise print popped value
    FMOV D0, D1
    BL printf
    B after_pop_extra             // Skip underflow message
pop_underflow:                    // Label: underflow occurred
    LDR X0, =underflowMsg         // Load underflow string
    BL printf                     // Print underflow message
after_pop_extra:                  // Label: end of extra pop

    // --- Push 9.0 (should succeed again) ---
    FMOV D0, #9                   // Load 9.0 into D0
    FMOV D1, D0                    // Save for print
    BL push                       // Try to push
    CMP X0, #0                    // Check result
    B.EQ push9_fail                // If failed, handle it
    LDR X0, =pushMsg              // Load success format
    FMOV D0, D1
    BL printf                     // Print success
    B after_push9
push9_fail:                       // Label: push 9.0 failed
    LDR X0, =pushFailMsg          // Load failure format
    FMOV D0, D1
    BL printf                     // Print failure
after_push9:                      // End of push 9.0

    // --- Delete stack ---
    BL delete                     // Call delete to reset stack
    LDR X0, =deleteMsg            // Load reset message
    BL printf                     // Print reset message

    // --- Pop after delete (expect underflow) ---
    BL pop                        // Try to pop
    FMOV D1, D0                   // Save result
    MOV X2, #0                    // move in 0 into X2
    SCVTF D2, X2                    // signed integer to double FP
    FCMP D1, D2                   // Compare values
    B.EQ deleted_underflow        // If equal, stack was empty
    LDR X0, =popMsg               // Print value (unexpected)
    FMOV D0, D1
    BL printf
    B after_pop_deleted
deleted_underflow:                // Label: underflow after delete
    LDR X0, =underflowMsg         // Load underflow message
    BL printf                     // Print it
after_pop_deleted:                // End of underflow-after-delete test

    // --- Destructor ---
    BL stackDestructor            // Free stack memory

    // terminate program
    MOV X0, #0           // load 0 (exit okay)
    MOV X8, #SYS_exit    // syscall to exit 
    SVC 0                // Linux call

    .data

pushMsg:      .asciz "Pushed: %f\n"                  // Message for successful push
pushFailMsg:  .asciz "Push failed (overflow) on value: %f\n" // Message for overflow
popMsg:       .asciz "Popped: %f\n"                  // Message for successful pop
underflowMsg: .asciz "Pop failed (underflow)\n"      // Message for underflow
deleteMsg:    .asciz "Stack deleted (reset)\n"       // Message for delete
newline:      .asciz "\n"

.end
