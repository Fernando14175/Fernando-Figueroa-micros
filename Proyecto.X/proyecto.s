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
  
    
PSECT udata_bank0	    ;declaramos registros 
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
  semaforo_estado: ds 1 
  display_var1: ds 2
  display_var2: ds 2
  display_var3: ds 2
  display_var4: ds 2
  display_var5: ds 2
  display_var6: ds 2
  banderas1_2:    ds 1
  banderas3_4:    ds 1
  banderas5_6:    ds 1
  ultbanderas1_2:    ds 1
  ultbanderas3_4:    ds 1
  ultbanderas5_6:    ds 1
  semaforo_cont: ds 1
  seleccion_sem: ds 1
  numero_contador: ds 1
  mandar_contador: ds 1
  cambiar_display: ds 1
  cambiar_display2: ds 1
  seleccion_ultdisplay: ds 1
  listo_ultdisplay: ds 1
    
  BMODO   EQU 2
  B0      EQU 0
  B1      EQU 1  
  B3      EQU 3
  B6      EQU 6
    
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
    MOVWF W_TEMP		;push para las interrupciones
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
    
 isr:
    btfsc  RBIF			;interrupcion de los botones 
    call   int_ioc		;llamamos la interrupcion de los botones
    
    btfsc  TMR1IF		;interrupcion del timer 1 
    call   fue_tmr1		;llamamos a la interrupcion del timer1
    
    btfsc  T0IF			;interrupcion timer0
    call   timerint		;llamamos interrupcion del timer0
    
    
 pop:				;pop para las interrupciones 
    SWAPF STATUS_TEMP,W
    MOVWF STATUS 
    SWAPF W_TEMP, F 
    SWAPF W_TEMP, W
    RETFIE
  
incrementar_reset:                      ;reseteamos he incrementamos las variables 
    clrf  semaforo_cont                 ;limpiamos semaforo cont, para empezar de 0 otra ves 
    incf  seleccion_sem                 ;incremento la variable que enciende cada semaforo 
    movf  seleccion_sem, w              ;la movemos a w
    xorlw 3                             ;revisamos con 3 porque son 3 semaforos 
    btfsc STATUS, 2                      
    clrf  seleccion_sem                 ;limpiamos seleccion sem porque ya paso por los tres semaforos asi repetimos el ciclo
    
    incf  cambiar_display               ;incrementamos la variable para cambiar el multiplexado
    movf  cambiar_display, w            ;movemos la vairable a w 
    xorlw 3                             ;revisamos con 3 
    btfsc STATUS, 2
    clrf  cambiar_display               ;limpiamos la variable porque ya paso el numero maximo y regresamos a 0 
    
    incf  cambiar_display2              ;incrementamos la variable del 4 display para mandarle un valor diferente 
    movf  cambiar_display2, w           ;la movemos a w  
    xorlw 3                             ;revisamos que sea 3 para empezarla de 0 y regresar al principio
    btfsc STATUS, 2
    clrf  cambiar_display2              ;la limpiamos para regresar al principio
    return                               

fue_tmr1:
    movlw   254                         ;empezamos el timer1
    movwf   TMR1H                       
    movlw   66
    movwf   TMR1L
    bcf     TMR1IF
    call    multiplexado                ;limpiamos los puertos para multiplexar
    
    movf    cambiar_display2, w         ;movemos la variable del ultimo display
    xorlw   0                           ;revisamos que sea 0 para poner el tiempo de ese semaforo
    btfsc   STATUS, 2
    call    display1                    ;llamamos el multiplexado 
    movf    cambiar_display, w          ;movemos la variable de los otros tres displays 
    xorlw   0                           ;revisamos que sea 0
    btfsc   STATUS, 2
    goto    multiplex_display1_2        ;vamos al multiplexado para el otro display
    
    movf    cambiar_display2, w         ;movemos la variable del ultimo display
    xorlw   1                           ;revisamos si es 1 
    btfsc   STATUS, 2
    call    display2                    ;llamamos al multiplexado de ese display
    movf    cambiar_display, w          ;mandamos la variable del los otros displays 
    xorlw   1                           ;revisamos que sea 1 
    btfsc   STATUS, 2 
    goto    multiplex_display3_4        ;multiplexamos 
    
    movf    cambiar_display2, w         ;movemos la variable del ultimo display
    xorlw   2                           ;revisamos que sea 1 
    btfsc   STATUS, 2
    call    display3                    ;llamamos el multiplexado del 4to display
    movf    cambiar_display, w          ;movemos a w 
    xorlw   2                           ;revisamos que sea 2 
    btfsc   STATUS, 2
    goto    multiplex_display5_6        ;llamamos el multiplexado del display 5 y 6 
    goto    multiplex_display1_2        ;llamamos el multiplexado del display 1 y 2 para repetir 
    
multiplexado:
    bcf     PORTE,0			;limpiamos para multiplexar
    bcf     PORTE,1			;limpiamos para multiplexar
    bcf     PORTA,2			;limpiamos para multiplexar
    bcf     PORTA,3			;limpiamos para multiplexar
    bcf     PORTA,0			;limpiamos para multiplexar
    bcf     PORTA,1			;limpiamos para multiplexar
    bcf     PORTB,4			;limpiamos para multiplexar
    bcf     PORTB,5			;limpiamos para multiplexar
    return
 
display1:  
    movf    listo_ultdisplay, w         ;variable que revisa en que display estamos 
    xorlw   1                           ;revisamos que sea 1 
    btfsc   STATUS, 2                    
    goto    multiplex_ultdisplay1_2     ;multiplexamos 
    return
    
display2: 
    movf    listo_ultdisplay, w         ;variable que revisa en que display estamos 
    xorlw   2                           ;revisamos que sea 2
    btfsc   STATUS, 2
    goto    multiplex_ultdisplay3_4     ;multiplexamos 
    return
    
display3:  
    movf    listo_ultdisplay, w         ;variable que revisa en que display estamos
    xorlw   3                           ;revisamos que sea 3
    btfsc   STATUS, 2
    goto   multiplex_ultdisplay5_6      ;multiplexamos 
    return
    
 multiplex_ultdisplay1_2:
    btfsc   ultbanderas1_2, 0           ;revisamos que el bit este en 0 para hacer multiplexado para los primeros dos displays
    goto    ultdisplay_1                ;encendemos un display
    goto    ultdisplay_2                ;encendemos un display
 
 multiplex_ultdisplay3_4:
    btfsc   ultbanderas3_4, 0		;revisamos que el bit este en 0 para hacer multiplexado para los primeros dos displays
    goto    ultdisplay_4		;encendemos un display
    goto    ultdisplay_3		;encendemos un display
 
 multiplex_ultdisplay5_6:
    btfsc   ultbanderas5_6, 0		;revisamos que el bit este en 0 para hacer multiplexado para los primeros dos displays
    goto    ultdisplay_6		;encendemos un display
    goto    ultdisplay_5		;encendemos un display
  
 multiplex_display1_2:
    btfsc   banderas1_2, 0		;revisamos que el bit este en 0 para hacer multiplexado para los primeros dos displays
    goto    display_2			;encendemos un display
    goto    display_1			;encendemos un display
 
 multiplex_display3_4:
    btfsc   banderas3_4, 0		;revisamos que el bit este en 0 para hacer multiplexado para los primeros dos displays
    goto    display_4			;encendemos un display
    goto    display_3			;encendemos un display
 
 multiplex_display5_6:
    btfsc   banderas5_6, 0		;revisamos que el bit este en 0 para hacer multiplexado para los primeros dos displays
    goto    display_6			;encendemos un display
    goto    display_5			;encendemos un display
    
 timerint:                           
    call    restart_TMR0	        ;reiniciamos el timer 0 
    incf    display_cont                ;incrementamos variable que mandamos al conversor 
    incf    semaforo_cont               ;incrementamos variable que se usa para poner los colores 
    movf    semaforo_cont, w            ;mandamos variable a w 
    xorwf   mandar_contador, w          ;revisamos que sean iguales para llamar incrementar reset y completar un ciclo
    btfsc   STATUS, 2
    call    incrementar_reset           ;llamamos incrementar reset 
    return
 
    
display_1:
    movf display_var1, W		;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTE, 0
    goto  siguiente_display1		;apagamos la bandera para el otro display
      
display_2:
    movf display_var2, W		;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTE, 1
    goto  siguiente_display1		;apagamos la bandera para el otro display
    
siguiente_display1:
    movlw 1
    xorwf banderas1_2, F		;hacemos un xor para cambiar la variable banderas1
    return

ultdisplay_1:
    movf display_var1, W		;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTB, 4
    goto  siguiente_ultdisplay1		;apagamos la bandera para el otro display
      
ultdisplay_2:
    movf display_var2, W		;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTB, 5
    goto  siguiente_ultdisplay1		;apagamos la bandera para el otro display 

siguiente_ultdisplay1:
    movlw 1
    xorwf ultbanderas1_2, F		;hacemos un xor para cambiar la variable banderas1
    return    
    
display_3:
    movf display_var3, W		;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTA, 0
    goto  siguiente_display2		;apagamos la bandera para el otro display
      
display_4:
    movf display_var4, W		;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTA, 1
    goto  siguiente_display2		;apagamos la bandera para el otro display
    
siguiente_display2:
    movlw 1
    xorwf banderas3_4, F		;hacemos un xor para cambiar la variable banderas1
    return

ultdisplay_3:
    movf display_var3, W		;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTB, 4
    goto  siguiente_ultdisplay2		;apagamos la bandera para el otro display
      
ultdisplay_4:
    movf display_var4, W		;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTB, 5
    goto  siguiente_ultdisplay2		 ;apagamos la bandera para el otro display
    
siguiente_ultdisplay2:
    movlw 1
    xorwf ultbanderas3_4, F		;hacemos un xor para cambiar la variable banderas1
    return
    
 
display_5:
    movf display_var5, W		;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTA, 2
    goto  siguiente_display3		;apagamos la bandera para el otro display
      
display_6:
    movf display_var6, W		;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTA, 3
    goto  siguiente_display3		;apagamos la bandera para el otro display
    
siguiente_display3:
    movlw 1
    xorwf banderas5_6, F		;hacemos un xor para cambiar la variable banderas1
    return  

ultdisplay_5:
    movf display_var5, W		;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTB, 4
    goto  siguiente_ultdisplay3		;apagamos la bandera para el otro display
      
ultdisplay_6:
    movf display_var6, W		;le mandamos al display la variable que tiene el numero 
    movwf PORTC
    bsf   PORTB, 5
    goto  siguiente_ultdisplay3		;apagamos la bandera para el otro display
    
siguiente_ultdisplay3:
    movlw 1
    xorwf ultbanderas5_6, F		;hacemos un xor para cambiar la variable banderas1
    return  
    
 int_ioc:
    movf   estado, W                    ;movemos el estado a w
    clrf   PCLATH                       ;usamos una lista para escoger el estado
    andlw  0x03 
    addwf  PCL 
    goto   estado_0_int                 ;vamos al estado0
    goto   estado_1_int                 ;vamos al estado1
    goto   estado_2_int                 ;vamos al estado2

estado_0_int:                           ;estado mandamos variables 
    btfsc  PORTB, BMODO                 ;revisamos el boton del modo
    goto   end_ioc                      ;terminamos 
    ;estado = 1
    incf estado                         ;incrementamos el estado 
    ;T0_TEMP <=T0_ACT 
    movf  numero_contador, W            ;movemos el nuevo valor del contador a w
    movwf  mandar_contador              ;movemos el valor a la variable mandar contador, la usamos para decirle al semaforo en que momento dar una vuelta 
    movf   T0_ACT, W                    ;movemos el tiempo del timer0 a w 
    movwf  T0_TEMP                      ;movemos el nuevo tiempo del timer0 al timer 0
    
estado_1_int:                            ;estado 1 revisamos botones  
    btfss  PORTB, B3                     ;revisamos el boton que cambia el display
    incf   seleccion_ultdisplay          ;cambiamos el dislay
    btfss  PORTB, B0                     ;revisamos el boton B0 para aumentar el tiempo
    call   aumentar                     
    btfss  PORTB, B1
    call   disminuir                     ;revisamos el boton B0 para disminuir el tiempo
    btfss  PORTB, BMODO                  ;revisamos el boton BMODO para cambiar el estado 
    incf   estado 
    btfss  PORTB, B6                     ;revisamos el reset
    call   resetear
    goto   end_ioc
    
estado_2_int: 
     btfss  PORTB, B1                    ;revisamos el boton b1
     clrf   estado                       ;limpiamos el estado para regresar 
     btfss  PORTB, B0                    ;revisamos el boton B0
     goto   end_ioc                      ;terminamos la interrupcion
     ; T0_ACT <= T0_TEMP                   
     movf   seleccion_ultdisplay, W      ;movemos la variable a w 
     movwf  listo_ultdisplay             ;movemos la variable que selecciona el display 
     movf   numero_contador, W           ;movemos la variable del tiempo 
     movwf  mandar_contador              ;movemos la variable del tiempo 
     movf   T0_TEMP, W                   ;movemos el  tiempo del timer 
     movwf  T0_ACT                       ;cambiamos el tiempo del timer 
     ; cambio estado
     clrf   estado                       ;limpiamos el estado 
     clrf   display_cont                 ;limpiamos la variable que mandamos al display
     clrf   semaforo_cont                ;limpiamos la del semaforo
     goto   end_ioc                      ;terminamos la interrupcion
     
resetear:                                ;limpiamos y mandamos 255 al puerto c para ver el reset manual
     call   delay_big                    ;llamamos unos delay para poder ver el reseteo
     call   delay_big
     movlw  255
     movwf  PORTC
     call   delay_big
     call   delay_big
     clrf   estado                       ;limpiamos variables para el reset 
     clrf   display_cont
     clrf   semaforo_cont
     return
     
aumentar: 
    incf   T0_TEMP                       ;incrementamos el tiempo del timer 
    incf   numero_contador               ;incrementamos el numero del contador 
    movf   numero_contador, w            ;lo movemos a w 
    xorlw  21                            ;revisamos que sea 21 para regresarlo a 10
    btfsc STATUS, 2             
    call  regresar10                     ;regresamos a 10 el valor para que quede entre 20 y 10
    return
    
regresar10:
    movlw   10                           ;movemos 10 a w
    movwf   numero_contador              ;movemos 10 a numero contador 
    return                                

disminuir:
    decf   T0_TEMP                       ;le bajamos el tiempo al timer 0
    decf   numero_contador               ;bajamos el numero del display
    return 
    
end_ioc:                                 ;terminamos la interrupcion
    bcf    RBIF                          ;limpiamos la interrupcion
    return 
    
    
PSECT code, delta = 2, abs 
 ORG 100h
    
 display:
   CLRF  PCLATH				  ;limpiamos el registro
   bsf   PCLATH, 0			  ;ponemos en 1 el bit 0 del registro
   ADDWF PCL				  ;sumamos 1 al pcl para poder determinar que sale en el display
   RETLW 00111111B			  ;numero_0
   RETLW 00000110B			  ;numero_1
   RETLW 01011011B			  ;numero_2
   RETLW 01001111B			  ;numero_3
   RETLW 01100110B			  ;numero_4
   RETLW 01101101B			  ;numero_5
   RETLW 01111101B			  ;numero_6
   RETLW 00000111B			  ;numero_7
   RETLW 01111111B			  ;numero_8
   RETLW 01101111B			  ;numero_9
   return
    
main:    
      call    config_io			  ;configuracion para tiempo del timer
      call    config_reloj		  ;llamamos la config del oscilador
      call    config_rbioc                ;llamamos la interrupcion de los botones 
      call    config_TMR0                 ;config del timer 0
      call    config_tmr1                 ;config del timer1
      call    config_interrupt            ;interrupciones 
      banksel PORTA
      clrf    estado                      ;limpiamos los estados 
      
loop:
   call   llamar_semaforos                ;llamamos semaforos para poder cmabiar entre semaforos 
   movf   display_cont, W		  ;movemos el registro a w para el conversor 
   movwf  num_binario                     ;movemos a num binario para el conversor 
   xorwf  mandar_contador, w              ;revisamos cuando sean iguales para resetear
   btfsc  STATUS, 2
   call   res_puerto                      ;reseteamos 
   call   mover_decenas			  ;llamamos al concersor 
   call   preparar_displays		  ;le mandamos las variables a los displays 
   bcf    GIE                             
   movf   estado, W                       ;movemos el estado a w 
   clrf   PCLATH                          ;usamos una lista para encender los leds de los estados 
   bsf    PCLATH, 0 
   andlw  0x03 
   addwf  PCL
   goto   estado_0                        ;estado 1 
   goto   estado_1                        ;estado 2 
   goto   estado_2                        ;estado 3 
 
llamar_semaforos:
    call semaforo1                        ;nos vamos a semaforo1 
    call semaforo2                        ;nos vamos a semaforo2
    call semaforo3                        ;nos vamos a semaforo3
    return 
    
semaforo1:
    movf  seleccion_sem, w               ;revisamos que la variable del semaforo sea 0 para el primer semaforo
    xorlw 0                              ;revisamos que sea 0
    btfsc STATUS, 2
    call  encender_sem1                  ;encendemos el semaforo 1
    return

encender_sem1:
    bcf  PORTD, 0
    bcf  PORTD, 1
    bsf  PORTD, 2
    bsf  PORTD, 3
    bcf  PORTD, 4
    bcf  PORTD, 5
    bsf  PORTD, 6
    bcf  PORTD, 7
    bcf  PORTE, 2
    movf    semaforo_cont, w            ;revisamos en donde va el contador 
    xorlw   20
    btfsc   STATUS, 2
    call    amarillo2                   ;encendemos el amarillo 
    return

amarillo2:                         
    bcf   PORTD, 3                      ;apagamos la luz roja 
    bsf   PORTD, 4                      ;encendemos la amarilla 
    xorwf mandar_contador, w            ;revisamos el contador para apagar el amarillo 
    btfsc STATUS, 2
    call  encender
    return

encender:                               ;apagamos el amarillo 
    bcf   PORTD, 4                      ;apagamos la roja 
    bcf   PORTD, 3                      ;encendemos la amarilla 
    return

semaforo2:                              
    movf  seleccion_sem, w              ;movemos la variable de los semaforos a w
    xorlw 1                             ;revisamos que sea 1
    btfsc STATUS, 2
    call  encender_sem2                 ;encendemos el seamforo 2
    return

encender_sem2:                         
    bsf  PORTD, 0
    bcf  PORTD, 1
    bcf  PORTD, 2
    bcf  PORTD, 3
    bcf  PORTD, 4
    bsf  PORTD, 5
    bsf  PORTD, 6
    bcf  PORTD, 7
    bcf  PORTE, 2
    movf    semaforo_cont, w           ;revisamos el contador sel semaforo 
    xorlw   20                        
    btfsc STATUS, 2
    call  amarillo3                     ;encendemos el amarillo 
    return

amarillo3: 
    bcf   PORTD,  6                     ;apagamos la luz roja 
    bsf   PORTD,  7                     ;encendemos el amarillo 
    xorwf mandar_contador, w            ;revisamos el contador 
    btfsc STATUS, 2
    call  encender2                     ;apagamos el amarillo 
    return

encender2:
    bcf   PORTD, 7                      ;apagamos el amarillo 
    bcf   PORTD, 6                      ;apagamos el rojo
    return    
   
semaforo3:
    movf  seleccion_sem, w              ;movemos la variable del semaforo a w 
    xorlw 2                             ;revisamos que sea 2 
    btfsc STATUS, 2                     
    call  encender_sem3                 ;encendemos el otro semaforo 
    return

encender_sem3:
    bsf  PORTD, 0
    bcf  PORTD, 1
    bcf  PORTD, 2
    bsf  PORTD, 3
    bcf  PORTD, 4
    bcf  PORTD, 5
    bcf  PORTD, 6
    bcf  PORTD, 7
    bsf  PORTE, 2
    movf    semaforo_cont, w           ;revisamos el contador 
    xorlw   20     
    btfsc STATUS, 2
    call  amarillo                     ;encedemos el amarillo 
    return

amarillo: 
    bcf   PORTD,  0                    ;apagamos el rojo 
    bsf   PORTD,  1                    ;encendemos el amarillo 
    xorwf mandar_contador, w           ;revisamos el contador 
    btfsc STATUS, 2
    call  encender3                    ;apagamaos el amarillo
    return                    
 
encender3:
    bcf   PORTD, 1                     ;apagamos el rojo 
    bcf   PORTD, 0                     ;apagamos el amarillo 
    
res_puerto:                            ;empezamos desde 0 el display  cuando ya dio una vuelta 
    movlw 0                            ;movemos la variable 0
    movwf display_cont                 ;movemos el reseteo a display_cont
    movwf num_binario                  ; lo movemos al num binario para que llegue el  al conversor 
    return
   
estado_0:                              ;encendemos los ledss del estado 0
   bsf    GIE
   //clrf   PORTA
   bsf    PORTA, 4
   bcf    PORTA, 6
   bcf    PORTA, 5
   goto   loop
   
estado_1:                              ;encendemos los leds del estado 1
    bsf    GIE
    //movf   T0_TEMP, W
    //movwf  PORTA
    bsf    PORTA, 5
    bcf    PORTA, 6
    bcf    PORTA, 4
    goto   loop
    
estado_2:                              ;encendemos los leds del estado 1
    bsf    GIE
    //movf   T0_TEMP, W
    //movwf  PORTA
    bsf    PORTA, 6
    bcf    PORTA, 4
    bcf    PORTA, 5
    goto   loop
     
restart_TMR0:                          ;empezamos otra ves el timer 0
    movf     T0_ACT, W 
    movwf    TMR0
    bcf      T0IF 
    return
   
config_TMR0:                           ;config del timer 0
    banksel  TRISA
    bcf      T0SE
    bcf      T0CS
    bcf      PSA
    bsf      PS2
    bsf      PS1
    bcf      PS0
    banksel  PORTA
    movlw    150
    movwf    T0_ACT                   ;mandamos la variable al timer 0 para cambairle el tiempo
    movf     T0_ACT, W                ;mandamos la variable al timer 0 para cambairle el tiempo
    movwf    TMR0
    bcf      T0IF
    bsf      T0IE
    bcf      T0IF   
    return

config_tmr1:                           ;config del timer1
    banksel PORTA 
    bcf     TMR1GE
    bsf     T1CKPS1
    bsf     T1CKPS0
    bcf     T1OSCEN
    bcf     TMR1CS
    bsf     TMR1ON
    movlw   254
    movwf   TMR1H
    movlw   66
    movwf   TMR1L
    bcf     TMR1IF
    return

config_interrupt:                     ;config de las interrupciones 
    banksel   TRISA
    bsf       TMR1IE
    bsf       TMR2IE
    banksel   PORTA
    bsf       GIE 
    bsf       PEIE
    bcf       TMR1IF
    bcf       TMR2IF
    return

config_rbioc:
    banksel  TRISA                   ;config de la interrupcion de los botones 
    bsf      IOCB, BMODO             ;interrup con change para los botones 
    bsf      IOCB, B0                ;interrup con change para los botones
    bsf      IOCB, B1                ;interrup con change para los botones
    bsf      IOCB, B3                ;interrup con change para los botones
    bsf      IOCB, B6                ;interrup con change para los botones
    
    banksel  PORTB 
    movf     PORTB, W                
    bcf      RBIF 
    bsf      GIE 
    bsf      RBIE 
    return 

config_io:                           ;entradas y salidas 
    banksel  ANSEL 
    clrf     ANSEL 
    clrf     ANSELH 
    
    banksel TRISA
    clrf    TRISA 
    clrf    TRISC
    clrf    TRISD
    clrf    TRISE
    movlw   01001111B 
    movwf   TRISB 
    bcf     OPTION_REG, 7 
    movlw   0xff
    movwf   WPUB                     ;movemos para el pull up 
    
    banksel PORTA
    clrf    PORTA 
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
    clrf    PORTB
    movlw   21
    movwf   mandar_contador         ;le damos el valor de 21 desde e principio para que no pase de 20
    movlw   11                      
    movwf   numero_contador         ;le damos el valor de 11 desde el principio para poder cargar unicamente un valor de 10 hasta 20
    
    bcf     PORTB, 6
    bcf     PORTB, 7
    bsf     PORTC, 7
    return

config_reloj:                        ;config del oscilador 250khz
    banksel OSCCON
    bcf     IRCF2 
    bsf     IRCF1 
    bcf     IRCF0
    bsf     SCS 
    return 
 
preparar_displays:                   ;le mandamos a cada variables su resepctivo display
    movf    decena, W 
    call    display
    movwf   display_var1 
    
    movf    unidad, W
    call    display
    movwf   display_var2
    
    movf    decena, W 
    call    display
    movwf   display_var3 
    
    movf    unidad, W
    call    display
    movwf   display_var4
    
    movf    decena, W 
    call    display
    movwf   display_var5 
    
    movf    unidad, W
    call    display
    movwf   display_var6
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
    btfss   STATUS,0        ;las revisamos para seguir restando o si incrementamos para pasarnos las unidades 
    goto    mover_unidades
    incf    decena, F
    goto    conv_decenas 
    
conv_unidades:
    subwf   num_binario,F   ;hacemos la conversion de unidades a bcd para el valor decimal
    btfss   STATUS, 0       ;las revisamos para seguir restando o si regresamos o si seguimos 
    return
    incf    unidad, F
    goto    conv_unidades
    
delay_big:                  ;delay  
    movlw   70 
    movwf   cont+1
    call    delay_small 
    decfsz  cont+1, 1
    goto    $-2
    return

delay_small:                ;delay
    movlw   50
    movwf   cont 
    decfsz  cont, 1 
    goto    $-1
    return

    

  
END 



