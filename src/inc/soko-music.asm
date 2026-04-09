;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Sound effects to events
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PLAY_END_OF_LEVEL_SOUND:
    EXX
    CALL sound_init
    LD HL, END_OF_LEVEL_MUSIC
    CALL music_play_HL
    EXX
    RET

PLAY_MOVE_TO_PLACE:
    RET
    EXX
;    CALL sound_init
    LD HL, MOVE_TO_PLACE_MUSIC
    CALL music_play_HL
    EXX
    RET

PLAY_MOVE_FROM_PLACE:
    RET
    EXX
;    CALL sound_init
    LD HL, MOVE_FROM_PLACE_MUSIC
    CALL music_play_HL
    EXX
    RET

;PLAY_PUSH_SOUND: ; 0x81,0x30
;    EXX
;    LD A, 2
;    LD BC, 0xD700
;    CALL sound_play_A_BC ; Egy hang lejátszása: A=hossz BC=masgasság (C első bájt, B második)
;    EXX
;    RET

PLAY_STEP_SOUND:
    RET
;    EXX
;    LD A, 2
;    LD BC, 0x3C00
;    CALL sound_play_A_BC ; Egy hang lejátszása: A=hossz BC=masgasság (C első bájt, B második)
;    EXX
;    RET

PLAY_NO_STEP_SOUND:
    EXX
    CALL sound_init
    LD A, 130
    CALL music_set_length_A
    LD A, 5
    CALL sound_play_n_A ; N. félhang lejátszása
    EXX
    RET

PLAY_UNDO_SOUND:
    CALL sound_init
    LD HL, UNDO_MUSIC
    CALL music_play_HL
    RET

END_OF_LEVEL_MUSIC: ; cdeggegggg
    DB 0x86,0x0C, 0x86,0x0E, 0x86,0x10, 0x8C,0x13, 0x86,0x10, 0x98,0x13, EOM
MOVE_TO_PLACE_MUSIC: ; ceg
    DB 0x82,0x0C,0x10,0x13, EOM
UNDO_MUSIC:
MOVE_FROM_PLACE_MUSIC: ; gec
    DB 0x82,0x13,0x10,0x0C, EOM

include "inc/sound.asm"
