; PIC12F675 Configuration Bit Settings
; ADC test
    
; Assembly source line config statements

; CONFIG
  CONFIG  FOSC = INTRCIO        ; Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-Up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; GP3/MCLR pin function select (GP3/MCLR pin function is digital I/O, MCLR internally tied to VDD)
  CONFIG  BOREN = ON            ; Brown-out Detect Enable bit (BOD enabled)
  CONFIG  CP = OFF              ; Code Protection bit (Program Memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)

// config statements should precede project file includes.
#include <xc.inc>
  

PSECT resetVect, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
    
    
PSECT code, delta=2
main:
    ; initialization of GPIO
    bcf STATUS, 5   ;this shifts us to bank 0
    clrf GPIO	    ;sets the GPIO pins to zero
    movlw 0b00000000	;this selects the comparator setting. see page 37 for the settings
    movwf CMCON	    ;this writes the above setting to the comparator. 
    bsf STATUS, 5   ;this shifts us to bank 1
    movlw 0b00110001	;this selects ansel setting. see page 44 for the settings
    movwf ANSEL	    ;this writes the above setting to the ansel 
    movlw 0b00001001 ; first four zeros are irrelevent. 
		     ; last five bits: GP5, GP4, GP3, GP2, GP1, GP0
		     ; 1 will set to input, 0 will set to output
		     ; GP3 is input only.
    movwf TRISIO
    bcf STATUS, 5   ;this shifts us to bank 0 note the GPIO is on bank 0
    nop
    nop
    
    ;extra stuff for ADC
    movlw 0b00000000	;this selects adcon0 setting. see page 43 for the settings
    movwf ADCON0
    clrf ADRESH
    clrf ADRESL
mainloop:
    bcf GP2
    bcf GP1
    bcf GP4
    bcf GP5
    
    bsf ADCON0, 0 ; turning the ADC off
    nop
    bsf ADCON0, 1 ; turning ADC go on
    
    ; reading the 4 most significant bits in ADRESH
    btfsc ADRESH, 7 
    bsf GP5
    btfsc ADRESH, 6 
    bsf GP4
    btfsc ADRESH, 5 
    bsf GP2
    btfsc ADRESH, 4 
    bsf GP1
    movlw 2  ; a momentary delay. It seems neccessary to have this slight delay
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
 
