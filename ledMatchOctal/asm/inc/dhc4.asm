;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; A high4 grafika első 4 bájtjának legenerálása
;;; a 4 palettakódból z80 alapon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;DIRECT_TEST:
;    LD A, 2
;    CALL SEVSEG_SET_ON_COLOR_PALETTE_A
;    LD BC, PUZZLE_SIZE
;    CALL SEVSEG_SET_SIZE_BC
;    LD HL, PUZZLE_POS
;    LD A,0
;    CALL RECOLOR_7_SEGMENTS_HL_A
;
;    LD A, 4
;    CALL SEVSEG_SET_ON_COLOR_PALETTE_A
;    LD HL, PLAYER_POS
;    LD A,127
;    CALL RECOLOR_7_SEGMENTS_HL_A
;    RET
;    LD BC, 0001h ; Palette 0,1
;    LD DE, 0203h ; Palette 2,3
;    LD HL, PUZZLE_POS
;    CALL DIRECT_RESET_PALETTES_BC_DE_HL
;    LD BC, 0405h
;    LD DE, 0607h
;    LD HL, PLAYER_POS
;    CALL DIRECT_RESET_PALETTES_BC_DE_HL
;    RET

_STARTPOS: DW 0
_VALUE: DB 0

RECOLOR_7_SEGMENTS_HL_A: ; Az A kód kiszínezése HL pozíciótól
    LD (_STARTPOS), HL
    LD (_VALUE), A
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P11:
    CALL RECOLOR_P11_HL_A
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P12:
    EX AF, AF'
    LD A, (_XREPEAT)
    LD B, A
    EX AF, AF'
P12_LOOP:
        INC H
        LD A, (_VALUE)
        CALL RECOLOR_P12_HL_A
    DJNZ P12_LOOP
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P13:
    INC H
    LD A, (_VALUE)
    CALL RECOLOR_P13_HL_A
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P23:
    EX AF, AF'
    LD A, (_YREPEAT)
    LD B, A
    EX AF, AF'
P23_LOOP:
        INC L
        LD A, (_VALUE)
        CALL RECOLOR_P23_HL_A
    DJNZ P23_LOOP
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P21:
    LD HL, (_STARTPOS)
    EX AF, AF'
    LD A, (_YREPEAT)
    LD B, A
    EX AF, AF'
P21_LOOP:
        INC L
        LD A, (_VALUE)
        CALL RECOLOR_P21_HL_A
    DJNZ P21_LOOP
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P31:
    INC L
    LD A, (_VALUE)
    CALL RECOLOR_P31_HL_A
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P41:
    EX AF, AF'
    LD A, (_YREPEAT)
    LD B, A
    EX AF, AF'
P41_LOOP:
        INC L
        LD A, (_VALUE)
        CALL RECOLOR_P41_HL_A
    DJNZ P41_LOOP
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P51:
    INC L
    LD A, (_VALUE)
    CALL RECOLOR_P51_HL_A
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P52:
    EX AF, AF'
    LD A, (_XREPEAT)
    LD B, A
    EX AF, AF'
P52_LOOP:
        INC H
        LD A, (_VALUE)
        CALL RECOLOR_P52_HL_A
    DJNZ P52_LOOP
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P53:
    INC H
    LD A, (_VALUE)
    CALL RECOLOR_P53_HL_A
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P43:
    EX AF, AF'
    LD A, (_YREPEAT)
    LD B, A
    EX AF, AF'
P43_LOOP:
        DEC L
        LD A, (_VALUE)
        CALL RECOLOR_P43_HL_A
    DJNZ P43_LOOP
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P33:
    DEC L
    LD A, (_VALUE)
    CALL RECOLOR_P33_HL_A
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P32:
    EX AF, AF'
    LD A, (_XREPEAT)
    LD B, A
    EX AF, AF'
P32_LOOP:
        DEC H
        LD A, (_VALUE)
        CALL RECOLOR_P32_HL_A
    DJNZ P32_LOOP

    RET

;0016 0100 0012               P11  P12  P13
;0600 0000 0200               P21       P23
;0675 0700 0273               P31  P32  P33
;0500 0000 0300               P41       P43
;0540 0400 0340               P51  P52  P53

RECOLOR_P11_HL_A: ; 0016 -> BC=00, DE=16
    CALL SET_TMP_A_1
    EX AF, AF'
    LD D, A
    EX AF, AF'
    CALL SET_TMP_A_6
    EX AF, AF'
    LD E, A
    EX AF, AF'
    LD BC, 0
    CALL DIRECT_RESET_PALETTES_BC_DE_HL
    RET

RECOLOR_P12_HL_A: ; 0100 -> BC=01, DE=00
    PUSH BC
    LD B, 0
    CALL SET_TMP_A_1
    EX AF, AF'
    LD C, A
    EX AF, AF'
    LD DE, 0
    CALL DIRECT_RESET_PALETTES_BC_DE_HL
    POP BC
    RET

RECOLOR_P13_HL_A: ; 0012 -> BC=00, DE=12
    CALL SET_TMP_A_1
    EX AF, AF'
    LD D, A
    EX AF, AF'
    CALL SET_TMP_A_2
    EX AF, AF'
    LD E, A
    EX AF, AF'
    LD BC, 0
    CALL DIRECT_RESET_PALETTES_BC_DE_HL
    RET

RECOLOR_P21_HL_A: ; 0600 -> BC=06, DE=00
    PUSH BC
    LD B, 0
    CALL SET_TMP_A_6
    EX AF, AF'
    LD C, A
    EX AF, AF'
    LD DE, 0
    CALL DIRECT_RESET_PALETTES_BC_DE_HL
    POP BC
    RET

RECOLOR_P23_HL_A: ; 0200 -> BC=02, DE=00
    PUSH BC
    LD B, 0
    CALL SET_TMP_A_2
    EX AF, AF'
    LD C, A
    EX AF, AF'
    LD DE, 0
    CALL DIRECT_RESET_PALETTES_BC_DE_HL
    POP BC
    RET

RECOLOR_P31_HL_A: ; 0675 -> BC=06, DE=75
    PUSH BC
    LD B, 0
    CALL SET_TMP_A_6
    EX AF, AF'
    LD C, A
    EX AF, AF'
    CALL SET_TMP_A_7
    EX AF, AF'
    LD D, A
    EX AF, AF'
    CALL SET_TMP_A_5
    EX AF, AF'
    LD E, A
    EX AF, AF'
    CALL DIRECT_RESET_PALETTES_BC_DE_HL
    POP BC
    RET

RECOLOR_P32_HL_A: ; 0700 -> BC=07, DE=00
    PUSH BC
    LD B, 0
    CALL SET_TMP_A_7
    EX AF, AF'
    LD C, A
    EX AF, AF'
    LD DE, 0
    CALL DIRECT_RESET_PALETTES_BC_DE_HL
    POP BC
    RET

RECOLOR_P33_HL_A: ; 0273 -> BC=02, DE=73
    PUSH BC
    LD B, 0
    CALL SET_TMP_A_2
    EX AF, AF'
    LD C, A
    EX AF, AF'
    CALL SET_TMP_A_7
    EX AF, AF'
    LD D, A
    EX AF, AF'
    CALL SET_TMP_A_3
    EX AF, AF'
    LD E, A
    EX AF, AF'
    CALL DIRECT_RESET_PALETTES_BC_DE_HL
    POP BC
    RET

RECOLOR_P41_HL_A: ; 0500 -> BC=05, DE=00
    PUSH BC
    LD B, 0
    CALL SET_TMP_A_5
    EX AF, AF'
    LD C, A
    EX AF, AF'
    LD DE, 0
    CALL DIRECT_RESET_PALETTES_BC_DE_HL
    POP BC
    RET

RECOLOR_P43_HL_A: ; 0300 -> BC=03, DE=00
    PUSH BC
    LD B, 0
    CALL SET_TMP_A_3
    EX AF, AF'
    LD C, A
    EX AF, AF'
    LD DE, 0
    CALL DIRECT_RESET_PALETTES_BC_DE_HL
    POP BC
    RET

RECOLOR_P51_HL_A: ; 0540 -> BC=05, DE=40
    PUSH BC
    LD B, 0
    CALL SET_TMP_A_5
    EX AF, AF'
    LD C, A
    EX AF, AF'
    CALL SET_TMP_A_4
    EX AF, AF'
    LD D, A
    EX AF, AF'
    LD E, 0
    CALL DIRECT_RESET_PALETTES_BC_DE_HL
    POP BC
    RET

RECOLOR_P52_HL_A: ; 0400 -> BC=04, DE=00
    PUSH BC
    LD B, 0
    CALL SET_TMP_A_4
    EX AF, AF'
    LD C, A
    EX AF, AF'
    LD DE, 0
    CALL DIRECT_RESET_PALETTES_BC_DE_HL
    POP BC
    RET

RECOLOR_P53_HL_A: ; 0340 -> BC=03, DE=40
    LD B, 0
    CALL SET_TMP_A_3
    EX AF, AF'
    LD C, A
    EX AF, AF'
    CALL SET_TMP_A_4
    EX AF, AF'
    LD D, A
    EX AF, AF'
    LD E, 0
    CALL DIRECT_RESET_PALETTES_BC_DE_HL
    RET

SET_TMP_A_1:
    BIT 0, A
    JR SET_TMP_Z
SET_TMP_A_2:
    BIT 1, A
    JR SET_TMP_Z
SET_TMP_A_3:
    BIT 2, A
    JR SET_TMP_Z
SET_TMP_A_4:
    BIT 3, A
    JR SET_TMP_Z
SET_TMP_A_5:
    BIT 4, A
    JR SET_TMP_Z
SET_TMP_A_6:
    BIT 5, A
    JR SET_TMP_Z
SET_TMP_A_7:
    BIT 6, A
    JR SET_TMP_Z
SET_TMP_Z
    EX AF, AF'
    LD A, (SEVSEG_OFF_PALETTE)
    EX AF, AF'
    RET Z
    EX AF, AF'
    LD A, (SEVSEG_ON_PALETTE)
    EX AF, AF'
    RET
