;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MUPID Led Match Octal (Mk14 inspired)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ORG 0x8100

SCRPOS EQU 0106h;

START:
    LD C, 0xFE
    RST 0x20           ; Keyboard click sound off

    CALL DIRECT_KEY_INIT_AND_CLEAT_PUFFER

    LD HL, INIT_SCREEN
    LD DE, INIT_SCREEN_END-INIT_SCREEN
    CALL BTX_PRINT_HL_DE

    CALL PALETTE_REDEFINE
    LD A, SEGMENT_OFF_PALETTE
    CALL SEVSEG_SET_OFF_COLOR_PALETTE_A
    CALL INIT_7SEGMENTS
    LD HL, START_TEXT
    CALL SYSERR

;    CALL DIRECT_TEST

    CALL DIRECT_KEY_WAIT_A
    SET 5, A
    CP 'q'
    JP Z, END_GAME


    LD A, 73
START_GAME_A:
    CALL SHOW_PUZZLE_A

    CALL PALETTE_18_DEFAULT

    LD HL, INFO_TEXT
    LD DE, INFO_TEXT_END-INFO_TEXT
    CALL BTX_PRINT_HL_DE

    LD HL, PLAYER_NUMBERS
    LD (HL), 0
    LD DE, PLAYER_NUMBERS+1
    LD BC, 4
    LDIR

    LD HL, MESSAGE_CLEAR
    LD DE, MESSAGE_CLEAR_END-MESSAGE_CLEAR
    CALL BTX_PRINT_HL_DE

    LD HL, PLAY_TEXT
    CALL SYSERR
    CALL DISPLAY_NUMBERS
    CALL XOR_NUMBERS_TO_A
    CALL HIDE_HELP

    CALL CLOCK_START
IN_GAME:
    CALL CLOCK_CHECK
    CALL DIRECT_KEY_GET2_A_Z
    SET 5, A
    CP 'q'
    JR Z, END_GAME
    CP 'x'
    JR Z, GIVE_UP
    CP 'h'
    CALL Z, SHOW_HELP1
    CP '0'
    JR C, IN_GAME    ; A < '0'
    CP '8'
    JR NC, IN_GAME    ; A >= '8'
    CALL PRESS_NUMBER_A_Z
    JR NZ, IN_GAME   ; Z=1, még nincs megoldva
    CALL SUCCESS_Z
    JR NZ, END_GAME
NEXT_GAME:
    CALL CLOCK_START
    JP NEXT_PUZZLE
GIVE_UP:
    CALL GIVING_UP_Z
    JR NZ, END_GAME
    JR NEXT_GAME
END_GAME:
    CALL DIRECT_KEY_REMOVE
    LD HL, BYE_SCREEN
    LD DE, BYE_SCREEN_END-BYE_SCREEN
    CALL BTX_PRINT_HL_DE
    LD HL, BYE_TEXT
    CALL SYSERR

    LD C, 0xFD
    RST 0x20           ; Keyboard click sound on
RET

PUZZLE_DATA: DB 0
RANDOM_NUMBER: DB 0
PLAYER_NUMBERS: DB 0,0,0,0,0

NEXT_PUZZLE:
    LD A, (PUZZLE_DATA)
    INC A
    LD (PUZZLE_DATA), A
    JP START_GAME_A

PRESS_NUMBER_A_Z:    ; A in [ '0' .. '7' ]
    SUB '0'
    INC A
    CALL ADD_OR_REMOVE_NUMBER_A

    LD HL, PLAYER_NUMBERS   ; Sort numbers
    CALL Sort5Bytes_HL

    CALL DISPLAY_NUMBERS

    CALL XOR_NUMBERS_TO_A

    LD HL, PUZZLE_DATA
    CP (HL)
    RET

GIVING_UP_Z
    LD HL, MESSAGE_BORDER
    LD DE, MESSAGE_BORDER_END-MESSAGE_BORDER
    CALL BTX_PRINT_HL_DE
    LD HL, MESSAGE_GIVING_UP
    LD DE, MESSAGE_GIVING_UP_END-MESSAGE_GIVING_UP
    CALL BTX_PRINT_HL_DE
    JP SUCCESS_LOOP

SUCCESS_Z:
    LD HL, MESSAGE_BORDER
    LD DE, MESSAGE_BORDER_END-MESSAGE_BORDER
    CALL BTX_PRINT_HL_DE
    LD HL, MESSAGE_SUCCESS
    LD DE, MESSAGE_SUCCESS_END-MESSAGE_SUCCESS
    CALL BTX_PRINT_HL_DE
SUCCESS_LOOP:
    LD HL, RANDOM_NUMBER
    INC (HL)
    CALL PALETTE_18_CHNG
    CALL DIRECT_KEY_GET_A_Z
    ;CALL RST_0x30 ; Get key
    JR Z, SUCCESS_LOOP
    SET 5, A
    CP 'n'
    RET Z
    CP 'r'
    JP Z, RANDOMIZE_NEXT_LEVEL
    CP 'q'
    JR NZ, SUCCESS_LOOP
    OR 1
    RET

RANDOMIZE_NEXT_LEVEL:
    LD A, (RANDOM_NUMBER)
    AND 127
    LD (PUZZLE_DATA), A
    XOR A ; Set Z flag
    RET

XOR_NUMBERS_TO_A:
    LD A, 0
    LD HL, PLAYER_NUMBERS
    LD B, 5
    LD C, 0
XOR_LOOP:
        LD A, (HL)
        CP 0
        JR Z, A_IS_OK
            DEC A
            CALL SEVSEG_CONVERT_HEX_NUMBER_A_TO_SEGMENTS_A
A_IS_OK:
        XOR C
        LD C, A
        INC HL
    DJNZ XOR_LOOP
    LD A, C
    PUSH AF
    CALL SHOW_PLAYER_A
    POP AF
    RET

ADD_OR_REMOVE_NUMBER_A:
    LD HL, PLAYER_NUMBERS   ; Sort numbers
    LD B, 5
SEARCH_NUMBER:
        CP (HL)
        JR Z, DELETE_NUMBER_HL    ; Már lenyomtuk ezt a azámot, akkor töröljük
        INC HL
    DJNZ SEARCH_NUMBER
    ; Ha itt lépünk ki, akkor nem volt a számok özött, beszúrjuk az első helyre, arról tudjuk, hogy biztosan üres
    EX AF,AF'
    LD HL, PLAYER_NUMBERS
    LD A, (HL)
    CP 0
    RET NZ                     ; Ha az első sem üres, akkor nincs több hely, nem csinálunk semmit
    EX AF,AF'
    LD (HL), A
    RET
DELETE_NUMBER_HL:
    LD A, 0
    LD (HL), A
    RET

DISPLAY_NUMBERS:
    LD A, NUMBER_PALETTE
    CALL SEVSEG_SET_ON_COLOR_PALETTE_A
    LD BC, NUMBER_SIZE
    CALL SEVSEG_SET_SIZE_BC
    LD HL, FIRST_NUMBER_POS
    LD DE, PLAYER_NUMBERS
    LD B, NUMBER_COUNTER
DISPLAY_LOOP:
        PUSH BC
        LD A, (DISPLAY_NUMBERS_HIDE_COUNTER)
        CP B
        LD A, SEGMENT_OFF_PALETTE
        JR NC, NORMAL_NUMBER_OFF_COLOR ; C nagyobb, mint az aktuális pozíció, így nem kell elrejteni
        LD A, HIDDEN_SEGMENT_OFF_PALETTE ; rejtőszín
NORMAL_NUMBER_OFF_COLOR:
        LD (SEVSEG_OFF_PALETTE), A
        LD A, (DE)
        CP 0
        JR Z, A_CONTAINS_CHAR_FORMAT
            DEC A
            CALL SEVSEG_CONVERT_HEX_NUMBER_A_TO_SEGMENTS_A
A_CONTAINS_CHAR_FORMAT:
        INC DE
        PUSH DE
        PUSH HL
        CALL SEVSEG_RECOLOR_HL_A
        POP HL
        CALL SEVSEG_HL_NEXT_POS_HL
        POP DE
        POP BC
    DJNZ DISPLAY_LOOP
    RET

DISPLAY_NUMBERS_HIDE_COUNTER: DB NUMBER_COUNTER+1

INIT_7SEGMENTS:
    LD BC, PUZZLE_SIZE
    CALL SEVSEG_SET_SIZE_BC
    LD HL, PUZZLE_POS
    CALL SHOW_0_HL
    LD HL, PLAYER_POS
    CALL SHOW_0_HL

    LD BC, NUMBER_SIZE
    CALL SEVSEG_SET_SIZE_BC
    LD HL, FIRST_NUMBER_POS
    CALL SHOW_0_HL
    CALL SHOW_0_HL
    CALL SHOW_0_HL
    CALL SHOW_0_HL
    CALL SHOW_0_HL

    CALL CLOCK_INIT
    RET

SHOW_0_HL:
    PUSH BC
    PUSH HL
    CALL SEVSEG_INIT_HL
    POP HL
    LD A, 0
    PUSH HL
    CALL SEVSEG_RECOLOR_HL_A
    POP HL
    CALL SEVSEG_HL_NEXT_POS_HL
    POP BC
    RET

SHOW_PUZZLE_A:
    CALL SET_PUZZLE_INDEX_A ; A nem változik
    PUSH AF
    LD A, PUZZLE_PALETTE
    CALL SEVSEG_SET_ON_COLOR_PALETTE_A
    POP AF
    LD HL, PUZZLE_DATA
    LD (HL), A
    LD BC, PUZZLE_SIZE
    CALL SEVSEG_SET_SIZE_BC
    LD HL, PUZZLE_POS
    CALL SEVSEG_RECOLOR_HL_A
    RET

SET_PUZZLE_INDEX_A:
    PUSH AF
    PUSH HL
    LD HL, PUZZLE_INDEX ; 3 bytes
    CALL NumToAscii_HL_A
    POP HL
    POP AF
    RET

SHOW_PLAYER_A:
    PUSH AF
    LD A, PLAYER_PALETTE
    CALL SEVSEG_SET_ON_COLOR_PALETTE_A
    POP AF
    LD BC, PUZZLE_SIZE
    CALL SEVSEG_SET_SIZE_BC
    LD HL, PLAYER_POS
    CALL SEVSEG_RECOLOR_HL_A
    RET

SHOW_HL_A:
    CALL SEVSEG_CONVERT_HEX_NUMBER_A_TO_SEGMENTS_A
    PUSH AF
    PUSH HL
    CALL SEVSEG_INIT_HL
    POP HL
    POP AF
    PUSH HL
    CALL SEVSEG_RECOLOR_HL_A
    POP HL
    CALL SEVSEG_HL_NEXT_POS_HL
    RET

;INIT_KEYBOARD:
;    LD C, 0xFE
;    RST 0x20           ; Keyboard click sound off
;    LD A, 1
;    LD ( 0x6D60 ), A     ; Disable BTX write
;    ;CALL DIRECT_KEY_INIT
;    RET
;
;ENABLED_BTX:
;    LD C, 0xFF
;    RST 0x20           ; Keyboard click sound on?
;    LD A, 0
;    LD ( 0x6D60 ), A     ; Enabled BTX write
;    RET

include "lmo-config.asm"
include "lmo-texts.asm"
include "lmo-sort.asm"
include "lmo-clock.asm"
include "lmo-dhc4.asm"
include "lmo-palette.asm"
include "lib/ROM.asm"
include "lib/directKey.asm"
; include "lib/directKeyWithPuffer.asm"
; include "lib/directKey7220.asm"
include "lib/hex.asm"
include "inc/7segments.asm"
include "inc/levels.asm"
include "inc/helps.asm"
include "inc/num10.asm"
