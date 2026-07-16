;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MUPID direct keyboard reader
;;; - DIRECT_KEY_INIT  : init direct keyboard driver from 0x7600-0x7646 first free byte: 0x7647
;;; - DIRECT_KEY_INIT_AND_CLEAT_PUFFER : init and clear keyboard puffer
;;; - DIRECT_KEY_CLEAR_PUFFER : Clear puffer ( read keys while not 0 )
;;; - DIRECT_KEY_GET_A_Z : return last pressed key, or 0 if no key pressed
;;; - DIRECT_KEY_WAIT_A : wait for key pressed, and return. key code in A
;;; - DIRECT_KEY_REMOVE: remove custom keyboard driver
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include "lib/key.asm"

DIRECT_KEY_INIT: ; ; IM 2 esetén a 0x44 adatbuszos megszakítás átvétele
    ; copy handler to 0x7600
    LD HL, DIRECT_KEY_IM2_HANDLER_44
    LD DE, 0x7600
    LD BC, DIRECT_KEY_IM2_HANDLER_44_END - DIRECT_KEY_IM2_HANDLER_44
    LDIR                                               ; Copy custom keyboard interrupt handler
    ; set IM 2 table into 0x7644, 0x764A, 0x764C
    LD HL, (0x004A)
    LD (0x764A), HL ; BTX
    LD HL, (0x004C)
    LD (0x764C), HL ; BTX
    LD HL, 0x7600 ; DIRECT_KEY_IM2_HANDLER_44
    LD (0x7644), HL ; Keyboard
    LD A, 0x76 ; Switch into new IM 2 table
    LD I, A
    RET

DIRECT_KEY_INIT_AND_CLEAT_PUFFER:
    CALL DIRECT_KEY_INIT
    CALL DIRECT_KEY_CLEAR_PUFFER
    RET

DIRECT_KEY_CLEAR_PUFFER:
    CALL DIRECT_KEY_GET_A_Z
    JR NZ, DIRECT_KEY_CLEAR_PUFFER
    RET

DIRECT_KEY_REMOVE:
    LD A, 0
    LD I, A
    RET

DIRECT_KEY_GET_A_Z:
    LD A, (DIRECT_KEY_LASTKEY)
    CP 0
    RET Z
    PUSH AF
    LD A, 0
    LD (DIRECT_KEY_LASTKEY), A
    POP AF
    RET

DIRECT_KEY_GET2_A_Z:
    CALL DIRECT_KEY_GET_A_Z
    RET Z
    PUSH AF
DIRECT_KEY_GET2_WAIT:
    CALL DIRECT_KEY_GET_A_Z
    JP NZ, DIRECT_KEY_GET2_WAIT
    POP AF
    RET

RST_0x30:
DIRECT_KEY_WAIT_A:
    CALL DIRECT_KEY_GET_A_Z
    JR Z, DIRECT_KEY_WAIT_A
    RET

DIRECT_KEY_LASTKEY EQU 0x7646 ; : DB 0

DIRECT_KEY_IM2_HANDLER_44: ; billentyűzet megszakítása
    PUSH AF
    IN A,(2)
    LD (DIRECT_KEY_LASTKEY), A
    POP AF
    EI
    RETI
DIRECT_KEY_IM2_HANDLER_44_END:
