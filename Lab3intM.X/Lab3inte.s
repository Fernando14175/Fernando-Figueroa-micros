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
    
PSECT udata_bank0 
    
  CONT1: ds 1 
  CONT2: ds 1
  

PSECT udata_shr 
  STATUS_TEMP: DS 1
  W_TEMP:      DS 1 

PSECT resVect, class=CODE, abs, delta = 2
;-------------vector res---------------------------
ORG 00h
    resetVec: 
	PAGESEL main
	goto    main
;----------------------Interrupcion VEC-----------------------
PSECT intVect, class = CODE,abs, delta = 2 
ORG 04h

 push: 
    MOVWF W_TEMP 
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
    
 isr:
    btfsc  RBIF 
    call   PuertoA
    
    btfsc  T0IF 
    call   timerint
    

 pop:
    SWAPF STATUS_TEMP, W
    MOVWF STATUS 
    SWAPF W_TEMP, F 
    SWAPF W_TEMP, W
    RETFIE
 ;---------------interrupcion----------------------------
 PuertoA:
    btfss  PORTB, 1
    incf   PORTA
    btfss  PORTB, 0
    decf   PORTA
    movf   PORTB, W 
    bcf    RBIF
    return
 
 timerint:
   incf  PORTD          //incrementamos el puertob
   return
 
    
PSECT code, delta = 2, abs 
 ORG 100h
   
;-----------Main-----------------
    
main:    
     
      call SETUP
      call rbioc     
   
      
               //vamos al main
;--------------------Interrupcion----------------------
loop:
        //llamamos la rutina comparar
    call frecuencia	    //llamamos la funcion frecuencia
    call timer0	    //llamamos la funcion timer0
    btfss T0IF            //llamamos la funcion T0IF
    goto  $-1
    call  empezar         //llamamos la funcion empezar
    incf  contarriba          //incrementamos el puertob 
    movf  contarriba, W
    call  display
    movwf PORTD
    movf  PORTA, W
    call  display
    movwf PORTC
    goto  loop
rbioc: 
    banksel TRISA
    movlw   00000011B
    movwf   IOCB 
    
    banksel PORTB
    movf    PORTB, W
    bcf     RBIF 
    bsf     GIE 
    bsf     RBIE 
    return
    
SETUP:  
    banksel ANSEL
    CLRF ANSEL    ;entradas digitales
    CLRF ANSELH   ;entradas digitales 
    
    
   banksel TRISA
  
    bcf TRISA, 0
    bcf TRISA, 1
    bcf TRISA, 2
    bcf TRISA, 3
    
    bsf TRISB, 0
    bsf TRISB, 1
    bsf TRISB, 2
    bsf TRISB, 3
    bsf TRISB, 7
    
    bcf TRISC, 0
    bcf TRISC, 1
    bcf TRISC, 2
    bcf TRISC, 3
    bcf TRISC, 4
    bcf TRISC, 5
    bcf TRISC, 6
    bcf TRISC, 7
    
    bcf TRISD, 0
    bcf TRISD, 1
    bcf TRISD, 2
    bcf TRISD, 3
    bcf TRISD, 4
    bcf TRISD, 5
    bcf TRISD, 6
    bcf TRISD, 7
    
    
    
    bcf   OPTION_REG, 7 //encendemos el bit del pull up 
    movlw 11111111B
    movwf WPUB
    
    
    banksel PORTA
    clrf PORTA 
    clrf PORTC
    clrf PORTD
    return
  
;--------------------Tabla----------------------
    
display:
   CLRF  PCLATH              ;limpiamos el registro
   bsf   PCLATH, 0 ;ponemos en 1 el bit 0 del registro
   andlw 00001111B
   ADDWF PCL                 ;sumamos 1 al pcl para poder determinar que sale ne l display
   RETLW 00111111B ;numero_0
   RETLW 00000110B ;numero_1
   RETLW 01011011B ;numero_2
   RETLW 01001111B ;numero_3
   RETLW 01100110B ;numero_4
   RETLW 01101101B ;numero_5
   RETLW 01111101B ;numero_6
   RETLW 00000111B ;numero_7
   RETLW 01111111B ;numero_8
   RETLW 01101111B ;numero_9
   RETLW 01110111B ;numero_A
   RETLW 01111100B ;numero_B
   RETLW 00111001B ;numero_C
   RETLW 01011110B ;numero_D
   RETLW 01111001B ;numero_E
   RETLW 01110001B ;numero_F
   return
   
  
;-----------Configuraciones timer y oscilador-----------------

 
    
timer0:
    banksel OPTION_REG //nos vamos al banko 1
    bcf     T0CS //escogemos los valores del timer
    bcf     PSA
    bsf     PS2
    bsf     PS1
    bcf     PS0
    banksel PORTA
    call    empezar
    return
 
 frecuencia:
    banksel OSCCON //nos vamos al bancoo 1 
    bcf     IRCF0  //escogemos los valores del osscon
    bcf     IRCF1
    bcf     IRCF2
    bsf     SCS 
    return
    
    
 empezar:
    movlw   226  //movemos la literal al timer 0
    movwf   TMR0
    bcf     T0IF
    return
    
;-----------------------------Alarma---------------------------

DELAY:
    
    MOVLW 0Xfa     //movemos una literal 
    MOVWF CONT1   //movemos la literal cont1
    MOVLW 0X0d    //movemos otra literal 
    MOVWF CONT2   //movemos la literal al cont2
    
LOOP:
    DECFSZ CONT1, 1
    GOTO LOOP
    DECFSZ CONT2, 1
    GOTO LOOP
    NOP
RETURN

END

    





