@ vi: ft=armv5
.syntax unified
.cpu cortex-m0plus
.thumb
.thumb_func
.global main

.MACRO printNum
    MOV R4, R0
    LDR R0, =strNum
    BL printf
    MOV R0, R4
.ENDM

@ R4 is race time (R)
@ R5 is race distance (D)
@ R7 is product of results
@ R8 points to time row
@ R9 points to distance row

main:
    @ B notPart2

    @ For part2
    @ R4 is race time (R)
    @ R7..R6 is distance (D) - 64-bit
    @ can ignore product, as only 1 result

    BL stdio_init_all
    LDR R0, =sepstr
    BL printf

    LDR R2, =input_dist2
    LDR R6, [R2]
    ADDS R2, #4
    LDR R7, [R2]
    LDR R2, =input_time2
    LDR R4, [R2]

    B solving

notPart2:
    LDR R0, =input
    BL skipWord
    ADDS R0, #1  @ skip :
    MOV R8, R0
    BL skipLine
    BL skipWord
    ADDS R0, #1  @ skip :
    MOV R9, R0
    MOVS R7, #1

nextRace:
    B racesDone @ for part 2

    MOV R0, R8
    BL skipSpaces
    LDRB R1, [R0]
    CMP R1, #'\n'
    BEQ racesDone
    BL readNumber
    MOV R4, R1
    MOV R8, R0
    MOV R0, R9
    BL skipSpaces
    BL readNumber
    MOV R5, R1
    MOV R9, R0

    @ Solving quadratic B^2-BR+D=0
    @ B is the button time, R is the race time, D is the distance to beat
    @ Standard form, a=1, b=-R c=D
    @ Has <2 roots (and therefore can't win, could equal if 1 root) if b^2-4ac<=0, i.e. if b^2<=4ac
    @ This would give the overall trivial answer to the puzzle of 0, so assume never true, for now!
solving:
    MOVS R2, #0xff
    LSLS R2, #8
    MOVS R3, #0xff
    ORRS R2, R3
    MOV R0, R4      @ R
    MOV R1, R0
    ANDS R0, R2     @ LS 16 bits of R (L)
    LSLS R2, #16
    ANDS R1, R2
    LSRS R1, #16    @ MS 16 bits of R (M)
    MOV R2, R0      @ L
    MULS R2, R1     @ ML
    MULS R0, R0     @ L^2
    MULS R1, R1     @ M^2
    MOVS R3, #0

    @ Add ML twice, but shifted left 16
    MOV R3, R2
    LSRS R3, #16
    LSLS R2, #16

    ADDS R0, R2
    ADCS R1, R3
    ADDS R0, R2
    ADCS R1, R3     @ R1..R0 now contains R^2 (=b^2)

    @ Part 1 version
    @ MOV R2, R5      @ D
    @ LSLS R2, #2     @ 4D=4ac
    
    @ Part 2 version, start with D in R7..R6
    ADDS R6, R6
    ADCS R7, R7
    ADDS R6, R6
    ADCS R7, R7     @ R7..R6 now contains 4ac
    MOV R2, R6
    MOV R3, R7

    SUBS R0, R2
    SBCS R1, R3     @ R1..R0 now contains b^2-4ac

    MOVS R2, #0
    BL ufix642double    @ R1..R0 now contains a double of the same value
    BL sqrt            @ R1..R0 now contains a double of sqrt(b^2-4ac)
    MOVS R2, #4
    BL double2fix64     @ R1..R0 now contains a fixed point with 4 bits of fraction
                        @ (but R0 may be big enough, let's see)
    LSRS R0, #1     @ sqrt(b^2-4ac)/2a

    MOV R1, R4      @ b
    LSLS R1, #3      @ b/2 (24/4 fixed)
    MOV R2, R1
    SUBS R2, R0      @ solution 1 (24/4f)
    MOV R3, R1
    ADD R3, R0      @ solution 2 (24/4f)
    SUBS R3, #1      @ adjust for case where higher root is an exact int
    LSRS R2, #4      @ floor to uint
    LSRS R3, #4      @ floor to uint
    SUBS R3, R2      @ number of solutions
    MULS R7, R3
    MOV R1, R3
    printNum
    B nextRace



racesDone:
    LDR R0, =strProduct
    MOV R1, R7
    BL printf
end:
    b end

@ skipWord
@ Reads past a word (alphabetic chars only) in a string, returns pointer to following char
@ Input:    R0 - the address of the first character
@ Output:   R0 - the address of the following character
@ Clobbered regs:
@   R1 - current char val, not saved
skipWord:
    LDRB R1, [R0]
    CMP R1, #'A'
    BLT skipWordDone
    CMP R1, #'z'
    BGT skipWordDone
    CMP R1, #'Z'
    BLT skipWordNext
    CMP R1, #'a'
    BLT skipWordDone
skipWordNext:
    ADDS R0, #1
    B skipWord
skipWordDone:
    BX LR

@ skipSpaces
@ Reads past space characters
@ Input:    R0 - the address of the first character
@ Output:   R0 - the address of the following character
@ Clobbered regs:
@   R1 - current char val, not saved
skipSpaces:
    LDRB R1, [R0]
    CMP R1, #' '
    BNE skipSpacesDone
    ADDS R0, #1
    B skipSpaces
skipSpacesDone:
    BX LR

@ skipLine
@ Read beyond the next '\n'
@ Input:    R0 - the address of the first character
@ Output:   R0 - the address of the following character
@ Clobbered regs:
@   R3 - current char val, not saved
skipLine:
    LDRB R3, [R0]
    ADDS R0, #1
    CMP R3, #'\n'
    BEQ skipLineDone
    B skipLine
skipLineDone:
    BX LR

@ skipToEmptyLine
@ skips lines until an empty line is reached (first char is '\n' or '\0')
@ Always skips at least one line!
@ Input:    R0 - address of first char
@ Output:   R0 - address of following char
@ Clobbered regs:
@   R3 - not saved
skipToEmptyLine:
    PUSH {LR}
    BL skipLine
    LDRB R3, [R0]
    CMP R3, #'\n'
    BEQ skipToEmptyLineDone
    CMP R3, #0
    BEQ skipToEmptyLineDone
    B skipToEmptyLine
skipToEmptyLineDone:
    POP {PC}

@ readNumber
@ Reads a number from a string, returning the value
@ Returns 0 if a numeric is not pointed at
@ Input:    R0 - the address of the first character
@ Output:   R0 - the address of the following character
@           R1 - the numeric value
@ Used regs: (none clobbered)
@   R2 - current char val, not saved
@   R3 - number base (10), not saved
readNumber:
    MOVS R1, #0
    MOVS R3, #10
nextDigit:
    LDRB R2, [R0]
    CMP R2, #'0'
    BLT readNumberDone
    CMP R2, #'9'
    BGT readNumberDone
    SUBS R2, #'0'
    MULS R1, R3
    ADD R1, R2
    ADDS R0, #1
    B nextDigit
readNumberDone:
    BX LR

.align 4
.data
strNum: .asciz "Number: %u\n"
strProduct: .asciz "Product: %u\n"
sepstr: .asciz "-----------------------------------------\n"

@Note : always ensure these test "files" have a CR at the end!
input_test: .asciz "Time:      7  15   30
Distance:  9  40  200
"

input_test2: .asciz "Time:      71530
Distance:  940200
"

input:  .asciz "Time:        40     82     84     92
Distance:   233   1011   1110   1487
"

input_part2:  .asciz "Time:        40828492
Distance:   233101111101487
"
.align 4
@ Cheating a bit here, but can't be bothered writing a 64-bit version of readNumber for 1 entry!
input_time2:    .quad 40828492
input_dist2:    .quad 233101111101487
