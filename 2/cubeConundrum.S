@ vi: ft=armv5
.thumb_func
.global main

.MACRO printNum
    MOV R4, R0
    LDR R0, =strNum
    BL printf
    MOV R0, R4
.ENDM

main:
    BL stdio_init_all

    LDR R0, =sepstr
    BL printf

    LDR R0, =red_cubes
    LDR R1, [R0]
    MOV R8, R1
    LDR R0, =green_cubes
    LDR R1, [R0]
    MOV R9, R1
    LDR R0, =blue_cubes
    LDR R1, [R0]
    MOV R10, R1

    MOV R5, #0
    MOV R6, #0

    LDR R0, =input
nextGame:
    LDRB R1, [R0]
    CMP R1, #0
    BEQ gamesDone
    MOV R1, R8
    MOV R2, R9
    MOV R3, R10
    BL processLine
    ADD R5, R1
    ADD R6, R2
    MOV R1, R2
    @ printNum
    B nextGame
gamesDone:
    LDR R0, =strTotal
    MOV R1, R5
    BL printf
    LDR R0, =strPower
    MOV R1, R6
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
    ADD R0, #1
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
    ADD R0, #1
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
    ADD R0, #1
    CMP R3, #'\n'
    BEQ skipLineDone
    B skipLine
skipLineDone:
    BX LR

@ readNumber
@ Reads a number from a string, returning the value
@ Returns 0 if a numeric is not pointed at
@ Input:    R0 - the address of the first character
@ Output:   R0 - the address of the following character
@           R1 - the numeric value
@ Clobbered rgs:
@   R2 - current char val, not saved
@   R3 - number base (10), not saved
readNumber:
    MOV R1, #0
    MOV R3, #10
nextDigit:
    LDRB R2, [R0]
    CMP R2, #'0'
    BLT readNumberDone
    CMP R2, #'9'
    BGT readNumberDone
    SUB R2, #'0'
    MUL R1, R3
    ADD R1, R2
    ADD R0, #1
    B nextDigit
readNumberDone:
    BX LR


@ processLine
@ Process a line of text, containing one game result
@ Return 0 if the game would be impossible, the game number otherwise
@ Also returns the "power" which is the product of the min number of red, green
@ and blue cubes.
@ Input:    R0 - the address of the string
@           R1 - the number of reds allowed
@           R2 - the number of greens allowed
@           R3 - the number of blues allowed
@ Output:   R0 - the address of the next string
@           R1 - the game result (game number or 0)
@           R2 - the "power" of this game
@ Clobbered regs:
@   R1-R3 - not saved
@   R4 - red limit
@   R5 - green limit
@   R6 - blue limit
@   R7 - number of cubes in current draw
@   R8 - game number
@   R9 - min red cubes
@   R10- min green cubes
@   R11- min blue cubes
processLine:
    PUSH {R4, R5, R6, R7, LR}
    MOV R4, R8
    MOV R5, R9
    MOV R6, R10
    MOV R7, R11
    PUSH {R4, R5, R6, R7}

    MOV R4, R1
    MOV R5, R2
    MOV R6, R3

    MOV R1, #0  @ clear min cube counts
    MOV R9, R1
    MOV R10, R1
    MOV R11, R1

    BL skipWord @ Game
    BL skipSpaces
    BL readNumber
    MOV R8, R1  @ game number
    ADD R0, #1  @ skip :

    @ process a draw of the game
    @ currently we're not differentiating between ; for end draw
    @ and , for end particular cube set in a draw, but it doesn't
    @ seem to matter yet
nextDraw:
    BL skipSpaces
    BL readNumber   @ number of cubes in R1
    MOV R7, R1
    BL skipSpaces
    LDRB R2, [R0]   @ 'r', 'g' or 'b' in R2
    CMP R2, #'r'
    BNE notRed
    @ red
    CMP R7, R9
    BLT notNewMinRed
    MOV R9, R7
notNewMinRed:
    CMP R7, R4
    BGT tooMany
    B nextCubes
notRed:
    CMP R2, #'g'
    BNE notGreen
    @ green
    CMP R7, R10
    BLT notNewMinGreen
    MOV R10, R7
notNewMinGreen:
    CMP R7, R5
    BGT tooMany
    B nextCubes
notGreen:
    @ blue
    CMP R7, R11
    BLT notNewMinBlue
    MOV R11, R7
notNewMinBlue:
    CMP R7, R6
    BGT tooMany
nextCubes:
    BL skipWord
    LDRB R2, [R0]
    CMP R2, #'\n'
    BEQ endGame
    ADD R0, #1      @ skip , or ;
    B nextDraw

tooMany:
    @ too many, so clear the game number and continue
    MOV R1, #0
    MOV R8, R1
    B nextCubes

endGame:
    MOV R1, R8
return:
    MOV R2, #1
    MOV R3, R9
    MUL R2, R3
    MOV R3, R10
    MUL R2, R3
    MOV R3, R11
    MUL R2, R3
    BL skipLine     @ skip past next '\n'
    POP {R4, R5, R6, R7}
    MOV R8, R4
    MOV R9, R5
    MOV R10, R6
    MOV R11, R7
    POP {R4, R5, R6, R7, PC}

.align 4
.data
strNum: .asciz "Number: %u\n"
strTotal: .asciz "Total: %u\n"
strPower: .asciz "Power: %u\n"
sepstr: .asciz "-----------------------------------------\n"

.align 4
red_cubes:      .word 12
green_cubes:    .word 13
blue_cubes:     .word 14

@Note : always ensure these test "files" have a CR at the end!
input_test: .asciz "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
"

input:  .asciz "Game 1: 14 green, 8 blue, 9 red; 5 blue, 4 green, 2 red; 4 red, 4 blue, 4 green; 1 blue, 3 green, 2 red; 10 red, 3 blue, 15 green; 2 red, 6 green, 3 blue
Game 2: 1 red, 12 green, 2 blue; 2 green, 1 blue, 1 red; 4 green, 2 blue; 10 green, 3 blue; 4 green, 2 red, 2 blue
Game 3: 16 red, 3 green; 7 green, 15 red, 3 blue; 4 green, 20 red, 1 blue; 12 red, 13 green, 1 blue; 2 green, 8 red, 1 blue; 16 red, 7 green
Game 4: 3 red, 7 blue; 4 blue, 3 green; 19 blue, 1 red, 3 green; 16 blue, 4 red, 5 green; 1 red, 19 blue, 3 green
Game 5: 7 blue, 4 red, 6 green; 2 red, 3 green, 6 blue; 11 blue, 1 red, 5 green
Game 6: 7 red, 13 blue; 2 green, 9 red, 7 blue; 7 green, 3 red, 12 blue; 11 green, 3 blue, 4 red; 12 green, 10 blue
Game 7: 2 green, 5 red; 4 green, 1 blue, 3 red; 1 blue, 1 green, 18 red; 4 green, 12 red, 1 blue
Game 8: 12 red, 9 green, 11 blue; 13 blue, 1 red, 16 green; 12 blue, 12 green; 3 green, 7 blue, 2 red
Game 9: 1 green, 9 red, 9 blue; 4 blue, 2 red; 17 red, 6 green, 3 blue; 3 green, 1 blue, 12 red
Game 10: 2 blue, 11 red, 3 green; 4 blue, 11 red, 13 green; 4 blue, 15 green, 4 red; 1 blue, 3 green, 17 red
Game 11: 9 green, 3 blue, 2 red; 11 blue, 16 green, 5 red; 7 blue, 3 red, 5 green; 7 red, 8 green, 10 blue
Game 12: 13 green, 2 red, 2 blue; 1 red, 6 green; 5 green, 3 red, 8 blue
Game 13: 2 blue, 5 green; 2 blue, 2 green; 2 blue, 2 red, 4 green
Game 14: 4 red, 2 green, 1 blue; 7 red, 1 green; 6 red, 18 green, 4 blue; 3 green, 1 blue
Game 15: 2 blue, 5 green, 12 red; 13 red, 8 green; 10 blue, 6 red, 8 green; 9 blue, 7 red; 2 green, 15 red; 9 blue, 3 green, 14 red
Game 16: 8 green, 11 blue, 14 red; 4 red, 8 green; 5 red, 4 blue, 3 green; 4 green, 13 blue, 6 red; 9 red, 8 blue, 11 green
Game 17: 8 red, 6 green; 5 blue, 7 green; 10 red, 6 blue; 9 blue, 10 green, 7 red; 1 red, 3 green, 5 blue
Game 18: 8 blue, 10 red; 6 red, 5 blue, 6 green; 16 green, 6 blue, 1 red; 16 red, 3 green, 5 blue
Game 19: 2 green, 17 blue; 2 blue, 4 green, 7 red; 6 red, 12 blue; 6 blue, 5 red, 10 green
Game 20: 4 green, 8 red, 9 blue; 6 blue, 4 green; 5 blue, 7 green, 9 red; 9 red, 9 blue, 6 green
Game 21: 1 green, 11 red, 2 blue; 6 red, 7 blue; 5 red, 1 green; 2 red, 7 blue
Game 22: 8 blue, 1 red, 4 green; 6 blue, 4 green, 14 red; 5 green, 8 red, 9 blue
Game 23: 4 blue, 12 red, 1 green; 1 green, 10 blue; 11 red, 2 blue; 1 blue, 1 green
Game 24: 5 blue, 1 green; 2 green, 2 blue, 4 red; 3 red, 5 blue
Game 25: 13 blue, 5 green, 4 red; 5 red, 17 blue; 6 blue, 8 green, 1 red; 2 blue, 1 red, 8 green; 3 red, 3 green
Game 26: 2 green, 9 red, 2 blue; 3 green, 19 red; 2 green, 16 red, 6 blue; 11 green, 4 red, 4 blue; 2 blue, 8 red, 13 green; 7 blue
Game 27: 1 red, 17 green, 1 blue; 4 red, 8 green; 1 blue, 7 green, 7 red; 18 green, 2 red
Game 28: 6 blue, 1 red; 2 blue, 1 red; 1 red, 1 green, 5 blue; 1 green; 1 green, 3 blue; 1 blue, 1 green
Game 29: 15 blue, 8 red, 1 green; 6 red, 2 green, 17 blue; 13 blue, 12 red; 12 blue, 2 green, 12 red; 5 red, 14 blue
Game 30: 4 blue, 6 green, 4 red; 3 blue, 2 green, 9 red; 5 green, 18 red; 9 blue, 16 red, 5 green
Game 31: 6 blue, 7 green, 4 red; 8 green, 6 blue, 10 red; 6 red, 2 green, 2 blue; 2 green, 4 blue, 6 red; 2 red, 7 green; 7 red, 13 green, 2 blue
Game 32: 5 blue; 2 green, 8 blue; 1 red, 6 blue, 2 green; 2 green, 11 blue
Game 33: 1 red, 7 green, 17 blue; 1 red, 14 blue, 2 green; 13 blue
Game 34: 12 red, 1 green, 1 blue; 11 red, 1 blue, 1 green; 16 red, 3 green; 9 red, 1 blue; 15 red, 2 blue; 1 green, 4 blue, 8 red
Game 35: 6 blue, 13 red, 1 green; 8 red, 9 blue, 6 green; 12 red, 8 green
Game 36: 5 blue, 3 red; 2 green, 3 red; 9 green, 6 red, 1 blue; 3 blue, 4 red, 9 green
Game 37: 14 blue, 3 red; 2 green, 2 red, 8 blue; 11 blue, 5 red
Game 38: 3 red, 18 green, 2 blue; 5 green, 5 red; 1 red, 12 green, 6 blue; 3 red, 5 blue, 1 green; 4 blue, 6 red, 17 green; 17 green, 6 blue, 3 red
Game 39: 5 green, 13 blue, 1 red; 6 green, 1 red, 12 blue; 1 red, 2 green, 11 blue; 1 red, 2 green, 12 blue
Game 40: 15 red; 14 red, 2 green, 4 blue; 13 red, 5 blue; 5 blue, 1 green, 18 red
Game 41: 2 red, 15 green; 11 red, 6 green, 17 blue; 10 green, 15 red, 9 blue; 8 red, 4 blue; 1 green, 13 blue, 13 red
Game 42: 3 green, 3 blue, 1 red; 2 red, 8 blue, 1 green; 7 blue, 2 red, 1 green
Game 43: 8 green, 10 red, 4 blue; 3 red, 11 green, 10 blue; 4 red, 5 blue, 2 green; 9 green, 10 red, 4 blue
Game 44: 3 green, 4 blue, 4 red; 10 red, 5 green, 4 blue; 1 green, 16 red; 2 blue, 15 red, 6 green; 13 red, 2 blue, 4 green
Game 45: 5 blue, 3 red; 1 red, 3 blue, 17 green; 2 red, 3 blue
Game 46: 9 blue, 10 green, 5 red; 1 red, 5 blue, 1 green; 6 blue, 8 green, 9 red; 2 red, 4 blue, 11 green
Game 47: 3 green, 7 red, 7 blue; 12 red, 1 blue; 6 blue, 4 green, 6 red; 6 red, 5 blue, 1 green
Game 48: 5 green, 1 blue; 2 green, 8 red, 4 blue; 16 red, 12 blue, 8 green
Game 49: 19 green, 4 blue, 9 red; 3 green, 1 blue, 8 red; 7 red, 1 blue, 14 green; 2 blue, 7 green, 2 red
Game 50: 6 blue, 11 red; 1 green, 8 blue, 11 red; 5 blue, 1 green; 4 blue, 12 red, 1 green; 1 green, 6 red, 8 blue; 7 blue, 5 red
Game 51: 5 red, 7 green; 8 green; 4 blue, 7 green, 2 red
Game 52: 3 blue, 12 red, 1 green; 13 red, 1 blue; 7 blue, 8 red; 7 blue, 9 red; 4 red, 5 green
Game 53: 2 blue; 1 green, 4 red, 12 blue; 1 green, 7 blue, 4 red; 8 blue, 1 green, 4 red
Game 54: 2 blue, 7 green; 1 red, 1 green, 2 blue; 5 red, 5 blue, 7 green; 5 red, 5 blue, 6 green; 7 green; 7 green, 2 blue, 5 red
Game 55: 2 green, 20 blue, 3 red; 2 red, 1 green, 1 blue; 2 green, 14 blue, 2 red; 2 red, 11 blue; 8 green, 4 blue, 2 red
Game 56: 5 red, 1 green, 10 blue; 2 red, 1 blue; 1 blue, 2 red; 1 green, 8 blue
Game 57: 1 green, 4 red, 5 blue; 20 blue, 4 red, 2 green; 17 blue, 1 green; 1 green, 10 blue, 1 red; 3 red, 17 blue
Game 58: 15 green, 2 blue; 15 green, 4 blue, 2 red; 14 blue, 5 red, 15 green; 15 green
Game 59: 1 blue; 5 green, 8 red, 1 blue; 15 red, 2 blue, 1 green
Game 60: 3 green, 4 blue, 16 red; 6 blue, 10 green, 10 red; 2 blue, 13 red, 8 green
Game 61: 2 green, 2 blue, 3 red; 7 blue, 15 red, 9 green; 5 green, 1 blue, 8 red; 4 blue, 6 green, 18 red
Game 62: 5 red, 7 blue, 13 green; 7 green, 6 blue, 8 red; 6 blue, 8 red, 12 green; 2 blue, 6 red; 5 red, 4 blue, 5 green
Game 63: 3 red; 5 blue, 2 red; 10 red, 1 green, 4 blue; 5 blue, 4 red, 3 green
Game 64: 7 blue, 3 green; 5 red, 6 green, 14 blue; 1 green, 12 blue, 9 red; 1 blue, 8 red, 12 green
Game 65: 12 red, 12 blue; 5 green, 12 blue, 11 red; 6 green, 3 red, 14 blue; 11 green, 4 red, 1 blue; 11 red, 3 green, 2 blue; 13 blue, 9 red, 5 green
Game 66: 1 red, 1 green; 3 blue, 6 red, 3 green; 6 blue, 1 green, 4 red; 8 green, 1 red
Game 67: 2 green, 8 blue; 5 red, 7 blue, 4 green; 8 red, 5 green, 5 blue; 2 red, 1 blue
Game 68: 3 green, 14 blue, 3 red; 16 blue, 7 green, 4 red; 10 blue, 6 red; 4 green, 3 blue, 5 red; 2 red, 14 blue, 8 green
Game 69: 11 red, 1 green; 1 green, 4 blue, 13 red; 18 red, 3 blue; 7 red, 1 green, 9 blue; 5 blue, 1 red, 1 green; 3 red, 4 blue
Game 70: 10 blue, 2 green, 4 red; 4 green, 4 red, 2 blue; 7 green, 5 red, 1 blue; 7 green, 3 red, 10 blue; 7 green, 2 blue, 5 red; 1 blue, 9 red, 2 green
Game 71: 1 green, 6 blue; 10 blue, 2 red, 1 green; 8 blue, 1 red; 11 blue, 2 green, 3 red; 1 green, 10 blue
Game 72: 10 blue, 3 red, 2 green; 11 red, 4 green, 3 blue; 1 blue, 4 red, 3 green
Game 73: 8 red, 17 green, 3 blue; 5 blue, 10 red, 8 green; 9 green, 12 red, 3 blue
Game 74: 5 green, 4 blue, 1 red; 4 red, 6 blue; 2 red; 2 blue, 1 red; 3 blue, 1 green, 3 red
Game 75: 4 blue; 3 red, 10 blue, 14 green; 8 blue, 3 red, 11 green
Game 76: 10 blue, 15 green, 5 red; 14 green; 6 blue, 10 red, 13 green; 2 green, 10 red, 6 blue; 1 red, 6 blue
Game 77: 3 green, 5 red, 8 blue; 14 red, 15 green; 14 green, 1 blue, 2 red
Game 78: 5 blue, 5 green; 9 blue, 2 green, 5 red; 4 red, 4 blue, 1 green; 3 red, 10 green, 2 blue; 4 red, 12 blue, 3 green; 4 green, 5 red, 13 blue
Game 79: 6 red, 1 green, 18 blue; 5 red, 11 blue, 2 green; 2 green, 4 red, 4 blue; 7 red, 17 blue; 9 red, 1 green, 3 blue
Game 80: 5 blue, 6 green, 6 red; 2 blue, 8 green, 8 red; 5 green, 16 blue, 3 red; 2 green, 3 red, 1 blue
Game 81: 11 green, 5 blue; 1 blue, 10 green, 1 red; 3 red, 3 blue, 15 green
Game 82: 14 red, 11 green; 2 green, 11 blue; 9 blue, 7 green, 7 red; 13 blue, 17 red, 3 green; 12 green, 15 blue, 8 red
Game 83: 2 green, 9 red, 4 blue; 3 green, 4 blue, 5 red; 2 green, 9 red, 7 blue; 4 blue, 3 green
Game 84: 4 red, 3 green, 6 blue; 2 blue, 5 red, 2 green; 6 blue, 1 red, 10 green; 1 green, 1 blue, 3 red; 16 blue, 6 red, 2 green
Game 85: 14 red, 4 green, 6 blue; 11 red, 2 green, 6 blue; 9 red; 3 blue, 13 red, 8 green; 3 green, 2 blue, 8 red
Game 86: 4 red, 1 green; 14 blue, 3 red, 2 green; 5 red, 3 green, 5 blue; 13 blue, 11 green, 1 red; 1 green, 14 blue, 3 red
Game 87: 1 blue, 2 green, 4 red; 11 blue, 3 green, 4 red; 11 blue; 4 green, 11 blue, 3 red; 4 blue, 5 green, 2 red
Game 88: 1 red, 1 blue, 1 green; 3 green, 1 blue, 1 red; 9 blue, 5 red, 5 green; 3 blue, 5 red, 8 green; 2 blue, 3 red, 13 green; 8 blue, 3 red, 9 green
Game 89: 3 green, 12 red, 11 blue; 10 red, 7 green, 14 blue; 17 green, 9 blue; 15 green, 1 red, 3 blue
Game 90: 12 green, 7 red, 5 blue; 12 green, 1 blue, 6 red; 6 red, 3 green
Game 91: 11 red, 10 green, 15 blue; 5 red, 6 green, 2 blue; 3 blue, 9 red, 7 green; 11 red, 1 green, 15 blue; 10 blue, 4 green; 9 red, 7 green, 14 blue
Game 92: 1 green, 6 red, 4 blue; 5 blue, 1 green; 6 red, 6 blue
Game 93: 19 red, 8 green, 9 blue; 7 blue, 1 red, 9 green; 2 red, 9 blue, 11 green; 1 blue, 4 green, 10 red; 10 blue, 11 red; 4 green, 8 blue, 16 red
Game 94: 11 red, 1 green, 1 blue; 4 green, 8 red; 2 red, 1 green; 4 green, 5 red; 5 red, 1 blue; 1 blue, 2 green, 9 red
Game 95: 6 green, 7 blue, 8 red; 1 red, 7 green; 16 green, 2 blue, 3 red; 5 green, 10 blue, 8 red; 5 red, 16 green, 3 blue; 4 red, 10 blue, 12 green
Game 96: 6 blue, 5 green, 6 red; 3 red, 5 blue, 4 green; 2 blue, 2 red, 3 green
Game 97: 3 red, 8 green; 2 blue, 3 green; 13 red, 10 green, 3 blue
Game 98: 4 green, 9 red, 2 blue; 1 blue, 5 green, 18 red; 3 green, 16 red; 15 red, 1 green, 2 blue
Game 99: 7 green, 2 red, 5 blue; 9 red, 17 green, 19 blue; 8 red, 12 blue, 1 green; 11 red, 11 green, 10 blue; 19 green, 4 blue, 2 red
Game 100: 4 blue, 3 green; 5 blue, 12 green; 16 green, 1 red, 1 blue; 2 blue, 1 green; 1 red, 3 blue, 18 green; 3 green, 1 red, 3 blue
"
