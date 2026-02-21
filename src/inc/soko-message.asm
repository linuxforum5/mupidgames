;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mupid Sokoban Menü
;;; Lehetőségek:
;;; - Restart current level
;;; - Restart full game
;;; - Next level
;;; - Back to the current level
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SHOW_MESSAGE_DE:
    CALL PRINTP_DE
    RST 0x30
    RET

; Ha kész a szint:
MESSAGE_LEVEL_FINISHED_LEVEL_POS
MESSAGE_LEVEL_FINISHED: DB 0x1F,0x48,0x41,0x83,0x1D,"R",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"S"
                        DB 0x1F,0x49,0x41,0x83,0x1D,"P The "
FINISHED_LEVEL_POS:     DB "00. warehouse  has been cleaned! ",0x1D,"P"
                        DB 0x1F,0x4A,0x41,0x83,0x1D,"P Press ",0x82,"any key",0x83," to the next warehouse. ",0x1D,"P"
                        DB 0x1F,0x4B,0x41,0x83,0x1D,"T",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"Q",0x1D,"U"
                        DB 0
;P Would you like to move to the next warehouse? P"
; Ha kész az utolsó szint is
;MESSAGE_LAST_FINISHED:	DB "** CONGRATULATION **"

; Ha nincs kész, és ez volt az utolsó próbálkozás, azaz kirúgtak
;FINISH_LAST_TRY:	DB "* You got fired from your job! Try again? (Y/N)"
; --- Ha már csak 1 láda kellett volna végéhez
;FINISH_MAYBE_TEXT "That was close! Do better next time!\nWould you like to try again? (Y/N)"
; --- Ha még több mint egy láda van hátra
;FINISH_BAD:	DB "Pull yourself together! They're going to fire you!\nTry again? (Y/N)"
