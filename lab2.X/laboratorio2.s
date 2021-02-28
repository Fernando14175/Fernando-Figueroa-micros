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
  
  
    


    
PSECT code, delta = 2, abs 
 ORG 100h 
 
    
SETUP:  
    BSF	STATUS, 5 ;entramos al banco para poder entrar el registro ansel y poder limpiarlo
    BSF STATUS, 6
    CLRF ANSEL    ;entradas digitales
    CLRF ANSELH   ;entradas digitales 
    
    BCF  STATUS,6 ;nos cambiamos de banco
    BSF  STATUS,5 
   
    BCF TRISB,0 //salidas y entras puerto b
    BCF TRISB,1
    BCF TRISB,2
    BCF TRISB,3
    
    BCF TRISC,0 //salidas y entras puerto c
    BCF TRISC,1
    BCF TRISC,2
    BCF TRISC,3
    
    
    BCF TRISE,0 //salidas y entras puerto e
    
    BSF TRISA,0
    BSF TRISA,1
    
    BCF  STATUS,6 ;nos cambiamos de banco
    BCF  STATUS,5 
    
    clrf PORTB //limpiamos puertob
    clrf PORTC //limpiamos puerto c 
    bcf  PORTE,0 //limpiamos RE0
   
;-----------Main-----------------
    
main:
      
      call comparar	    //llamamos la rutina comparar
      call frecuencia	    //llamamos la funcion frecuencia
      call timer0	    //llamamos la funcion timer0
      call presionar_arriba //llamamos la funcion presionar arriba
      call presionar_abajo  //llamamos la funcion presionar abajo
      btfss T0IF            //llamamos la funcion T0IF
      goto  $-1
      call  empezar         //llamamos la funcion empezar
      incf  PORTB           //incrementamos el puertob
      call  comparar        //llamamos la funcion comparar
      bcf  PORTE,0 //limpiamos el puerto RE0
      goto main             //vamos al main
       

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
    INCF contarriba,1           ;aumentamos el contador 
    MOVF contarriba, w          ;movemos al registro w
    call display                ;llamamos a la funcion display
    MOVWF PORTC                 ;movemos el valor del display al puerto c
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
    call bajar1                ;llamamos a la rutina 
    return
bajar1:
    DECF contarriba,1          ;disminuimos el contador  
    MOVF contarriba, w         ;movemos al registro w
    call display               ;llamamos a la funcion display
    MOVWF PORTC                ;movemos el valor del display al puerto c
    return
    
;--------------------Tabla----------------------

display:
   CLRF  PCLATH              ;limpiamos el registro
   bsf   PCLATH, 0           ;ponemos en 1 el bit 0 del registro
   ADDWF PCL                 ;sumamos 1 al pcl para poder determinar que sale ne l display
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
 comparar:
    MOVF   PORTB, W  //movemos el valor de puertob a w
    XORWF  PORTC, W  //comparamos si son iguales
    BTFSS  STATUS, 2 //revisamos que queda en el bit 2 del registro status para saber si son iguales
    return
    bsf PORTE,0	     //ponemos el puerto e en 1
    call DELAY       //llamamos al delay
    clrf PORTB       //limpiamos el puerto b
    return
   
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

    


