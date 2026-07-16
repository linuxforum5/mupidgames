
SOUND_NO_SPACE:
    EXX
    CALL sound_init
    LD A, 130
    CALL music_set_length_A
    LD A, 5
    CALL sound_play_n_A ; N. félhang lejátszása
    EXX
    RET
