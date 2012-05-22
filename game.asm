	.inesprg 1		;pamiêæ PRG 16KB
	.ineschr 1		;grafiki 8KB
	.inesmap 0		;brak mapera
	.inesmir 1		;nie wiem

;######################Per-Inicjalizacja##########################

	.bank 0
	.org $C000
StartReset:
	SEI			;blokada maperów
	CLD			;wyl¹czenie decimal mode (nes nie obs³uguje)

	LDX #$40
	STX $4017	;kolejne mapery

	LDX #$FF
	TXS			;zerowanie wskaŸnika stosu

	INX			;Zerowanie X (256 + 1 = 0)
	
	STX $2000	
	STX $2001
	STX $4010	; Wy³¹czenie grafiki (musi siê najpierw zainicjalizowaæ wiêæ musi zostaæ wy³¹czona!)

	JMP Inicjalizacja
;######################Funkcje Inicjalizacji##########################
ResetGrafy:
	BIT $2002
	BPL ResetGrafy
	RTS				;return
CzyscPamiec:
	LDA #00
	STA $0000, X
	STA $0200, X
	STA $0400, X
	STA $0500, X
	STA $0600, X
	STA $0700, X

	LDA #$FE		;
	STA $0300, X	; reser spritów (przesuñ poza ekran)
	INX
	BNE CzyscPamiec

	RTS				;return 

WlaczGrafe:
	LDA #%10000000		
	STA $2000		;przerwania rtsowania
	LDA #%00010000
	STA $2001		;rysowanie spriteów
	RTS				;return

InicjalizujKolory:
	LDA $2002
	LDA #$3F
	STA $2006
	LDA #$00
	STA $2006
	LDX #$00
PetlaKolory:
	LDA koloryData, X
	STA $2007
	INX
	CPX #$20
	BNE PetlaKolory
	RTS				;return

;######################Inicjalizacja##########################
Inicjalizacja:
	JSR ResetGrafy
	JSR CzyscPamiec
	JSR ResetGrafy
	JSR InicjalizujKolory
	JSR WlaczGrafe
	JMP StartGame


;######################Start Game##########################
StartGame:
	LDA #$80
	STA $0200        ; put sprite 0 in center ($80) of screen vert
	STA $0203        ; put sprite 0 in center ($80) of screen horiz
	LDA #$00
	STA $0201        ; tile number = 0
	STA $0202        ; color = 0, no flipping

	LDX #03
	LDA #$80
	STA $0204        ; put sprite 0 in center ($80) of screen vert
	STA $0207, X     ; put sprite 0 in center ($80) of screen horiz
	LDA #$00
	STA $0205        ; tile number = 0
	STA $0206        ; color = 0, no flipping

UpdateLoop:
	LDX $0000
	BNE UpdateLoop
	INC $0200
	DEC $0000
	JMP UpdateLoop

NMIDraw:
	;Save State {
	PHP
	PHA
	TXA
	PHA
	TYA 
	PHA

	;}
	
	JSR DrawStrites
	INC $0000

	;LoadState {
	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	;}
	RTI		;return

;######################DrawHelpers##########################
DrawStrites:;{
	LDA #$00
	STA $2003
	LDA #02
	STA $4014
	RTS		;return
;}

;######################ZasobyRAM##########################

	.bank 1
	.org $E000
koloryData:
  .db $0F,$31,$32,$33,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F
  .db $0F,$1C,$15,$14,$0F,$02,$38,$3C,$0F,$1C,$15,$14,$0F,$02,$38,$3C


	.org $FFFA
	.dw NMIDraw
	.dw StartReset
	.dw 0

;######################ZasobyGrafa##########################

	.bank 2
	.org $0000
	.incbin "mario.chr"