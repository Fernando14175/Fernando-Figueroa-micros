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
  
 NUMERO equ 0x124
    
PSECT udata_bank0   ;declaramos variables
  var1:         ds 1
  banderas1:    ds 1
  nibble1:      ds 2 
  nibble2:      ds 2 
  display_var1: ds 2
  display_var2: ds 2
  CONT1:       ds 1 
  CONT2:       ds 1
  unidad:    ds 1
  decena:      ds 1
  centena:      ds 1
  num_binario:		DS  1
    
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
    call   PuertoA
   
    
    btfsc T0IF         ;interrupcion timer
    call  timerint
    
    

 pop:
    SWAPF STATUS_TEMP,W
    MOVWF STATUS 
    SWAPF W_TEMP, F 
    SWAPF W_TEMP, W
    RETFIE
 
 PuertoA:
    btfss  PORTB, 0  ;incrementamos el puerto con la interrupcion
    incf   PORTA
    btfss  PORTB, 1
    decf   PORTA
    bcf    RBIF      ;limpiamos la interrupcion
    return
    
timerint: 
    movlw   61           ;empezamos el timer 
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
   RETLW 01110111B ;numero_A
   RETLW 01111100B ;numero_B
   RETLW 00111001B ;numero_C
   RETLW 01011110B ;numero_D
   RETLW 01111001B ;numero_E
   RETLW 01110001B ;numero_F
   return
    
main:    
      call SETUP		;llamamos la configuracion del pic
      call config_tiempo        ;configuracion para tiempo del timer
      call config_timer         ;llamamos la config del timer
      call interrupciones                ;llamamos a las interrucpiones
      banksel PORTA
      
loop:
     movf PORTA, W          ;movemos el porta a w para los dos leds
     movwf num_binario      ;movemos el puerto a la variable para convertir a bcd para el decimal
     movwf var1             ;movemos la variable para los dos displays
     call mover_centenas    ;llamamos a la funcion centenas
     call separar_nibbles   ;separamos los datos de los displays 
     call preparar_displays ;le mandamos el valor a los displays 
     call Imprimir_display  ;imprimimos en los tres displays
     goto  loop  

Imprimir_display:     
     call apagar_displays   ;apagamos todos los displays 
     movf centena, W        ;movemos las centenas a w
     call display           ;llamamos para imprimir las centenas
     movwf PORTD            ;movemos las centenas al puerto d 
     call display_izq       ;encendemos el display de la izquierda

     call apagar_displays   ;apagamos todos los displays 
     movf decena,W	
     call display           ;llamamos para imprimir las decenas
     movwf PORTD
     call display_centro    ;encendemos el display del centro

     call apagar_displays   ;apagamos todos los displays 
     movf unidad, W	
     call display           ;llamamos para imprimir las decenas
     movwf PORTD
     call display_der       ;encendemos el display del centro
     return
     
interrupciones:             ;inicializamos las interrupciones
    banksel TRISA
    bsf     IOCB, 0
    bsf     IOCB, 1
    
    banksel PORTB
    movf    PORTB, W
    bcf     RBIF 
    bsf     GIE
    bsf     RBIE 
    return

separar_nibbles:            ;separamos los valores de cada display para los primeros dos 
    movf var1,W 
    andlw 0x0f
    movwf nibble1
    
    swapf var1, W           ; giramos los bits para tener los otros dos datos
    andlw 0x0f
    movwf nibble2
   
 
preparar_displays:          ;le mandamos a cada variables su resepctivo numero
    movf    nibble1, W 
    call    display
    movwf   display_var1 
    
    movf    nibble2, W
    call    display
    movwf   display_var2
   
    return
    
apagar_displays:
    bcf PORTB, 5           ;apagamos los tres displays 
    bcf PORTB, 6 
    bcf PORTB, 7 
    return

display_izq:
    bsf PORTB, 5           ;encendemos el display izquierdo 
    call Delay
    return

display_centro:            ;encendemos el display del centro
    bsf PORTB, 6
    call Delay
    return

display_der:               ;encendemos el display derecho
    bsf PORTB, 7 
    call Delay
    return

SETUP:                     ;configuracion del pic
    banksel ANSEL  
    clrf    ANSEL
    clrf    ANSELH
    
    banksel TRISA
    
    bcf  TRISA, 0
    bcf  TRISA, 1
    bcf  TRISA, 2
    bcf  TRISA, 3
    bcf  TRISA, 4
    bcf  TRISA, 5
    bcf  TRISA, 6
    bcf  TRISA, 7
    
    bcf  TRISD, 0
    bcf  TRISD, 1
    bcf  TRISD, 2
    bcf  TRISD, 3
    bcf  TRISD, 4
    bcf  TRISD, 5
    bcf  TRISD, 6
    bcf  TRISD, 7
       
    bsf TRISB, 0
    bsf TRISB, 1
    bcf TRISB, 5
    bcf TRISB, 6
    bcf TRISB, 7
  
    clrf TRISC
    
    
    bcf  TRISE,0
    bcf  TRISE,1
    
   
    banksel PORTA
    clrf    PORTC
    clrf    PORTA
    clrf    PORTE
    clrf    PORTB
    clrf    PORTD
    return

config_tiempo:          ;configuracion del osscon para el tiempo del pic
    banksel OSCCON  
    bsf     IRCF2
    bsf     IRCF1
    bcf     IRCF0
    bsf     SCS
    return
 
config_timer:           ;configuracion del timer 
    banksel TRISA
    bcf     T0CS
    bcf     PSA
    bsf     PS2
    bsf     PS1
    bsf     PS0
    banksel PORTA
    movlw   61
    movwf   TMR0
    bcf     T0IF
    bsf     T0IE
    bcf     T0IF   
    return
 
mover_centenas:             ;movemos las literales a restar para las centenas
    clrf    centena
    movlw   100    
    goto    conv_centenas

mover_decenas:              ;movemos las literales a restar para las decenas
    clrf    decena   
    movlw   100
    addwf   num_binario
    movlw   10
    goto conv_decenas
 
mover_unidades:             ;movemos las literales a restar para las unidades
    clrf    unidad
    movlw   10
    addwf   num_binario
    movlw   1
    goto    conv_unidades
    
conv_centenas:              ;hacemos la conversion de centenas a bcd para el valor decimal
    subwf   num_binario, F        
    btfss   STATUS,0   		
    goto    mover_decenas
    incf    centena, F
    goto    conv_centenas
    
    
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
 
Delay:
    
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

    





