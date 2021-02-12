PROCESSOR 16F887
    #include "xc.inc"
  
    CONFIG FOSC = INTRC_NOCLKOUT
    CONFIG WDTE = OFF       
    CONFIG PWRTE = ON      
    CONFIG MCLRE = OFF     
    CONFIG CP = OFF         
    CONFIG CPD = OFF        
    CONFIG BOREN = OFF      
    CONFIG IESO = OFF       
    CONFIG FCMEN = OFF      
    CONFIG LVP = ON        

    ;configuration word 1
    CONFIG WRT = OFF
    CONFIG BOR4V=BOR40V
    
     contarriba EQU 0
     contabajo  EQU 0


PSECT udata_bank0 
    
  CONT1: ds 1 
  CONT2: ds 1
  
    
PSECT resVect, class = CODE, abs, delta = 2
 ORG 00h
 resetVEC:
    PAGESEL SETUP
    GOTO SETUP
    
PSECT code, delta = 2, abs 
 ORG 100h 

    
SETUP:  
    BSF	STATUS, 5 ;entramos al banco para poder entrar el registro ansel y poder limpiarlo
    BSF STATUS, 6
    CLRF ANSEL    ;entradas digitales
    CLRF ANSELH   ;entradas digitales 
    
    BCF  STATUS,6 ;nos cambiamos de banco
    BSF  STATUS,5 
   
    BCF TRISB,0
    BCF TRISB,1
    BCF TRISB,2
    BCF TRISB,3
    BCF TRISB,4
    BCF TRISB,5
    
    BCF TRISD,0
    BCF TRISD,1
    BCF TRISD,2
    BCF TRISD,3
    
    BSF TRISB,0
    BSF TRISB,1
    
    clrf PORTB
    clrf PORTD
   
;-----------Main-----------------
    
main: ;declaramos el main
    call frecuencia
    call timer0  
    call loop_display

contador_timer0:
    btfss T0IF
    goto  $-1
    call  empezar
    incf  PORTB
    goto  contador_timer0
    
    
   
    
;--------------------Display-----------------------    
loop_display:
call display    
MOVWF PORTC
return

;--------------------Botones -----------------------  
presionar_arriba: 
    btfss PORTA, 0		;revisamos si esta presionado el boton
    return			;regresamos a donde llamamos la rutina
    call anti_rebote_Arriba1	;llamamos a la siguiente rutina  
    return                      ;regresamos a donde llamamos a la rutina
anti_rebote_Arriba1:
    btfsc PORTA, 0              ;revisamos que el boton ya no este presionado
    goto anti_rebote_Arriba1    ;nos movemos a la rutina 
    call aumentar1              ;llamamos a la rutina 
    return
aumentar1:
    INCF contarriba,1
    MOVF contarriba,W
    call display
    
;--------------------Tabla-----------------------
    
display: 
   MOVWF PCL 
   RETLW 0000B ;numero_0
   RETLW 0001B ;numero_1
   RETLW 0010B ;numero_2
   RETLW 0011B ;numero_3
   RETLW 0100B ;numero_4
   RETLW 0101B ;numero_5
   RETLW 0110B ;numero_6
   RETLW 0111B ;numero_7
   RETLW 1000B ;numero_8
   RETLW 1001B;numero_9
   RETLW 1010B;numero_A
   RETLW 1011B ;numero_B
   RETLW 1100B ;numero_C
   RETLW 1101B ;numero_D
   RETLW 1110B ;numero_E
   RETLW 1111B ;numero_F
   return
    
;-----------Configuraciones timer y oscilador-----------------
    
timer0:
    banksel OPTION_REG
    bcf     T0CS
    bcf     PSA
    bsf     PS2
    bsf     PS1
    bcf     PS0
    banksel PORTA
    call    empezar
    return
 
 frecuencia:
    banksel OSCCON
    bcf     IRCF0
    bcf     IRCF1
    bcf     IRCF2
    bsf     SCS 
    return
    
    
 empezar:
    movlw   226
    movwf   TMR0
    bcf     T0IF
    return
    
    
;-----------Delays-----------------
    DELAY_50MS:
	MOVLW 100
	MOVWF CONT2 
    CONFIG1:
	CALL	DELAY_50MS
	DECFSZ  CONT2,F 
	GOTO    CONFIG1
    RETURN
    
    DELAY_500US:
	MOVLW  250
	MOVWF  CONT1 
	DECFSZ CONT1,F
	GOTO   $-1  
    RETURN
     
END

    


