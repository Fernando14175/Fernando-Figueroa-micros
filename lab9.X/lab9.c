/*
 * File:   newmain.c
 * Author: Fernando Figueroa
 *
 * Created on January 23, 2021, 12:38 PM
 */

//configuracion del programa 
#pragma config FOSC =INTRC_NOCLKOUT// Oscillator Selection bits (EC: I/O function on RA6/OSC2/CLKOUT pin, CLKIN on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = OFF        // Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)
// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.




#include <xc.h>
#include "PIC16F887.h"
#include <stdint.h>
#include <string.h>            
#include <stdio.h> 
#define _XTAL_FREQ  8000000 //frecuencia


void setup (void);
void conversion2 (char puertoANL);

unsigned int a = 0;
unsigned int b = 0;

void __interrupt()isr(void){
    
    if(PIR1bits.ADIF){
        a = ADRESH;
        b = ADRESH;
        
        PIR1bits.ADIF = 0;
    }
        
}


void main(void) {
    
    setup();
   
    while(1){
         conversion2(2);
       __delay_ms(1);
        conversion2(3);
       __delay_ms(1);
   
            
    }
    
}

void setup (void){
    ANSEL = 0b00001100;
    ANSELH = 0;
    
    TRISA = 0b00001100;
    TRISB = 0;
    TRISC = 0;
    
    //OPTION_REGbits.nRBPU = 0;
    //WPUB = 0b0011;
    
    PORTA = 0;
    PORTB = 0;
    PORTC = 0;
    
    OSCCONbits.IRCF = 0b0111;
    OSCCONbits.SCS = 1;
    
    ADCON1bits.ADFM = 0; //just izquierda 
    ADCON1bits.VCFG0 = 0;// vss vdd 
    ADCON1bits.VCFG0 = 0;// vss vdd 
    
    ADCON0bits.ADCS = 0b10;
    
    __delay_us(25);
    ADCON0bits.ADON = 1;
    
    // CONFIG PWM
    TRISCbits.TRISC2 = 1;
    TRISCbits.TRISC1 = 1;

    PR2 = 249;

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
    //interrupciones 
    PIR1bits.ADIF = 0;
    PIE1bits.ADIE = 1;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
    
    return;
}

void conversion2(char puertoANL){  //funcion conversion la cual hace la conversion del valor del adc a voltaje y identifica para cual puerto es cada valor con un if
    
    ADCON0bits.CHS = puertoANL;   
    if (ADCON0bits.GO_DONE==0 && puertoANL == 2){ // bit de conversion e 0 indicando que no ha empezado y puerto analogico en 0 para determinar cual puerto es el que se utiliza 
        CCPR1L = (prueba >>1) +128;
        //CCP1CONbits.DC1B0 = ADRESL >> 7;
        ADCON0bits.GO_DONE = 1;//le indicamos al adc que empiece la conversion de los numeros 
    }
    
    else{
        CCPR2L = (prueba >>1) +128;
        //CCP2CONbits.DC2B1 = ADRESL >> 7;
        ADCON0bits.GO_DONE = 1;//le indicamos al adc que empiece la conversion de los numeros 
    }
}    