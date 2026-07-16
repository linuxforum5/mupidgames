;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Segítséget
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SHOW_HELP1:
    LD A, (LevelNumber)
    CP ' '
    JR NZ, HIDE_HELP
    LD A, NUMBER_COUNTER
    ; HELP ON
    LD HL, LEVELS
    LD A, (PUZZLE_DATA)
    DEC A
    LD D, 0
    LD E, A
    ADD HL, DE
    LD A, (HL)
    LD (DISPLAY_NUMBERS_HIDE_COUNTER), A
    ADD A, '0'
    LD (LevelNumber), A
    CALL DISPLAY_NUMBERS
    LD HL, HELP_LEVEL_ON
    LD DE, HELP_LEVEL_ON_END-HELP_LEVEL_ON
    CALL BTX_PRINT_HL_DE
    RET

HIDE_HELP:
    LD A, ' '
    LD (LevelNumber), A
    LD HL, HELP_LEVEL_OFF
    LD DE, HELP_LEVEL_OFF_END-HELP_LEVEL_OFF
    CALL BTX_PRINT_HL_DE
    LD A, NUMBER_COUNTER
    LD (DISPLAY_NUMBERS_HIDE_COUNTER), A
    CALL DISPLAY_NUMBERS
    RET
