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
#define _XTAL_FREQ  9000000 //frecuencia

void config (void);
void conversion (char puertoANL);
void contador(void);
unsigned char Display[]={0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F};

unsigned int a = 0;
unsigned int b = 0;
unsigned int c = 0;
unsigned int d = 0;
unsigned int led = 0;

    
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
     }
}

void config (void){
    ANSEL =  0b00000000;
    ANSELH = 0b00000000;

    TRISA = 0b00000011;
    TRISB = 0b00000000;
    TRISC = 0b00000000;
    TRISD = 0b00000000;
    TRISE = 0b000;
    
    
   
    PORTD = 0b00000000;
    PORTC = 0b00000000;
    PORTE = 0b000;
    
    INTCONbits.GIE = 1;
    INTCONbits.PEIE = 1;
    INTCONbits.INTE = 1;
    
    ADCON0bits.ADCS0 = 1;
    ADCON0bits.ADCS1 = 0;
    
    ADCON0bits.ADON = 1;   // adc on
    ADCON1bits.ADFM = 0;
    
    PIE1bits.ADIE = 1;
    PIR1bits.ADIF = 0;
    
}

void conversion(char puertoANL){  //funcion conversion la cual hace la conversion del valor del adc a voltaje y identifica para cual puerto es cada valor con un if
    
    ADCON0bits.CHS = puertoANL;   
    if (ADCON0bits.GO_DONE==0 && puertoANL == 0){ // bit de conversion e 0 indicando que no ha empezado y puerto analogico en 0 para determinar cual puerto es el que se utiliza 
        
        a = ((a/100)%10);
        b = ((b/10)%10);  // holds 10th digit a = 2  
        c = (c%10); //b = 12 
         // holds unit digit value
         PORTC  = Display[a];
         PORTEbits.RE2 = 1;   
         __delay_ms(5);
         PORTEbits.RE2 = 0;  
         PORTC = Display[b]; //le decimos a la variable display que posicion de digito debe agarrar con la variable a
         PORTEbits.RE0 = 1;   
         __delay_ms(5);
         PORTEbits.RE0 = 0;   
         PORTC=Display[c];  //le decimos a la variable display que posicion de digito debe agarrar con la variable b
         PORTEbits.RE1 = 1; 
         __delay_ms(5);
         PORTEbits.RE1 = 0; 
         ADCON0bits.GO_DONE = 1;//le indicamos al adc que empiece la conversion de los numeros 
    }
    else{
        PORTD = d;
        ADCON0bits.GO_DONE = 1;//le indicamos al adc que empiece la conversion de los numeros 
    }
}    