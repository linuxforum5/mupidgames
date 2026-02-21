;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 80 fekete
;;; 81 piros
;;; 82 zöld
;;; 83 sárga
;;; 84 kék
;;; 85 magenta
;;; 86 cián
;;; 87 fehér
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SHOW_START_SCREEN:
    CALL CLSC
    LD A, (START_LEVEL_BCD)
    LD (CURRENT_LEVEL_BCD), A
    LD DE, START_SCREEN_DATA		; Text
    CALL PRINTP_DE
    LD HL, START_SCREEN_STATUS_LINE
    CALL SYSERR
NEXT_KEY:
    CALL SHOW_START_LEVEL
    RST 0x30
    CP 'C'
    JR Z, CHANGE_START_LEVEL
    CP 'c'
    JR Z, CHANGE_START_LEVEL
    CP 32
    JR NZ, NEXT_KEY
    LD A, (START_LEVEL_DEC)
    JR SET_START_LEVEL_A
;    CALL CLSC
;    LD HL, LEVELS
;    RET

SHOW_START_LEVEL:
    LD A, (START_LEVEL_BCD)
    LD HL, START_LEVEL_STR
    CALL BCD_PRINT_HL_A
    LD DE, START_LEVEL_STR_COLOR
    CALL PRINTP_DE
    RET

CHANGE_START_LEVEL:
    CALL CLSC
    LD DE, CHANGE_SCREEN_DATA		; Text
    CALL PRINTP_DE
    LD HL, SELECT_LEVEL_MESSAGE
    CALL SYSERR
WAIT_FOR_CORRECT_LEVEL_KEY:
    RST 0x30
    ; Számok ellenőrzése 1-9
    CP '1'
    JR c, WAIT_FOR_CORRECT_LEVEL_KEY   ; Ha A < '1'
    CP '9'+1
    JR c, SELECT_LEVEL1_9
    ; Betűk ellenőrzése A-K
    RES 5, A   ; Uppercase
    CP 'A'
    JR c, WAIT_FOR_CORRECT_LEVEL_KEY   ; Ha A < 'A'
    CP 'K'+1
    JR c, SELECT_LEVELA_K
    JR WAIT_FOR_CORRECT_LEVEL_KEY

SELECT_LEVEL1_9:
    SUB '0'                  ; A-'0'
    LD (START_LEVEL_BCD), A
    LD (START_LEVEL_DEC), A
    JR SET_START_LEVEL_A

SELECT_LEVELA_K:
    SUB 55                ; A-55 => Level >= 10
    CP 20
    JR nz, START_WITH_1
    ; start level 20
    LD A, 0x20
    LD (START_LEVEL_BCD), A
    LD A, 20
    LD (START_LEVEL_DEC), A
    JR SET_START_LEVEL_A
START_WITH_1:
    PUSH AF
    SUB 10
    OR 0x10
    LD (START_LEVEL_BCD), A
    POP AF
    LD (START_LEVEL_DEC), A
    JR SET_START_LEVEL_A

SET_START_LEVEL_A:       ; A-ban a level
    PUSH AF
    CALL CLSC
    POP AF
    LD B, A
    LD HL, CURRENT_LEVEL_BCD
    LD (HL), 0x01
    LD HL, LEVELS
SKIP_NEXT_LEVEL:
    DEC B
    RET Z               ; HL-ben az aktuális szint kezdőcíme Kezdődhet a játék
SKIP_LEVEL_PREFIX:
    LD A, (HL)
    INC HL
    CP 0
    JR nz, SKIP_LEVEL_PREFIX
    ; Megvan az első 0, HL a második 0-ára mutat és még két szám van uitána
    INC HL
    INC HL
    INC HL
    ; HL a következő szint elejére mutat
    PUSH HL
    PUSH BC
    CALL INC_LEVEL_Z ; INC BCD CURRENT_LEVEL_BCD
    POP BC
    POP HL
    JR SKIP_NEXT_LEVEL

Aa
START_LEVEL_DEC:	DB 0x01 ; Dec
START_LEVEL_BCD:	DB 0x01 ; BCD
START_LEVEL_STR_COLOR:	DB 0x1F,0x55,0x61,0x83
START_LEVEL_STR:	DB 0,0,0

START_SCREEN_DATA: ; ColorId, X, Y, Text chars,

    DB 0x1F,0x41,0x43, 0x81,      "     **    S o u k o b a n    **     " ; Red
    DB 0x1F,0x43,0x43, 0x86,      "  You have taken a part-time job at a" ; Cyan
    DB 0x1F,0x44,0x43, 0x86,      "large storage company!  Your task  is"
    DB 0x1F,0x45,0x43, 0x86,      "to organise 20 warehouses. Please or-"
    DB 0x1F,0x46,0x43, 0x86,      "ganise them neatly.  However, as the "
    DB 0x1F,0x47,0x43, 0x86,      "packages are large, you can only push"
    DB 0x1F,0x48,0x43, 0x86,      "one at a time.  If you  mess up,  you"
    DB 0x1F,0x49,0x43, 0x86,      "won't be able to move the packages!"
    DB 0x1F,0x4A,0x43, 0x86,      "  Please be careful."
    DB 0x1F,0x4C,0x43, 0x85,      "             8 Key (Up)              " ; Magenta
    DB 0x1F,0x4D,0x43, 0x85,      "                |                    "
    DB 0x1F,0x4E,0x43, 0x85,      "     4 Key  -  5 Key  -  6 Key       "
    DB 0x1F,0x4F,0x43, 0x85,      "     (Left)    (Down)    (Right)     "
    DB 0x1F,0x51,0x43, 0x87, 0x1D,"R Move  the packages neatly to  the ",0x1D,"S" ; White
    DB 0x1F,0x52,0x43, 0x87, 0x1D,"P area marked by red dots.          ",0x1D,"P"
    DB 0x1F,0x53,0x43, 0x87, 0x1D,"P If you make a mistake press       ",0x1D,"P" ; F1 Red
    DB 0x1F,0x54,0x43, 0x87, 0x1D,"P                   ", 0x81, "(U, R or X key) ", 0x87, 0x1D, "P" ; F1 Red
    DB 0x1F,0x55,0x43, 0x87, 0x1D,"T    ", 0x83, "Press SPACE to warehouse ..    ", 0x87, 0x1D,"U" ; yellow
    ; DB 0x1F,0x56,0x43, 0x82,      "         (C to hange level)" ; yellow
    DB 0x1F,0x42,0x41, 0xD2 ; R
    DB 0x1F,0x46,0x41, 0xCC ; L
    DB 0x1F,0x4A,0x41, 0xD5 ; U
    DB 0x1F,0x4E,0x41, 0xC4 ; D
    DB 0x1F,0x52,0x41, 0xC2 ; B
    DB 0x1F,0x56,0x41, 0xD7 ; W
    DB 0
START_SCREEN_STATUS_LINE:
    DB 0x82, "     (C to change level)          "
    DB 0x0A

CHANGE_SCREEN_DATA:
    DB 0x1F,0x43,0x49,0x82,"1",0x87," - Warehouse 01"
    DB 0x1F,0x44,0x49,0x82,"2",0x87," - Warehouse 02"
    DB 0x1F,0x45,0x49,0x82,"3",0x87," - Warehouse 03"
    DB 0x1F,0x46,0x49,0x82,"4",0x87," - Warehouse 04"
    DB 0x1F,0x47,0x49,0x82,"5",0x87," - Warehouse 05"
    DB 0x1F,0x48,0x49,0x82,"6",0x87," - Warehouse 06"
    DB 0x1F,0x49,0x49,0x82,"7",0x87," - Warehouse 07"
    DB 0x1F,0x4A,0x49,0x82,"8",0x87," - Warehouse 08"
    DB 0x1F,0x4B,0x49,0x82,"9",0x87," - Warehouse 09"
    DB 0x1F,0x4C,0x49,0x82,"A",0x87," - Warehouse 10"
    DB 0x1F,0x4D,0x49,0x82,"B",0x87," - Warehouse 11"
    DB 0x1F,0x4E,0x49,0x82,"C",0x87," - Warehouse 12"
    DB 0x1F,0x4F,0x49,0x82,"D",0x87," - Warehouse 13"
    DB 0x1F,0x50,0x49,0x82,"E",0x87," - Warehouse 14"
    DB 0x1F,0x51,0x49,0x82,"F",0x87," - Warehouse 15"
    DB 0x1F,0x52,0x49,0x82,"G",0x87," - Warehouse 16"
    DB 0x1F,0x53,0x49,0x82,"H",0x87," - Warehouse 17"
    DB 0x1F,0x54,0x49,0x82,"I",0x87," - Warehouse 18"
    DB 0x1F,0x55,0x49,0x82,"J",0x87," - Warehouse 19"
    DB 0x1F,0x56,0x49,0x82,"K",0x87," - Warehouse 20"
    DB "   ",0
SELECT_LEVEL_MESSAGE:
    DB 0x82, "  Select warehouse to start       "
    DB 0x0A
