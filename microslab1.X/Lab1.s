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
    
    BCF  TRISD, 0 ;ponemos los 4 pines de b como salida
    BCF  TRISD, 1
    BCF  TRISD, 2 
    BCF  TRISD, 3
    
    BCF  TRISB, 0 ;ponemos todos los pines de b como salida
    BCF  TRISB, 1
    BCF  TRISB, 2 
    BCF  TRISB, 3
    BCF  TRISB, 4
    BCF  TRISB, 5
    BCF  TRISB, 6 
    BCF  TRISB, 7
    
    BCF  TRISC, 0 ;ponemos los 4 pines de c como salida 
    BCF  TRISC, 1
    BCF  TRISC, 2 
    BCF  TRISC, 3
    
    BCF  TRISA, 0 ;ponemos el puerto RA0 como una salida 
    BSF  TRISA, 2 ;ponemos puerto RA2 y RA3 del PORTA como una entrada 
    BSF  TRISA, 3  
    
    BSF  TRISE, 0 ;ponemos el puerto RE0 y RE1 como entrada 
    BSF  TRISE, 1
   
    BCF  STATUS,6 ;nos cambiamos de banco
    BCF  STATUS,5 
    
    CLRF PORTA ;limpiamos el puretoA
    CLRF PORTB ;limpiamos el puertoB
    CLRF PORTC ;limpipamos el puertoc
    CLRF PORTD ;limpiamos el puertod
    BCF  PORTA,0 ;ponemos el RA0 en 0
;-----------Main-----------------
    
main: ;declaramos el main
    call presionar_arriba1 ;llamamos todas las rutinas y rehresamos debido al call
    call presionar_abajo1
    call presionar_arriba2
    call presionar_abajo2
    call presionar_suma 
    call carry
    goto main ;regresamos al main 

;-----------Primer contador-----------------
presionar_arriba1: 
    btfss PORTE, 0		;revisamos si esta presionado el boton
    return			;regresamos a donde llamamos la rutina
    call anti_rebote_Arriba1	;llamamos a la siguiente rutina  
    return			;regresamos a donde llamamos a la rutina
    
presionar_abajo1:
    btfss PORTE, 1		;revisamos si esta presionado el boton
    return			;regresamos
    call anti_rebote_Abajo1	;llamamos la rutina 
    return			;regresamos 
    
anti_rebote_Arriba1:
    btfsc PORTE, 0              ;revisamos que el boton ya no este presionado
    goto anti_rebote_Arriba1    ;nos movemos a la rutina 
    call aumentar1              ;llamamos a la rutina 
    return

anti_rebote_Abajo1:             
    btfsc PORTE, 1              ;revisamos que el boton ya no este presionado
    goto anti_rebote_Abajo1     ;nos movemos a la rutina 
    call disminuir1             ;llamamos a la rutina 
    return
   
aumentar1:
    INCF PORTB, 1               ;incrementamos el puerto b en 1
    return

disminuir1:
    DECF PORTB, 1               ;disminuimos el puerto b en 1 
    return
    
;-----------Segundo contador-----------------
presionar_arriba2: 
    btfss PORTA, 2              ;revisamos si esta presionado el boton
    return                      ;regresamos a donde llamamos la rutina
    call anti_rebote_Arriba2    ;llamamos a la siguiente rutina  
    return                      ;regresamos a donde llamamos a la rutina
    
presionar_abajo2:
    btfss PORTA, 3              ;revisamos si esta presionado el boton
    return 
    call anti_rebote_Abajo2     ;llamamos a la siguiente rutina  
    return
    
anti_rebote_Arriba2:
    btfsc PORTA, 2              ;revisamos que el boton ya no este presionado
    goto anti_rebote_Arriba2    ;nos movemos a la rutina 
    call aumentar2              ;llamamos a la siguiente rutina  
    return

anti_rebote_Abajo2:
    btfsc PORTA, 3              ;revisamos que el boton ya no este presionado
    goto anti_rebote_Abajo2     ;nos movemos a la rutina 
    call disminuir2             ;llamamos a la siguiente rutina  
    return
   
aumentar2: 
    INCF PORTD, 1               ;incrementamos el puerto D
    return

disminuir2:
    DECF PORTD, 1               ;disminuimos el puerto D 
    return
    
;-----------Suma--------------- 

presionar_suma: 
    btfss PORTE, 2		;revisamos que el puerto RE2 este presionado 
    return
    call anti_rebote_suma	;llamamos a la rutina 
    return
    
anti_rebote_suma:
    btfsc PORTE, 2              ;revisamos que ya se haya soltado el boton
    goto anti_rebote_suma       ;nos movemos a la rutina 
    call sumar                  ;llamamos a la rutina
    return
    
sumar: 
    movf PORTB,w                ;movemos el valor del puertob al registro w 
    addwf PORTD,w		;sumamos el puertod con el valor de w que y lo salvamos en w otra ves 
    movwf PORTC                 ;movemos el resultado de w al puertoc para poder desplegarlo en el pic
    return
    
;-----------Acarreo-----------------
carry:
    
    btfss STATUS, 1             ;revisamos que el bit de carry del registro status que se prende luego de sumar 
    return
    bsf PORTA, 0                ;seteamos el puertoRA0 en 1 para encender el led de carry
    clrf PORTC                  ;limpiamos el peurto c porque se paso de 15 que es valor maximo de nuestro contador
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

    
   


    



