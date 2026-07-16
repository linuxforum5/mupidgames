; =====================================================================
; Rutin: A regiszter értékének (0-255) tizedes ASCII karakterekké 
;        alakítása és tárolása a HL címtől kezdve.
; Bemenet:  A  = Konvertálandó szám (0-255)
;          HL = Cél memóriacím (legalább 3 bájt szabad hely szükséges)
; Kimenet: HL = A kiírt karakterek utáni címre mutat
; =====================================================================

NumToAscii_HL_A:
    PUSH HL
    LD (HL), ' '
    INC HL
    LD (HL), ' '
    INC HL
    LD (HL), ' '
    POP HL
    ; Ellenőrizzük a speciális esetet: ha a szám 0
    or a            ; CP 0 gyors verziója (beállítja a Zero flaget, ha A = 0)
    jr nz, .notZero
    ld (hl), '0'    ; Ha 0, akkor egyszerűen kiírjuk a '0' karaktert
    inc hl
    ret

.notZero:
    push bc         ; B és C regiszterek mentése

    ; 1. Százasok vizsgálata
    ld c, 0         ; C-ben számoljuk a százasokat
.loop100:
    cp 100          ; Kisebb a szám, mint 100?
    jr c, .write100 ; Ha igen, mehetünk a kiírásra/kihagyásra
    sub 100         ; Egyébként levonunk 100-at
    inc c           ; És növeljük a százasok számát
    jr .loop100

.write100:
    ld b, c         ; B-be másoljuk a százasok számát (ez lesz a "vezető nulla" jelzőnk)
    ld c, a         ; C-be ideiglenesen elmentjük a maradékot
    ld a, b         ; Visszatöltjük a százasok darabszámát az ellenőrzéshez
    or a            ; Volt százas? (A > 0?)
    jr z, .skip100  ; Ha nem volt, kihagyjuk a karakter mentését
    add a, '0'      ; Átalakítás ASCII karakterré ('0' + darabszám)
    ld (hl), a      ; Mentés a memóriába
    inc hl          ; Mutató léptetése
    ld b, 1         ; B = 1 jelzi, hogy már írtunk ki számjegyet (nincs több vezető nulla)

.skip100:
    ld a, c         ; Maradék visszatöltése A-ba

    ; 2. Tízesek vizsgálata
    ld c, 0         ; C-ben számoljuk a tízeseket
.loop10:
    cp 10           ; Kisebb a szám, mint 10?
    jr c, .write10  ; Ha igen, mehetünk a kiírásra
    sub 10          ; Egyébként levonunk 10-et
    inc c           ; És növeljük a tízesek számát
    jr .loop10

.write10:
    ld d, a         ; D-be elmentjük az egyeseket (maradékot)
    ld a, c         ; A-ba tesszük a tízesek számát
    or a            ; Van tízes?
    jr nz, .save10  ; Ha van, mindenképp kiírjuk
    ld c, b         ; Ha nincs tízes, megnézzük a B-t (volt-e már százas kiírva?)
    or c
    jr z, .skip10   ; Ha nem volt se százas, se tízes, akkor ezt a nullát kihagyjuk

.save10:
    ld a, c         ; Tízesek darabszáma vissza A-ba (ha az or c miatt felülíródott volna)
    add a, '0'      ; ASCII konverzió
    ld (hl), a      ; Mentés
    inc hl          ; Mutató léptetése

.skip10:
    ld a, d         ; Egyesek (maradék) visszatöltése

    ; 3. Egyesek mentése (ezeket mindig ki kell írni)
    add a, '0'      ; ASCII konverzió
    ld (hl), a      ; Mentés
    inc hl          ; Mutató léptetése

    pop bc          ; Eredeti regiszterek visszaállítása
    ret
