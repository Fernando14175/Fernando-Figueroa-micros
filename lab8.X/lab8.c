/*
 * File:   newmain.c
 * Author: Fernando Figueroa
 *
 * Created on January 23, 2021, 12:38 PM
 */


#pragma config FOSC = INTRC_NOCLKOUT
#pragma config WDTE = OFF       
#pragma config PWRTE = OFF      
#pragma config MCLRE =  OFF    
#pragma config CP = OFF         
#pragma config CPD = OFF        
#pragma config BOREN = OFF      
#pragma config IESO = OFF       
#pragma config FCMEN = OFF      
#pragma config LVP = OFF        

// CONFIG2
#pragma config BOR4V = BOR40V   
#pragma config WRT = OFF        

#define _XTAL_FREQ  1000000 //frecuencia
#include <xc.h>             // librerias 
#include <stdio.h>   
#include <stdint.h>
#include <stdbool.h>
#include <pic16f887.h>

void config (void);
void conversion (int puertoANL);
void contador(void);

unsigned int a = 0;
unsigned int b = 0;
unsigned int c = 0;
float d = 0.0;
int puertoANL = 3;
    
 void __interrupt() ISR(void) {
     
     if (PIR1bits.ADIF ==1){ 
        PIR1bits.ADIF = 0;              // interrupcion del ADC que guarda en un registro el valor de la conversion analogica a digital.
        
        a = ADRESH;
        b = ADRESH;
        c = ADRESH;
        d = ADRESH;
    }
        
}

void main(void) {
  
    config();

    while(1){
        conversion(0);
       __delay_ms(1);
       
       conversion(1);
       __delay_ms(1);
       
       conversion(2);
       __delay_ms(1);
       
        conversion(3);
       __delay_ms(1);
       
     }
}

void config (void){
    ANSEL =  0b00001111;
    ANSELH = 0b00000000;

    TRISA = 0b00001111;
    TRISB = 0b00000000;
    TRISC = 0b00000000;
    TRISD = 0b00000000;
    TRISE = 0b000;
    
    
    PORTA = 0b00000000;
    PORTB = 0b00000000;
    PORTD = 0b00000000;
    PORTC = 0b00000000;
    PORTE = 0b000;
   
    OSCCONbits.IRCF2 = 1;
    OSCCONbits.IRCF1 = 0;
    OSCCONbits.IRCF0 = 0;
    
    OSCCONbits.SCS = 1;
     
    ADCON1bits.ADFM = 0;
    
    ADCON1bits.VCFG0 = 0;
    ADCON1bits.VCFG1 = 0;
     
    ADCON0bits.ADCS0 = 1;
    ADCON0bits.ADCS1 = 0;
    
    ADCON0bits.ADON = 1;
    
      // CONFIG PWM
    TRISCbits.TRISC2 = 1;
    TRISCbits.TRISC1 = 1;

    PR2 = 165;

    CCP1CONbits.P1M = 0b000; //unica salida 

    CCP1CONbits.CCP1M = 0b00001100; //modo pwm
    CCP2CONbits.CCP2M = 0b00001100; //modo pwm

    CCPR1L = 0x0f;
    CCPR2L = 0x0f;
    CCP1CONbits.DC1B = 0; //bits significativos 

    PIR1bits.TMR2IF = 0;
    T2CONbits.T2CKPS = 0b11;
    T2CONbits.TMR2ON = 1;
    
    while(!PIR1bits.TMR2IF);
    PIR1bits.TMR2IF = 0;
     
    
    TRISCbits.TRISC2 = 0;
    TRISCbits.TRISC1 = 0;
    
    INTCONbits.GIE = 1;
    INTCONbits.PEIE = 1;
   
    PIE1bits.ADIE = 1;
    PIR1bits.ADIF = 0;
    
}

void conversion(puertoANL){  //funcion conversion la cual hace la conversion del valor del adc a voltaje y identifica para cual puerto es cada valor con un if
    
    ADCON0bits.CHS = puertoANL;  
    
    if (ADCON0bits.GO_DONE==0 && puertoANL == 3){ // bit de conversion e 0 indicando que no ha empezado y puerto analogico en 0 para determinar cual puerto es el que se utiliza 
        
        PORTEbits.RE0 = (d*5.0)/1023.0;
        PORTEbits.RE1 = (d*5.0)/1023.0;
        ADCON0bits.GO_DONE = 1;//le indicamos al adc que empiece la conversion de los numeros 
    }
    
    if (ADCON0bits.GO_DONE==0 && puertoANL == 2){ // bit de conversion e 0 indicando que no ha empezado y puerto analogico en 0 para determinar cual puerto es el que se utiliza 
        
        //PORTDbits.RD0 = (d*5.0)/1023.0;
        //PORTDbits.RD1 = (d*5.0)/1023.0;
        PORTD = c;
        PORTB = c;
        ADCON0bits.GO_DONE = 1;//le indicamos al adc que empiece la conversion de los numeros 
    }
  
    if (ADCON0bits.GO_DONE==0 && puertoANL == 1){ // bit de conversion e 0 indicando que no ha empezado y puerto analogico en 0 para determinar cual puerto es el que se utiliza 
        CCPR1L = (a >>2) +248;
        CCP1CONbits.DC1B0 = ADRESL >> 7;
        ADCON0bits.GO_DONE = 1;//le indicamos al adc que empiece la conversion de los numeros 
    }
    
    if (ADCON0bits.GO_DONE==0 && puertoANL == 0){
        CCPR2L = (b >>2) +248;
        CCP2CONbits.DC2B1 = ADRESL >> 7;
        ADCON0bits.GO_DONE = 1;//le indicamos al adc que empiece la conversion de los numeros 
    }
}    