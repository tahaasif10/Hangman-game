

DOSSEG
.MODEL SMALL
.STACK 100H

.DATA
; ---------------- Constants & Messages ------------------
WORD_LENGTH EQU 8
MAX_GUESSES  EQU 6

ARRAY DB 'SAAD   $', 'AHMED  $', 'SAUD   $', 'DAWOOD $', 'TAHA   $', 'WANIA  $', 'FAIZA  $', 'MARYAM $', 'MISS   $', 'UBIT$'

msg          DB "GUESS THE WORD: ", 0Dh, 0Ah, "$"
CORRECT      DB "YOU GUESSED IT :)", 0Dh, 0Ah, "$"
INCORRECT    DB "OOPS! WRONG GUESS :(", 0Dh, 0Ah, "$"
ALREADY_GUESSED DB "YOU ALREADY GUESSED THIS LETTER.", 0Dh, 0Ah, "$"
WIN_MESSAGE  DB 0Dh, 0Ah, "WOOWWW ! YOU GUESSED THE FULL WORD! YOU WIN:)", 0Dh, 0Ah, "$"
LOSE_MESSAGE DB 0Dh, 0Ah, "OOPS GAME OVER! YOU LOST:(", 0Dh, 0Ah, "$"
GUESSES_LEFT DB "GUESSES LEFT: $"
NEWLINE      DB 0Dh, 0Ah, "$"

; ---------------- Variables ------------------
DISPLAY_DASH DB WORD_LENGTH DUP('-'), '$'
SELECTED_WORD DB WORD_LENGTH DUP(0)

WORD_OFFSET DW 0
REMAINING_GUESSES DB MAX_GUESSES
MATCH_FLAG DB 0
GAME_OVER_FLAG DB 0

.CODE

; ---------------- VGA Pixel Routine ------------------
PUT_PIXEL PROC
    PUSH AX
    PUSH DI
    PUSH ES
    MOV AX, 0A000h
    MOV ES, AX
    MOV DI, CX
    MOV AX, 320
    MUL DX
    ADD DI, AX
    MOV ES:[DI], AL
    POP ES
    POP DI
    POP AX
    RET
PUT_PIXEL ENDP

; ---------------- VGA Line Helper -----------------
DRAW_LINE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV SI, 0
DRAW_LOOP:
    MOV AX, CX
    ADD AX, SI
    MOV CX, AX
    CALL PUT_PIXEL
    MOV CX, AX
    INC SI
    CMP SI, BX
    JB DRAW_LOOP
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DRAW_LINE ENDP

; ---------------- Hangman Graphics Drawer ------------------
DRAW_HANGMAN PROC
    MOV CX, 50
    MOV DX, 20
    MOV AL, 15
    MOV BX, 60
    CALL DRAW_LINE

    MOV CX, 50
    MOV DX, 20
    MOV BX, 60
    MOV SI, 0
VERT_LOOP:
    CALL PUT_PIXEL
    INC DX
    INC SI
    CMP SI, 60
    JB VERT_LOOP

    CMP REMAINING_GUESSES, 5
    JB STAGE_HEAD
    RET

STAGE_HEAD:
    MOV CX, 110
    MOV DX, 40
    MOV AL, 12
    CALL PUT_PIXEL
    CMP REMAINING_GUESSES, 4
    JB STAGE_BODY
    RET

STAGE_BODY:
    MOV CX, 110
    MOV DX, 41
    MOV BX, 20
    MOV AL, 12
    MOV SI, 0
BODY_LOOP:
    CALL PUT_PIXEL
    INC DX
    INC SI
    CMP SI, BX
    JB BODY_LOOP
    CMP REMAINING_GUESSES, 3
    JB STAGE_LARM
    RET

STAGE_LARM:
    MOV CX, 108
    MOV DX, 45
    MOV AL, 12
    CALL PUT_PIXEL
    CMP REMAINING_GUESSES, 2
    JB STAGE_RARM
    RET

STAGE_RARM:
    MOV CX, 112
    MOV DX, 45
    MOV AL, 12
    CALL PUT_PIXEL
    CMP REMAINING_GUESSES, 1
    JB STAGE_LLEG
    RET

STAGE_LLEG:
    MOV CX, 108
    MOV DX, 61
    MOV AL, 12
    CALL PUT_PIXEL
    CMP REMAINING_GUESSES, 0
    JB STAGE_RLEG
    RET

STAGE_RLEG:
    MOV CX, 112
    MOV DX, 61
    MOV AL, 12
    CALL PUT_PIXEL
    RET
DRAW_HANGMAN ENDP

; ---------------- Entry Point ----------------
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV AX, 13h
    INT 10h
    CALL INITIALIZE_GAME
    CALL GAME_LOOP
    CALL END_PROGRAM
MAIN ENDP

; ---------------- Game Initialization ----------------
INITIALIZE_GAME PROC
    MOV AH, 2Ch
    INT 21h
    MOV AL, DL
    XOR AH, AH
    MOV CL, 10
    DIV CL
    MOV BL, AH
    MOV AX, BX
    MOV CL, WORD_LENGTH
    MUL CL
    MOV WORD_OFFSET, AX
    MOV SI, AX
    MOV CX, WORD_LENGTH
    MOV DI, OFFSET SELECTED_WORD
COPY_WORD:
    MOV AL, [ARRAY+SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP COPY_WORD
    RET
INITIALIZE_GAME ENDP

; ---------------- Game Loop ----------------
GAME_LOOP PROC
GAME_START:
    CMP GAME_OVER_FLAG, 1
    JE GAME_EXIT
    CMP REMAINING_GUESSES, 0
    JE GAME_LOSE

    MOV AX, 03h
    INT 10h
    MOV AX, @DATA
    MOV DS, AX

    MOV DX, OFFSET DISPLAY_DASH
    MOV AH, 09h
    INT 21h
    MOV DX, OFFSET GUESSES_LEFT
    MOV AH, 09h
    INT 21h
    MOV DL, REMAINING_GUESSES
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    MOV DX, OFFSET NEWLINE
    MOV AH, 09h
    INT 21h

    MOV AH, 01h
    INT 21h
    MOV BL, AL
    MOV DX, OFFSET NEWLINE
    MOV AH, 09h
    INT 21h

    MOV MATCH_FLAG, 0
    CALL CHECK_LETTER
    CALL CHECK_WIN_CONDITION
    CMP AX, 1
    JE GAME_WIN

    MOV AX, 13h
    INT 10h
    CALL DRAW_HANGMAN
    JMP GAME_START

GAME_LOSE:
    MOV AX, 03h
    INT 10h
    MOV AX, @DATA
    MOV DS, AX
    MOV DX, OFFSET LOSE_MESSAGE
    MOV AH, 09h
    INT 21h
    MOV GAME_OVER_FLAG, 1
    JMP GAME_EXIT

GAME_WIN:
    MOV AX, 03h
    INT 10h
    MOV AX, @DATA
    MOV DS, AX
    MOV DX, OFFSET DISPLAY_DASH
    MOV AH, 09h
    INT 21h
    MOV DX, OFFSET WIN_MESSAGE
    MOV AH, 09h
    INT 21h
    MOV GAME_OVER_FLAG, 1

GAME_EXIT:
    RET
GAME_LOOP ENDP

; ---------------- Check Letter ----------------
CHECK_LETTER PROC
    MOV CX, WORD_LENGTH
    MOV DI, 0
CHECK_REPEAT_LOOP:
    MOV AL, [DISPLAY_DASH+DI]
    CMP AL, BL
    JE ALREADY_DISPLAYED
    INC DI
    LOOP CHECK_REPEAT_LOOP
    MOV CX, WORD_LENGTH
    MOV DI, 0
CHECK_LOOP:
    MOV AL, [SELECTED_WORD+DI]
    CMP BL, AL
    JNE NO_MATCH
    MOV MATCH_FLAG, 1
    MOV SI, OFFSET DISPLAY_DASH
    ADD SI, DI
    MOV [SI], BL
NO_MATCH:
    INC DI
    LOOP CHECK_LOOP
    CMP MATCH_FLAG, 1
    JE LETTER_MATCHED
    MOV DX, OFFSET INCORRECT
    MOV AH, 09h
    INT 21h
    DEC REMAINING_GUESSES
    JMP CHECK_LETTER_EXIT
LETTER_MATCHED:
    MOV DX, OFFSET CORRECT
    MOV AH, 09h
    INT 21h
    JMP CHECK_LETTER_EXIT
ALREADY_DISPLAYED:
    MOV DX, OFFSET ALREADY_GUESSED
    MOV AH, 09h
    INT 21h
CHECK_LETTER_EXIT:
    RET
CHECK_LETTER ENDP

; ---------------- Win Check ----------------
CHECK_WIN_CONDITION PROC
    MOV CX, WORD_LENGTH
    MOV DI, 0
    MOV AX, 1
WIN_CHECK_LOOP:
    MOV BL, [SELECTED_WORD+DI]
    CMP BL, ' '
    JE WIN_CHECK_NEXT
    CMP BL, '$'
    JE WIN_CHECK_NEXT
    MOV BL, [DISPLAY_DASH+DI]
    CMP BL, '-'
    JNE WIN_CHECK_NEXT
    MOV AX, 0
    JMP NEAR PTR WIN_CHECK_EXIT
WIN_CHECK_NEXT:
    INC DI
    LOOP WIN_CHECK_LOOP
WIN_CHECK_EXIT:
    RET
CHECK_WIN_CONDITION ENDP

; ---------------- Exit Program ----------------
END_PROGRAM PROC
    MOV AX, 03h
    INT 10h
    MOV AH, 4Ch
    INT 21h
    RET
END_PROGRAM ENDP

END MAIN
