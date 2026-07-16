;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MUPID keyboard functions (over RST 20h)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
KEY_BEEP        EQU 007h ; BELL
KEY_READ_ANALOG EQU 0F0h ; + ... 3/n Lesen Analogeingang n = 0 - 7 (Wertebereich : 0 - 255)
KEY_CLOSE       EQU 0FAh ; Tastatur sperren
KEY_SEL_CLOSE   EQU 0FBh ; selektive Tastatursperre (alle Tasten außer den alphabetischen Zeichen)
KEY_RESET       EQU 0FCh ; Key Reset (Tastatur neu initialisieren)
KEY_SND_ON      EQU 0FDh ; Tastenklick ein
KEY_SND_OFF     EQU 0FEh ; Tastenklick aus
KEY_PROGRAMMING EQU 0FFh ; Programmierung der Tasten

WAIT_FOR_KEY_PRESS EQU 030h ; RST 30h Wait for key press and send back ASCII code in A register
GET_KEY_A          EQU 0542h ; Current next key ASCII code from puffer or 0 if puffer is empty into A. Use "ld hl,06d53h" command before call it

KEY_CTRL_PORT EQU 3 ; 0x01
KEY_DATA_PORT EQU 2 ; 0x00
KEY_IM2_ADDR  EQU 0x44
