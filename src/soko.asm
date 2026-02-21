;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MUPID Sokoban teszt
;;; Irányítás:
;;;   - Left: 4 : 0x34
;;;   - Down: 5 : 0x35 / 2 : 0x32
;;;   - Right: 6 : 0x36
;;;   - Up: 8 : 0x38
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ORG 0x8100

START_X:
	LD SP, 0x7600	 ; 67E6
	CALL 0x0100	; Inint IO puffer
;	CALL 0x014e	; Inint sys
	CALL INIT_KEYBOARD ;
RESTART:
	CALL SHOW_START_SCREEN   ; HL-ben a kiválasztott level
	; LD HL, LEVELS
	CALL SHOW_NEXT_LEVEL_HL
WAIT_NEW_KEY:
	CALL SHOW_STATUS_Z
NL:                                   ; Next level for debug
	CALL Z, NEXT_LEVEL
IN_LEVEL:
	LD HL, 0
	LD (TM), HL
KEY_SLOWER:
	RST 0x30	; Wait for key pressed A:ASCII
	LD (KEYTMP), A
	LD HL, (TM)
	LD A, H
	OR L
	CP 1
	JR c, KEY_SLOWER
    LD A, (KEYTMP)
;	CP 'N'
;	JP Z, NL
;	CP 'n'
;	JP Z, NL
	CP 'X'
	JP Z, RESTART
	CP 'x'
	JP Z, RESTART
	CP 'U'
	JP Z, GO_UNDO
	CP 'u'
	JP Z, GO_UNDO
	CALL SAVE_FOR_UNDO
	CP '4'
	JP Z, GO_LEFT
	CP '5'
	JP Z, GO_DOWN
	CP '2'
	JP Z, GO_DOWN
	CP '6'
	JP Z, GO_RIGHT
	CP '8'
	JP Z, GO_UP
	CP 'R'
	JP Z, GO_RESTART
	CP 'r'
	JP Z, GO_RESTART
	CP 'Q'
	JP Z, 0
	JR WAIT_NEW_KEY

KEYTMP: DB 0

SAVE_FOR_UNDO:
    PUSH HL
    LD HL,(PLAYER_XY)
    LD (UNDO_PLAYER_XY), HL
    LD HL, 0
    LD (UNDO_LAST_BOX_NEW_POS), HL ; A
    POP HL
    RET

GO_UNDO:
    LD A, (UNDO_LAST_BOX_NEW_POS) ; Ez 0, akkor és csak akkor ha HL 0
    CP 0
    JP Z, WAIT_NEW_KEY    ; Do nothing if not move was last
    ;;; Ok, mehet az undo
    PUSH HL
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    LD HL, (UNDO_PLAYER_XY)   ; Játékos utolsó előtti poziciója
    LD (PLAYER_XY), HL
    CALL APA
    LD A, (UNDO_DIRECTION)   ; Játékos alakja utoljára
    LD C, A
    SET 7, C
    CALL CHSCREEN
    ;;;;;;;;;;;;;;;; Játékos UNDO ok ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; Most visszalépünkaz utoljára tolt dobozzal
    LD HL, (UNDO_LAST_BOX_NEW_POS)
    LD (BOX_UNDO_START_POS), HL
    LD DE, (UNDO_LAST_BOX_MOVE)
    CALL NEG_DE
    CALL GET_OBJECT_HL_A
    CALL MOVE_BOX
    PUSH HL
    CALL APA
    POP HL
    CALL GET_OBJECT_HL_A
    LD C, A
    SET 7, C
    CALL CHSCREEN
    POP HL
    JP WAIT_NEW_KEY

BOX_UNDO_START_POS:	DW 0

NEG_DE:
    LD A, D
    NEG
    LD D, A
    LD A, E
    NEG
    LD E, A
    RET

NEXT_LEVEL:
    LD A, (CURRENT_LEVEL_BCD) 
    LD HL, FINISHED_LEVEL_POS
    CALL BCD_PRINT_HL_A
    LD DE, MESSAGE_LEVEL_FINISHED
    CALL SHOW_MESSAGE_DE
    CALL INC_LEVEL_Z
    LD HL, LEVELS          ; Level 1
    JR Z, START_LEVEL_HL
    LD HL, (NEXT_LEVEL_START_ADDR)
START_LEVEL_HL:
    CALL CLSC
    CALL SHOW_NEXT_LEVEL_HL
    CALL SHOW_STATUS_Z
    RET

GO_RESTART:
    LD HL, (CURRENT_LEVEL_START_ADDR)
    CALL START_LEVEL_HL
    JP WAIT_NEW_KEY

PLAYER_XY:	DB 0,0
UNDO_PLAYER_XY:	DB 0,0
UNDO_DIRECTION:	DB 0	; A játékos utolsó kirajzolt alakjának kódja: UDLR

UNDO_LAST_BOX_NEW_POS:	DW 0  ; Az utolsó hely,a hova toltuk a dobozt
UNDO_LAST_BOX_MOVE:	DW 0  ; Az utolsó dobozeltolás iránya (DE:dXY)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; A játékos mozgatása adott irányban
;;; C : A játékos alakja : UDLR
;;; HL : A játékos aktuális koordinátája
;;; DE : A mozgatás elmozdulása
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MOVE_IF_OK: ; DE A mozgás iránya. Új helyre mozgatja a játékost, ha lehet. Ha nem, akkor marad a régi helyén. C-ben a játékos alakja
    LD A, C
    LD (UNDO_DIRECTION), A     ; Player current direction
    ADD A, 0x20
    LD B, A                    ; B contains the curent active magick wall code
    PUSH BC
    LD HL, (PLAYER_XY)
    LD C, EMPTY_BG             ; BG = Empty
    CALL GET_OBJECT_HL_A       ; A-ban a mandró alatti karakter
    CP PLACEHOLDER
    JR NZ, BG_IS_IN_C
    LD C, PLACEHOLDER          ; BG = Placeholder
BG_IS_IN_C:                    ; C-ben a játékos eredeti helye alatt lévő karakter
    CALL MOVE_HL_WITH_DE
    CALL GET_OBJECT_HL_A       ; A-ban a mandró előtti karakter
    CP 'B'
    JR Z, MOVE_BOX_JP
    CP 'F'
    JR Z, MOVE_BOX_JP  ; A,DE,HL
    CP PLACEHOLDER             ; If placeholder
    JR Z, MOVE_OK
    CP B                       ; If active magick wall
    JR Z, MOVE_OK
    CP EMPTY_BG                ; If empty
    JP Z, MOVE_OK              ;
NOT_MOVE:                      ; Ha nem üres, 
    LD HL, (PLAYER_XY)
    JR SHOW_PLAYER             ; akkor azért még felé fordul, de már nem mozog
MOVE_OK:                       ; Empty or placeholder or active magick wall
    CALL INC_STEP_COUNTER
    EX DE, HL                        ; DE-be kerül az új pozíció
    LD HL, (PLAYER_XY)               ; HL-be a játékos eredeti pozíciója van
    PUSH DE
;    CALL SHOW_OBJECT_HL_C            ; C contains BG
    CALL PUT_OBJECT_HL_C            ; C contains BG

    POP DE
    EX DE, HL                        ; HL-ben az új pozíció
    LD (PLAYER_XY), HL               ; Új pozíció mentése
SHOW_PLAYER:
    CALL APA
    POP BC
    SET 7, C
    CALL CHSCREEN
    JP WAIT_NEW_KEY

;TMP1:	DB 0

;SHOW_OBJECT_HL_C:
;    CALL SET_OBJECT_HL_C
;    PUSH HL
;    PUSH BC
;    CALL APA
;    POP BC
;    POP HL
;;    CALL GET_OBJECT_HL_A
;;    LD C, A
;    SET 7, C
;    CALL CHSCREEN                    ; Most megjeleníytjük ami a jétákos alatt volt
;    RET

PUT_OBJECT_HL_C:
    CALL SET_OBJECT_HL_C
    PUSH HL
    PUSH DE
    PUSH BC
    CALL APA
    POP BC
    PUSH BC
    SET 7, C
    CALL CHSCREEN ; ok
    POP BC
    POP DE
    POP HL
    RET

MOVE_BOX_JP:
    PUSH BC
    CALL MOVE_BOX
    POP BC
    JP MOVE_OK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Egy doboz eltolása
;;; A : Az eltolandó doboz kódja 'B' vagy 'F'
;;; C : A játéko aktuális pozíciója alatt lévő karakter
;;; HL : A doboz jelenlegi, eltolás előtti helye képernyőkoordinátákkal APA számára (H=X, L=Y)
;;; DE : Az eltolás mértéke, iránya (D=dX, E=dY)
;;; A végén 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MOVE_BOX:
    LD (BOX_ORIGI_CHAR), A            ; A doboz eredeti alakja
    LD (UNDO_LAST_BOX_MOVE), DE
    PUSH HL                               ; HL a doboz eredeti helye
    LD B, EMPTY_BG                        ; B tárolja a doboz alattei BG alakját
    CP 'B'                                ; Ha a doboz eredeti alakja 'B', akkor ok
    JR Z, BOX_BG_IS_EMPTY
    LD B, PLACEHOLDER                     ; A DOBOZ alatt Pötty volt
BOX_BG_IS_EMPTY:                          ; B-ben a doboz alatti forma
    CALL MOVE_HL_WITH_DE                  ; HL Doboz új helye HL-be
    LD (UNDO_LAST_BOX_NEW_POS), HL
    CALL GET_OBJECT_HL_A                  ; A doboz új helye alatti eredeti dolog: PLACEHOLDER vagy EMPTY_BG
    LD C, 'F'                             ; A doboz alakját állítsuk 'F'-re
    CP PLACEHOLDER                        ; Ha a doboz alatt PLACEHOLDER volt, 
    JR Z, BOX_MOVE_OK                     ; akkor rendben is vagyunk, C értéke jó, mehet a tolás
    LD C, 'B'                             ; Különben C értéke 'B'
    CP EMPTY_BG                           ; Ha a doboz új helye EMPTY_BG, akkor is mehet a tolás
    JR Z, BOX_MOVE_OK                     ; Egyébként nem tolható a doboz, fejezzük be
    ; fejezzük be
    LD HL, 0
    LD (UNDO_LAST_BOX_NEW_POS), HL
    POP HL
    POP AF
    POP BC                                ; Ez az ág csak mozgásnál jöhet be, undo-nál nem
    JR NOT_MOVE
BOX_MOVE_OK:    ; B-ben a doboz alatt eredetileg lévő forma, C: a doboz új alakja, HL: A doboz új helye. (BOX_ORIGI_CHAR): A doboz eredeti alakja 'F' vagy 'B'
    PUSH BC
    LD C, B
    CALL PUT_OBJECT_HL_C                  ; A dobozt törölhetjük is az eredeti helyéről, és vissza mehet alá az eredeti forma
    POP BC
    PUSH BC
    CALL CHECK_PLACE_COUNTER
    CALL SET_OBJECT_HL_C
    CALL APA
    POP BC
    PUSH BC
    SET 7, C
    CALL CHSCREEN ; ok
    POP BC
    POP HL                    ; A doboz előző helye kerül a HL-be
    LD C, EMPTY_BG
    LD A, (BOX_ORIGI_CHAR)
    CP 'F'
    JR NZ, BOX_ORIGI_CHAR_OK
    LD C, PLACEHOLDER
BOX_ORIGI_CHAR_OK:
    CALL SET_OBJECT_HL_C   ; A doboz előző helyére (HL) kerül ami alatta volt ( C: PLACEHOLDER vagy EMPTY_BG )
    LD A, C
    RET ;     JP MOVE_OK

BOX_ORIGI_CHAR:	DB 0  ; Az eltolt doboz eredeti alakja


CHECK_PLACE_COUNTER: ; C: a doboz új alakja, A: doboz eredeti alakja
    LD A, (BOX_ORIGI_CHAR)
    CP C
    RET Z      ; Nincs változás
    CP 'B'     ;
    JP Z, INC_PLACE_COUNTER    ; Majd itt lesz a RET
    JP DEC_PLACE_COUNTER       ; Majd itt lesz a RET

MOVE_HL_WITH_DE:
    LD A, D
    ADD A, H
    LD H, A
    LD A, E
    ADD A, L
    LD L, A
    RET

GO_LEFT:
    LD DE, 0xFF00
    LD C, 'L'
    JP MOVE_IF_OK
GO_RIGHT:
    LD DE, 0x0100
    LD C, 'R'
    JP MOVE_IF_OK
GO_UP:
    LD DE, 0x00FF
    LD C, 'U'
    JP MOVE_IF_OK
GO_DOWN:
    LD DE, 0x0001
    LD C, 'D'
    JP MOVE_IF_OK

INIT_KEYBOARD: ; IN A, (0x12h)
    LD A, 1
    LD (0x6D60), A
    RET

INIT_PLAYER_HL_C:
    LD A, (HL)
    INC HL
    LD B, (HL)
    INC HL
    PUSH HL
    PUSH BC
    LD H, A
    LD L, B
    LD (PLAYER_XY), HL
    CALL APA
    POP BC
    SET 7, C             ; Move char into DRCS area
    CALL CHSCREEN
    POP HL
    RET

include "inc/soko-constants.asm"
include "inc/ROM.asm"
include "inc/subs.asm"
include "inc/bcd.asm"
; include "inc/soko-sprites-data.asm"
include "inc/soko-start-screen.asm"
include "inc/soko-levels-data.asm"
include "inc/soko-cur-level.asm"
include "inc/soko-status.asm"
include "inc/soko-message.asm"
;include "inc/soko-debug.asm"

SOKOMAP: ; DB SIZE_X * SIZE_Y, 0
