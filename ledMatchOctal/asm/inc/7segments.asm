;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MUPID 7Segment graphics with 12x10 pixels 4 colors high resolution characters
;;; Sevent Segments display module
;;; - SEVSEG_SET_SIZE_BC : Set sevseg display size B=horizontal, C=vertical
;;; - SEVSEG_INIT_HL : Initialize a sevent segments display at position HL (H=horizontal, L=vertical).
;;; - SEVSEG_RECOLOR_HL_A : Switch leds on or off for value A at position HL (H=horizontal, L=vertical). Only after SEVSEG_INIT_HL!
;;; - SEVSEG_HL_NEXT_POS_HL : Change HL to the right side display position
;;; - SEVSEG_CONVERT_HEX_NUMBER_A_TO_SEGMENTS_A : Convert hexadecimal number to a display value from A to A. For example A='0' -> A=3Fh (%00111111)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; MK14 7 segmens definitions

; HREPEAT EQU 5
_YREPEAT: DB 3
_XREPEAT: DB 5
SEVSEG_BG_PALETTE:  DB 0
SEVSEG_OFF_PALETTE: DB 1
SEVSEG_ON_PALETTE:  DB 2

SEVSEG_SET_ON_COLOR_PALETTE_A:
    LD (SEVSEG_ON_PALETTE), A
    RET

SEVSEG_SET_OFF_COLOR_PALETTE_A:
    LD (SEVSEG_OFF_PALETTE), A
    RET

; ****************************************************************************
;                               Segment Data
; ****************************************************************************
SA      EQU    1                       ; Segment bit patterns
SB      EQU    2
SC      EQU    4
SD      EQU    8
SE      EQU    16
SF      EQU    32
SG      EQU    64
; ****************************************************************************
;                    Hex number to seven segment table
; ****************************************************************************
CRom: ; Characterset
Num0    EQU    SA+SB+SC+SD+SE+SF
Num1    EQU    SB+SC
Num2    EQU    SA+SB+SD+SE+SG
Num3    EQU    SA+SB+SC+SD+SG
Num4    EQU    SB+SC+SF+SG
Num5    EQU    SA+SC+SD+SF+SG
Num6    EQU    SA+SC+SD+SE+SF+SG
Num7    EQU    SA+SB+SC
Num8    EQU    SA+SB+SC+SD+SE+SF+SG
Num9    EQU    SA+SB+SC+SF+SG
NumA    EQU    SA+SB+SC+SE+SF+SG
NumB    EQU    SC+SD+SE+SF+SG
NumC    EQU    SA+SD+SE+SF
NumD    EQU    SB+SC+SD+SE+SG
NumE    EQU    SA+SD+SE+SF+SG
NumF    EQU    SA+SE+SF+SG

SEVSEG_NUMBERS_CHARSET:    DB Num0,Num1,Num2,Num3,Num4,Num5,Num6,Num7,Num8,Num9,NumA,NumB,NumC,NumD,NumE,NumF

SEVSEG_CONVERT_HEX_NUMBER_A_TO_SEGMENTS_A:
    AND 15
    PUSH HL
    PUSH DE
    LD HL, SEVSEG_NUMBERS_CHARSET
    LD E, A
    LD D, 0
    ADD HL, DE
    LD A, (HL)
    POP DE
    POP HL
    RET

SEVSEG_SET_SIZE_BC:
    LD (_YREPEAT), BC ; (_XREPEAT)<-B, (_YREPEAT)<-C
    RET

SEVSEG_HL_NEXT_POS_HL:
    LD A, (_XREPEAT)
    ADD A, 3
    ADD A, H
    LD H, A
    RET

SEVSEG_RECOLOR_HL_A:
    JP RECOLOR_7_SEGMENTS_HL_A
tmp1: DW 0
tmp2: DW 0

SEVSEG_INIT_HL:
    CALL SHOW7SEGMENTS_ROW3_HL
    INC L
    LD A, (_YREPEAT)
    LD B, A
SWR1:
        PUSH BC
        LD (tmp1), DE
        CALL SHOW7SEGMENTS_ROW2_HL
        LD (tmp2), DE
        LD DE, (tmp1)
        POP BC
        INC L
    DJNZ SWR1
    CALL SHOW7SEGMENTS_ROW3_HL
    INC L
    LD A, (_YREPEAT)
    LD B, A
SWR2:
        PUSH BC
        LD (tmp1), DE
        CALL SHOW7SEGMENTS_ROW2_HL
        LD (tmp2), DE
        LD DE, (tmp1)
        POP BC
        INC L
    DJNZ SWR2
;    CALL SHOW7SEGMENTS_ROW2_HL
;    INC L
    CALL SHOW7SEGMENTS_ROW3_HL
    RET

SHOW7SEGMENTS_ROW3_HL:
    PUSH HL
    PUSH HL
    LD DE, CORNER3LEFT
    CALL DIRECTSHOW_DE_HL ; Egy karakter kiírása DE címről HL karakterkoordinátára (44 bájtot)

    LD A, (_XREPEAT)
    LD B, A
SHOW_ROW3_LOOP:
        POP HL
        INC H
        PUSH HL
        PUSH BC
        LD DE, BLOCK
        CALL DIRECTSHOW_DE_HL ; Egy karakter kiírása DE címről HL karakterkoordinátára (44 bájtot)
        POP BC
    DJNZ SHOW_ROW3_LOOP

    POP HL
    INC H
    PUSH HL
    LD DE, CORNER3RIGHT
    CALL DIRECTSHOW_DE_HL ; Egy karakter kiírása DE címről HL karakterkoordinátára (44 bájtot)

    POP HL
    POP HL
    RET

SHOW7SEGMENTS_ROW2_HL:
    PUSH HL
    PUSH HL
    LD DE, BLOCK
    CALL DIRECTSHOW_DE_HL ; Egy karakter kiírása DE címről HL karakterkoordinátára (44 bájtot)

    LD A, (_XREPEAT)
    LD B, A
SHOW_ROW2_LOOP:
        POP HL
        INC H
        PUSH HL
        PUSH BC
        LD DE, BLOCK
        CALL DIRECTSHOW_DE_HL ; Egy karakter kiírása DE címről HL karakterkoordinátára (44 bájtot)
        POP BC
    DJNZ SHOW_ROW2_LOOP

    POP HL
    INC H
    PUSH HL
    LD DE, BLOCK
    CALL DIRECTSHOW_DE_HL ; Egy karakter kiírása DE címről HL karakterkoordinátára (44 bájtot)

    POP HL
    POP HL
    RET

;include "lib/ROM.asm"
include "lib/directHighChar4.asm"
include "inc/data.asm"
;include "inc/pals.asm"
