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
    BSF	STATUS, 5 
    BSF STATUS, 6
    CLRF ANSEL
    CLRF ANSELH
    
    BCF  STATUS,6
    BSF  STATUS,5 
    
    BCF  TRISD, 0
    BCF  TRISD, 1
    BCF  TRISD, 2 
    BCF  TRISD, 3
    
    BCF  TRISB, 0
    BCF  TRISB, 1
    BCF  TRISB, 2 
    BCF  TRISB, 3
    BCF  TRISB, 4
    BCF  TRISB, 5
    BCF  TRISB, 6 
    BCF  TRISB, 7
    
    BCF  TRISC, 0
    BCF  TRISC, 1
    BCF  TRISC, 2 
    BCF  TRISC, 3
    
    BCF  TRISA, 0
    BSF  TRISA, 2
    BSF  TRISA, 3
    
    BSF  TRISE, 0
    BSF  TRISE, 1
   
    BCF  STATUS,6 
    BCF  STATUS,5 
    
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC
    CLRF PORTD
    BCF  PORTA,0
    
    
    CLRF contarriba
    CLRF contabajo
;-----------Main-----------------
    
main:
    call presionar_arriba1
    call presionar_abajo1
    call presionar_arriba2
    call presionar_abajo2
    call presionar_suma 
    call carry
    goto main   

;-----------Primer contador-----------------
presionar_arriba1: 
    btfss PORTE, 0  ;esta el bit 0 de E presionado?
    return
    call anti_rebote_Arriba1 
    return
    
presionar_abajo1:
    btfss PORTE, 1  ;esta el bit 1 de E presionado?
    return 
    call anti_rebote_Abajo1
    return
    
anti_rebote_Arriba1:
    btfsc PORTE, 0
    goto anti_rebote_Arriba1
    call aumentar1
    return

anti_rebote_Abajo1:
    btfsc PORTE, 1
    goto anti_rebote_Abajo1
    call disminuir1
    return
   
aumentar1:
    INCF PORTB, 1
    return

disminuir1:
    DECF PORTB, 1
    return
    
;-----------Segundo contador-----------------
presionar_arriba2: 
    btfss PORTA, 2  ;esta el bit 0 de E presionado?
    return
    call anti_rebote_Arriba2
    return
    
presionar_abajo2:
    btfss PORTA, 3  ;esta el bit 1 de E presionado?
    return 
    call anti_rebote_Abajo2
    return
    
anti_rebote_Arriba2:
    btfsc PORTA, 2
    goto anti_rebote_Arriba2
    call aumentar2
    return

anti_rebote_Abajo2:
    btfsc PORTA, 3
    goto anti_rebote_Abajo2
    call disminuir2
    return
   
aumentar2:
    INCF PORTD, 1
    return

disminuir2:
    DECF PORTD, 1
    return
    
;-----------Suma--------------- 

presionar_suma: 
    btfss PORTE, 2  ;esta el bit 0 de E presionado?
    return
    call anti_rebote_suma 
    return
    
anti_rebote_suma:
    btfsc PORTE, 2
    goto anti_rebote_suma
    call sumar
    return
    
sumar:
    movf PORTB,w
    addwf PORTD,w
    movwf PORTC
    return
    
;-----------Acarreo-----------------
carry:
    
    btfss STATUS, 1
    return
    bsf PORTA, 0
    clrf PORTC
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

    
   


    



