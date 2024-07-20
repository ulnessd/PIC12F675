; PIC12F675 Configuration Bit Settings
;Simple interupt program
    
; Assembly source line config statements    

; CONFIG
  CONFIG  FOSC = INTRCIO        ; Oscillator Selection bits
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit
  CONFIG  PWRTE = OFF           ; Power-Up Timer Enable bit
  CONFIG  MCLRE = OFF           ; GP3/MCLR pin function select
  CONFIG  BOREN = ON            ; Brown-out Detect Enable bit
  CONFIG  CP = OFF              ; Code Protection bit
  CONFIG  CPD = OFF             ; Data Code Protection bit

#include <xc.inc>

PSECT resetVect, class=CODE, delta=2, abs, reloc=0x0000
resetVect:
    PAGESEL main
    goto main

;PSECT intVect, class=CODE, delta=2, abs, reloc=0x0004
ORG 0x0004
;intVect:
    ;PAGESEL ISR
    ;bsf STATUS, 5
    ;btfss INTCON, 1 ; Check if it?s the external interrupt
    ;retfie; If not, return from interrupt
    goto ISR  ; Interrupt vector    

main:
    ; initialization of GPIO
    bcf STATUS, 5   ;this shifts us to bank 0
    clrf GPIO	    ;sets the GPIO pins to zero
    movlw 0b00000111	;this selects the comparator setting. see page 37 for the settings
    movwf CMCON	    ;this writes the above setting to the comparator. 
    bsf STATUS, 5   ;this shifts us to bank 1
    movlw 0b00000000	;this selects ansel setting. see page 44 for the settings
    movwf ANSEL	    ;this writes the above setting to the ansel 
    movlw 0b00001100 ; first four zeros are irrelevent. 
		     ; last five bits: GP5, GP4, GP3, GP2, GP1, GP0
		     ; 1 will set to input, 0 will set to output
		     ; GP3 is input only.
    movwf TRISIO


    ; Enable interrupt on GP2 change
    bsf INTCON, 4    ; Enable external interrupt on GP2. See page 13
    bsf OPTION_REG, 6 ; Interrupt on rising edge (clear for falling edge)
    bsf INTCON, 7     ; Enable global interrupts. See page 13

    bcf STATUS, 5   ;this shifts us to bank 0
    
    
mainloop:
    bcf GP5
    bsf GP1
    movlw 25
    call delay
    bcf GP1
    movlw 25
    call delay
    goto mainloop

    
delay: ; this is a three-layer nested loop. wouldn't need 3 but it is what I had 
	; from other programs
    movwf 0xB2
out_out_loop:
    movwf 0xB1
outer_loop:
    movwf 0xB0
delay_loop:
    decfsz 0xB0, 1
    goto delay_loop
    decfsz 0xB1, 1
    goto outer_loop
    decfsz 0xB2, 1
    goto out_out_loop
    retlw 0 ; the return sets the working register to zero. 
    nop 


ISR:
    bsf STATUS, 5   ; move to bank 0
    bcf INTCON, 1   ; Clear interrupt flag
    bcf STATUS, 5   ; move to bank 1
    
    ; delay
    movlw 255
    movwf 0xB3
intloop:    
    bsf GP5
    decfsz 0xB3, 1
    goto intloop
    nop
    retfie
