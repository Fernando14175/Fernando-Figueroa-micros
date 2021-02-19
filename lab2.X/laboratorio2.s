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
     alarma     EQU 0
     


PSECT udata_bank0 
    
  CONT1: ds 1 
  CONT2: ds 1
  
    

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
    
    BCF TRISC,0
    BCF TRISC,1
    BCF TRISC,2
    BCF TRISC,3
    
    
    BCF TRISE,0
    
    BSF TRISA,0
    BSF TRISA,1
    
    BCF  STATUS,6 ;nos cambiamos de banco
    BCF  STATUS,5 
    
    clrf PORTB
    clrf PORTC
    bcf  PORTE,0
   
;-----------Main-----------------
    
main:
      call comparar 
      call frecuencia
      call timer0
      call presionar_arriba
      call presionar_abajo
      btfss T0IF
      goto  $-1
      call  empezar
      incf  PORTB
      call  comparar 
      call resett
      goto main
       

;--------------------Botones subir -----------------------  
presionar_arriba: 
    btfss PORTA, 0		;revisamos si esta presionado el boton
    return
    call anti_rebote_Arriba1	;llamamos a la siguiente rutina  
    return                      ;regresamos a donde llamamos a la rutina
anti_rebote_Arriba1:
    btfsc PORTA, 0
    goto anti_rebote_Arriba1    ;nos movemos a la rutina 
    call aumentar1              ;llamamos a la rutina 
    return
aumentar1:
    INCF contarriba,1
    MOVF contarriba, w
    call display
    MOVWF PORTC
    return
;--------------------Botones bajar -----------------------  
 presionar_abajo: 
    btfss PORTA, 1		;revisamos si esta presionado el boton
    return
    call anti_rebote_abajo1	;llamamos a la siguiente rutina  
    return                      ;regresamos a donde llamamos a la rutina
anti_rebote_abajo1:
    btfsc PORTA, 1
    goto anti_rebote_abajo1    ;nos movemos a la rutina 
    call bajar1              ;llamamos a la rutina 
    return
bajar1:
    DECF contarriba,1
    MOVF contarriba, w
    call display
    MOVWF PORTC
    return
    
;--------------------Tabla----------------------
    
display:
   CLRF  PCLATH
   bsf   PCLATH, 0 
   ADDWF PCL
   RETLW 0000B ;numero_0
   RETLW 1000B ;numero_1
   RETLW 0100B ;numero_2
   RETLW 1100B ;numero_3
   RETLW 0010B ;numero_4
   RETLW 1010B ;numero_5
   RETLW 0110B ;numero_6
   RETLW 1110B ;numero_7
   RETLW 0001B ;numero_8
   RETLW 1001B ;numero_9
   RETLW 0101B ;numero_A
   RETLW 1101B ;numero_B
   RETLW 0011B ;numero_C
   RETLW 1011B ;numero_D
   RETLW 0111B ;numero_E
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
    
;-----------------------------Alarma---------------------------
 comparar:
    MOVF   PORTB, W
    XORWF  PORTC, W
    BTFSC  STATUS, 2
    bsf PORTE,0
    return

;----------------------------reset----------------------------
 resett:
   btfsc PORTE, 0 
   bcf PORTE,0
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

    


