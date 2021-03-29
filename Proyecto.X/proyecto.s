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
  cont:         ds 2
  TMR0_TEMP:    ds 1
  T0_TEMP:      ds 1
  T0_ACT:       ds 1
  estado:       ds 1  
  unidad:       ds 1
  decena:       ds 1
  centena:      ds 1
  num_binario:  ds 1 
  display_cont: ds 1 
    
  BMODO   EQU 2
  B2      EQU 0
  B3      EQU 1  
  
    
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
    btfsc  RBIF         ;interrupcion externa
    call   int_ioc
    
    
 pop:
    SWAPF STATUS_TEMP,W
    MOVWF STATUS 
    SWAPF W_TEMP, F 
    SWAPF W_TEMP, W
    RETFIE
 
 int_ioc:
    movf   estado, W
    clrf   PCLATH 
    andlw  0x03 
    addwf  PCL
    goto   estado_0_int
    goto   estado_1_int
    goto   estado_2_int

estado_0_int:
    btfsc  PORTB, BMODO
    goto   end_ioc 
    ;estado = 1
    incf estado
    ;T0_TEMP <=T0_ACT 
    movf   T0_ACT, W 
    movwf  T0_TEMP
    goto   end_ioc
    
estado_1_int:
    btfss  PORTB, B2
    incf   T0_TEMP
    btfss  PORTB, B3
    decf   T0_TEMP
    btfss  PORTB, BMODO
    incf   estado 
    goto   end_ioc
    
estado_2_int: 
     btfss  PORTB, B3
     clrf   estado
     btfss  PORTB, B2
     goto   end_ioc
     ; T0_ACT <= T0_TEMP
     movf   T0_TEMP, W
     movwf  T0_ACT
     ; cambio estado
     clrf   estado
     
     
end_ioc:
    bcf    RBIF
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
      call config_reloj         ;llamamos la config del timer
      call config_rbioc
      call config_TMR0
      banksel PORTA
      clrf    estado
loop:
   
   bcf    GIE
   movf   estado, W
   clrf   PCLATH
   bsf    PCLATH, 0 
   andlw  0x03 
   addwf  PCL
   goto   estado_0
   goto   estado_1
   goto   estado_2
  
   
loop2:
   call mover_decenas    ;llamamos a la funcion centenas
   call Imprimir_display_1  ;imprimimos en los tres displays
   /*call Imprimir_display_2  ;imprimimos en los tres displays
   call Imprimir_display_3  ;imprimimos en los tres displays
   call Imprimir_display_4  ;imprimimos en los tres displays*/
   return
   
mover_puerto:
   movf display_cont, W          ;movemos el porta a w para los dos leds
   movwf num_binario
   xorlw 0x21
   btfsc STATUS, 2
   call  res_puerto
   goto loop2
   
res_puerto:
    movlw 0x00
    movwf display_cont
    movwf num_binario
    return
   
estado_0:
   bsf    GIE
   ;clrf   PORTD
   bsf    PORTC, 0
   bcf    PORTC, 2
   bcf    PORTC, 1
   btfss  T0IF 
   goto   $-1 
   call   restart_TMR0
   incf   display_cont
   call   mover_puerto
   goto   loop
   
estado_1:
    bsf    GIE
    ;movf   T0_TEMP, W
    ;movwf  PORTD
    bsf    PORTC, 1
    bcf    PORTC, 2
    bcf    PORTC, 0
    goto   loop
    
estado_2:
    bsf    GIE
    ;movf   T0_TEMP, W
    ;movwf  PORTD
    bsf    PORTC, 2
    bcf    PORTC, 0
    bcf    PORTC, 1
    goto   loop
     
restart_TMR0:    
    movf     T0_ACT, W 
    movwf    TMR0
    bcf      T0IF 
    return
   
config_TMR0: 
    banksel  TRISA 
    bcf      T0CS 
    bcf      PSA 
    bsf      PS2 
    bsf      PS1 
    bsf      PS0 
    banksel  PORTA
    movlw    0
    movwf    T0_ACT
    movf     T0_ACT, W 
    movwf    TMR0
    bcf      T0IF 
    return

config_rbioc:
    banksel  TRISA
    bsf      IOCB, BMODO
    bsf      IOCB, B2
    bsf      IOCB, B3
    
    banksel  PORTB 
    movf     PORTB, W 
    bcf      RBIF 
    bsf      GIE 
    bsf      RBIE 
    return 

config_io:
    banksel  ANSEL 
    clrf     ANSEL 
    clrf     ANSELH 
    
    banksel TRISA
    clrf    TRISA 
    clrf    TRISC
    clrf    TRISD
    clrf    TRISE
    movlw   00000111B 
    movwf   TRISB 
    bcf     OPTION_REG, 7 
    movlw   0xff
    movwf   WPUB
    
    banksel PORTA
    clrf    PORTA 
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
    return

config_reloj: 
    banksel OSCCON
    bsf     IRCF2 
    bcf     IRCF1 
    bcf     IRCF0
    bsf     SCS 
    return 
 
delay_big:
    movlw   35
    movwf   cont+1
    call    delay_small 
    decfsz  cont+1, 1
    goto    $-2
    return

delay_small: 
    movlw   135
    movwf   cont 
    decfsz  cont, 1 
    goto    $-1
    return

Imprimir_display_1:       
     call apagar_displays   ;apagamos todos los displays 
     movf decena,W
     call display           ;llamamos para imprimir las decenas
     movwf PORTD
     call display_1_1    ;encendemos el display del centro
     //call display_2_1    ;encendemos el display del centro
     //call display_3_1    ;encendemos el display del centro

     call apagar_displays   ;apagamos todos los displays 
     movf unidad, W
     call display           ;llamamos para imprimir las decenas
     movwf PORTD
     call display_1_2       ;encendemos el display del centro
     //call display_2_2       ;encendemos el display del centro
     //call display_3_2       ;encendemos el display del centro
     return

/*Imprimir_display_2:     
     call apagar_displays   ;apagamos todos los displays 
     movf decena,W
     call display           ;llamamos para imprimir las decenas
     movwf PORTD
     call display_2_1    ;encendemos el display del centro

     call apagar_displays   ;apagamos todos los displays 
     movf unidad, W
     call display           ;llamamos para imprimir las decenas
     movwf PORTD
     call display_2_2       ;encendemos el display del centro
     return

Imprimir_display_3:     
     call apagar_displays   ;apagamos todos los displays 
     movf decena,W
     call display           ;llamamos para imprimir las decenas
     movwf PORTD
     call display_3_1    ;encendemos el display del centro

     call apagar_displays   ;apagamos todos los displays 
     movf unidad, W
     call display           ;llamamos para imprimir las decenas
     movwf PORTD
     call display_3_2       ;encendemos el display del centro
     return

Imprimir_display_4:     
     call apagar_displays   ;apagamos todos los displays 
     movf decena,W
     call display           ;llamamos para imprimir las decenas
     movwf PORTD
     call display_4_1    ;encendemos el display del centro

     call apagar_displays   ;apagamos todos los displays 
     movf unidad, W
     call display           ;llamamos para imprimir las decenas
     movwf PORTD
     call display_4_2       ;encendemos el display del centro
     return*/
  
apagar_displays:
    bcf PORTE, 1 
    bcf PORTE, 2 
    bcf PORTC, 3
    bcf PORTC, 4
    bcf PORTC, 5
    bcf PORTC, 6
    bcf PORTB, 3
    bcf PORTB, 4
    return


display_1_1:            ;encendemos el display del centro
    bsf PORTE, 1
    bsf PORTC, 3
    bsf PORTC, 5
    call delay_big
    return

display_1_2:               ;encendemos el display derecho
    bsf PORTE, 2 
    bsf PORTC, 4
    bsf PORTC, 6
    call delay_big
    return  

/*display_2_1:               ;encendemos el display derecho
    bsf PORTC, 3 
    call delay_big
    return  
 
display_2_2:               ;encendemos el display derecho
    bsf PORTC, 4 
    call delay_big
    return  

display_3_1:               ;encendemos el display derecho
    bsf PORTC, 5 
    call delay_big
    return  
 
display_3_2:               ;encendemos el display derecho
    bsf PORTC, 6 
    call delay_big
    return  

display_4_1:               ;encendemos el display derecho
    bsf PORTB, 3 
    call delay_big
    return  
 
display_4_2:               ;encendemos el display derecho
    bsf PORTB, 4
    call delay_big
    return*/


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
  
END 



