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
  
    
PSECT udata_bank0   ;declaramos variables
  count:    ds 1
  cont:     ds 2
  banderas1:    ds 1
   unidad:       ds 1
  decena:       ds 1
  centena:      ds 1
  num_binario:  ds  1  
  display_var1: ds 2
  display_var2: ds 2
      
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
    MOVWF W_TEMP        ;interrupciones 
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
    
 isr:
    btfsc  TMR2IF         ;interrupcion externa
    call   fue_tmr2
    btfsc  TMR1IF
    call   fue_tmr1
    
    btfsc T0IF         ;interrupcion timer
    call  timerint
    
    
 pop:
    SWAPF STATUS_TEMP,W
    MOVWF STATUS 
    SWAPF W_TEMP, F 
    SWAPF W_TEMP, W
    RETFIE
    
fue_tmr1:
    movlw   50
    movwf   TMR1H
    movlw   300
    movwf   TMR1L
    bcf     TMR1IF
    incf    PORTA
    return

fue_tmr2:
    clrf    TMR2
    bcf     TMR2IF
    btfsc   PORTD, 0 
    bcf     PORTD ,0
    bcf     PORTE, 0
    bcf     PORTE, 1
    call    delay_big
    bsf     PORTD, 0
    bSf     PORTE, 0
    bsf     PORTE, 1
    return
    
timerint: 
    movlw   240           ;empezamos el timer 
    movwf   TMR0
    bcf     T0IF
    clrf    PORTE        ;limpiamos para multiplexar
    btfsc   banderas1, 0 ;revisamos que el bit este en 0 para hacer multiplexado para los primeros dos displays 
    goto    display_2    ;encendemos un display
    goto    display_1    ;encendemos el otro display
   
display_1:
    movf display_var1, W  ;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTE, 0
    goto  siguiente_display ;apagamos la bandera para el otro display
      
display_2:
    movf display_var2, W  ;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTE, 1
    goto  siguiente_display ;apagamos la bandera para el otro display
    
siguiente_display:
    movlw 1
    xorwf banderas1, F  ;hacemos un xor para cambiar la variable banderas1
    return

    
PSECT code, delta = 2, abs 
 ORG 100h
    
 display:
   CLRF  PCLATH              ;limpiamos el registro
   bsf   PCLATH, 0           ;ponemos en 1 el bit 0 del registro
   ADDWF PCL                 ;sumamos 1 al pcl para poder determinar que sale en el display
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
   return
    
main:    
      call config_io        ;configuracion para tiempo del timer
      call config_reloj     ;llamamos la config del timer
      call config_timer
      call config_tmr1
      call config_tmr2
      call config_interrupt
      banksel PORTA
loop:
   goto  mover_puerto

loop2:
   call mover_decenas    ;llamamos a la funcion centenas
   call preparar_displays ;le mandamos el valor a los displays
   goto loop

mover_puerto:
   movf PORTA, W          ;movemos el porta a w para los dos leds
   movwf num_binario
   xorlw 0x64
   btfsc STATUS, 2
   call  res_puerto
   goto loop2
   
res_puerto:
    movlw 0x00
    movwf PORTA
    movwf num_binario
    return
    
config_io:
    
    banksel TRISA
    clrf    TRISC
    clrf    TRISA 
    clrf    TRISD
    clrf    TRISE
    
    banksel  ANSEL 
    clrf     ANSEL 
    clrf     ANSELH 
    
    banksel  PORTA
    clrf     PORTA
    clrf     PORTD 
    clrf     PORTE
    clrf     PORTC
    return
   
config_reloj: 
    banksel OSCCON
    bcf     IRCF2 
    bsf     IRCF1 
    bcf     IRCF0
    bsf     SCS 
    return 

config_tmr1: 
    banksel PORTA 
    bcf     TMR1GE
    bcf     T1CKPS1
    bsf     T1CKPS0
    bcf     T1OSCEN
    bcf     TMR1CS
    bsf     TMR1ON
    movlw   0Bh
    movwf   TMR1H
    movlw   0EEH
    movwf   TMR1L
    bcf     TMR1IF
    return
    
 config_tmr2: 
    banksel  PORTA
    bsf      TOUTPS3
    bsf      TOUTPS2
    bsf      TOUTPS1
    bsf      TOUTPS0
    bsf      TMR2ON
    bsf      T2CKPS1
    bsf      T2CKPS0
    banksel  TRISA 
    movlw    140
    movwf    PR2
    banksel  PORTA
    clrf     TMR2
    bcf      TMR2IF
    return

config_interrupt:
    banksel   TRISA
    bsf       TMR1IE
    bsf       TMR2IE
    banksel   PORTA
    bsf       GIE 
    bsf       PEIE
    bcf       TMR1IF
    bcf       TMR2IF
    return

   
preparar_displays:          ;le mandamos a cada variables su resepctivo numero
    movf    decena, W 
    call    display
    movwf   display_var1 
    
    movf    unidad, W
    call    display
    movwf   display_var2
    return

config_timer:           ;configuracion del timer 
    banksel TRISA
    bcf     T0SE
    bcf     T0CS
    bcf     PSA
    bsf     PS2
    bsf     PS1
    bsf     PS0
    banksel PORTA
    movlw   240
    movwf   TMR0
    bcf     T0IF
    bsf     T0IE
    bcf     T0IF   
    return
 

mover_decenas:              ;movemos las literales a restar para las decenas
    clrf    decena   
    movlw   10
    goto    conv_decenas
 
mover_unidades:             ;movemos las literales a restar para las unidades
    clrf    unidad
    movlw   10
    addwf   num_binario
    movlw   1
    goto    conv_unidades
      
conv_decenas:
    subwf   num_binario,F   ;hacemos la conversion de decenas a bcd para el valor decimal
    btfss   STATUS,0
    goto    mover_unidades
    incf    decena, F
    goto    conv_decenas 
    
conv_unidades:
    subwf   num_binario,F   ;hacemos la conversion de unidades a bcd para el valor decimal
    btfss   STATUS, 0
    return
    incf    unidad, F
    goto    conv_unidades
    
delay_big:
    movlw   70
    movwf   cont+1
    call    delay_small 
    decfsz  cont+1, 1
    goto    $-2
    return

delay_small: 
    movlw   40
    movwf   cont 
    decfsz  cont, 1 
    goto    $-1
    return



END 






