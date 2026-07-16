;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mupid Sokoban Original current level
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_FILL_19_RET_C:
    ;;; Fill MAP and screen with C
    PUSH HL
    LD HL, 0x0704
    LD DE, 0x1811
    JR _FILL_HL_DE_RET_C
_FILL_20_RET_C:
    ;;; Fill MAP and screen with C
    PUSH HL
    LD HL, 0x0102
    LD DE, 0x1F14
_FILL_HL_DE_RET_C:
    LD B, L
_NEXT_FILL:
    PUSH DE
    PUSH HL
    PUSH BC
    LD C, STANDARD_WALL
    CALL SET_OBJECT_HL_C ; C,HL megmarad
    CALL APA
    LD C, STANDARD_WALL
    SET 7, C             ; Move char into DRCS area
    CALL CHSCREEN
    POP BC
    POP HL
    POP DE
    INC L
    LD A, L
    CP E
    JR NZ, _NEXT_FILL
    LD L, B               ; Restart L
    INC H
    LD A, H
    CP D
    JR NZ, _NEXT_FILL
    ;;; End fill
    LD C, EMPTY_BG
    POP HL
    RET

_INIT_CUR_LEVEL_HL:
    LD A, 0
    LD (_ITEM_COUNTER), A
    LD (ALL_PLACE_COUNTER), A
    LD (CURRENT_LEVEL_START_ADDR), HL
    LD HL, SOKOMAP
    LD DE, SOKOMAP+1
    LD (HL), EMPTY_BG
    LD BC, SIZE_X * SIZE_Y - 1
    LDIR
    LD HL, (CURRENT_LEVEL_START_ADDR)
    RET

INC_LEVEL_Z:               ; Z = 1 if restart
    LD HL, CURRENT_LEVEL_BCD
    CALL BCD_INC_HL
    CP 0x21
    RET NZ
    LD (HL), 0x01
    RET

; HL = L * SIZE_X + H + SOKOMAP
_set_pos_HL: 
    PUSH BC
    PUSH DE
    PUSH AF
    LD A, H
    PUSH AF
    LD B, L
    LD C, SIZE_X
    CALL MULT8_B_C_HL
    LD DE, SOKOMAP
    ADD HL, DE
    POP AF      ; A-ban a H eredeti értéker, azaz az X
    LD E, A
    LD D, 0
    ADD HL, DE
    POP AF
    POP DE
    POP BC
    RET

SET_OBJECT_HL_C:
    PUSH HL
    CALL _set_pos_HL
    LD (HL), C
    POP HL
    RET

GET_OBJECT_HL_A:
    PUSH HL
    CALL _set_pos_HL
    LD A, (HL)
    POP HL
    RET

; INPUT: THE VALUES IN REGISTER B EN C
; OUTPUT: HL = B * C
; CHANGES: AF,DE,HL,B
;
MULT8_B_C_HL:
    LD HL,0
    LD A,B
    OR C
    RET Z
    LD D,0
    LD E,C
MLOOP:	ADD HL,DE
    DJNZ MLOOP
    RET

SHOW_NEXT_LEVEL_HL:
    CALL _INIT_CUR_LEVEL_HL
    LD C, STANDARD_WALL
    LD A, (CURRENT_LEVEL_BCD)
    CP 0x19 ; BCD
    CALL Z, _FILL_19_RET_C   ; C = EMPTY_SPACE
    CP 0x20 ; BCD
    CALL Z, _FILL_20_RET_C   ; C = EMPTY_SPACE
    CALL SHOW_OBJECTS_HL2_C
    LD C, 'B'
    CALL SHOW_OBJECTS_HL2_C
    CALL SHOW_OBJECTS_HL3
    LD A, 0
    LD (_ITEM_COUNTER), A
    LD C, PLACEHOLDER
    CALL SHOW_OBJECTS_HL2_C
    LD A, (_ITEM_COUNTER)
    LD (ALL_PLACE_COUNTER), A
    LD C, 'R'
    CALL INIT_PLAYER_HL_C
    LD (NEXT_LEVEL_START_ADDR), HL
    CALL INIT_STATUS
    RET

SHOW_OBJECTS_HL2_C: ; HL címrő addig olvas (X,Y) koordinátákat, míg nem 0 vagy -1, és kitesz rájuk egy C karakter.
    LD A, (HL)
    INC HL
    LD B, (HL)
    INC HL
    CP -1
    RET Z
    CP 0
    RET Z
    PUSH HL
    PUSH BC         ; C=ObjChar
    LD HL, _ITEM_COUNTER
    INC (HL)
    LD H, A
    LD L, B
    CALL SET_OBJECT_HL_C
    CALL APA
    POP BC
    PUSH BC
    SET 7, C             ; Move char into DRCS area
    CALL CHSCREEN
    POP BC
    POP HL
    JR SHOW_OBJECTS_HL2_C

SHOW_OBJECTS_HL3: ; HL címrő addig olvas (X,Y) koordinátákat, míg nem 0 vagy -1, és kitesz rájuk egy C karakter.
    LD A, (HL)
    INC HL
    LD B, (HL)
    INC HL
    LD C, (HL)
    INC HL
    CP -1
    RET Z
;    PUSH AF
;    CALL CHANGE_C
;    POP AF
    PUSH HL
    PUSH BC         ; C=ObjChar
    LD H, A
    LD L, B
    CALL SET_OBJECT_HL_C
    CALL APA
    POP BC
    SET 7, C             ; Move char into DRCS area
    CALL CHSCREEN
    POP HL
    JR SHOW_OBJECTS_HL3

CHANGE_C:
    LD A, C
    LD C, 'u'
    CP 8 ; Up
    RET Z
    LD C, 'd'
    CP 2 ; Down
    RET Z
    LD C, 'l'
    CP 4 ; Left
    RET Z
    LD C, 'r'
    CP 6 ; Right
    RET Z
    LD C, A
    RET


_ITEM_COUNTER:	DB 0
ALL_PLACE_COUNTER:	DB 0
CURRENT_LEVEL_START_ADDR:	DW 0
NEXT_LEVEL_START_ADDR:	DW 0
CURRENT_LEVEL_BCD:	DB 0x01     ; Start value
