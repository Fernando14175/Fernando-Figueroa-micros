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
void dato_char (uint8_t valor);
void hola (void);
void pregunta (void);
void opciones (void);
void ascii_hex (void);
void opcion (void);
void meenu (void);
void ingresar (void);
void error (void);

uint8_t porta;
uint8_t portb;
uint8_t repetir;

int menu = 0;



void __interrupt()isr(void){
    
    if(PIR1bits.RCIF == 1){
        PORTD = RCREG; //yo ingreso el rcreg
        TXREG = RCREG;
        
    }
        
}


void main(void) {
    
    setup();
   
        while(1){
        __delay_ms(500);
        meenu();
        dato_char('\r');      
        
    }   
}

void setup (void){
    ANSEL = 0b00000000;
    ANSELH = 0;
    
    PORTD = 0;
    PORTB = 0;
    PORTA = 0;
    
    TRISA = 0;
    TRISB = 0;
    TRISD = 0;
   
    
 
    OSCCONbits.IRCF = 0b100;  //1 MHz
    OSCCONbits.SCS = 1;       //oscilador interno 
    
    TXSTAbits.SYNC = 0;       //modo asincrono 
    TXSTAbits.BRGH = 1;       //velocidad alta 
    
    BAUDCTLbits.BRG16 = 1;    // 16 bits para el generador de los baudios
    
    SPBRG = 25;               //periodo para el baud rate  (FOSC/baud rate/64 )-1  
    SPBRGH  = 0;              //periodo para el baud rate   (16000000/9600/64)-1 = 25 aproximado
    
    RCSTAbits.SPEN = 1;       //habilitamos los puertos seriales 
    RCSTAbits.RX9 = 0;        //recepcion de 8 bits 
    RCSTAbits.CREN = 1;       //habilitamos el recibidor 
    
    TXSTAbits.TXEN = 1;       //habilitamos la transmision 
    
    PIR1bits.RCIF = 0;        //el buffer que recibe datos esta vacio
    PIE1bits.RCIE = 1;        //habilitamos interrupcion cuando se reciben datos 
    INTCONbits.PEIE = 1;      //interrupciones perifericas 
    INTCONbits.GIE = 1;       //interrupciones globales 
    RCREG = '0';
}

void  dato_char (uint8_t valor)
{
    
    TXREG = valor;                    // Se envia Byte a TXREG
    while (PIR1bits.TXIF == 0){       // Espera a que se haya enviado dato
        
    }     
}

void hola (void){
    dato_char(104);      // caracter s
    dato_char(111);          // caracter 1
    dato_char(108);         // caracter :
    dato_char(97);
    dato_char('\r');      
}

void ascii_hex(void){
    dato_char(67);
    dato_char(97);
    dato_char(114);
    dato_char(97);
    dato_char(99);
    dato_char(116);
    dato_char(101);
    dato_char(114);
    dato_char(32);
    dato_char(58);
    dato_char(32);
    dato_char(48);
    dato_char('\r');      
    dato_char(72);
    dato_char(101);
    dato_char(120);
    dato_char(32);
    dato_char(58);
    dato_char(32);
    dato_char(51);
    dato_char(48);
    dato_char('\r');     
}

void pregunta(void){
    dato_char(81);
    dato_char(117);
    dato_char(101);
    dato_char(32);
    dato_char(97);
    dato_char(99);
    dato_char(99);
    dato_char(105);
    dato_char(111);
    dato_char(110);
    dato_char(32);
    dato_char(100);
    dato_char(101);      
    dato_char(115);
    dato_char(101);
    dato_char(97);
    dato_char(32);
    dato_char(101);
    dato_char(106);
    dato_char(101);
    dato_char(99);
    dato_char(117);
    dato_char(116);     
    dato_char(97);     
    dato_char(114);     
    dato_char(63);
    dato_char('\r');      
    
}

void opciones(void){
    dato_char(49);
    dato_char(41);
    dato_char(32);
    dato_char(67);
    dato_char(97);
    dato_char(114);
    dato_char(97);
    dato_char(99);
    dato_char(116);
    dato_char(101);
    dato_char(114);
    dato_char(101);
    dato_char(115); 
    dato_char('\r');      
    dato_char(50);
    dato_char(41);
    dato_char(32);
    dato_char(80);
    dato_char(111);
    dato_char(114);
    dato_char(116);
    dato_char(32);
    dato_char(65);
    dato_char('\r');      
    dato_char(51);
    dato_char(41);
    dato_char(32);
    dato_char(80);
    dato_char(111);
    dato_char(114);
    dato_char(116);
    dato_char(32);
    dato_char(66);
    dato_char('\r');      
    
}

void meenu (void){
    
    if (RCREG == '0'){
    dato_char('\r');          
    pregunta();
    opciones();
    menu = 0;
    }
    
    if (RCREG == '1' ){
        dato_char('\r');      
        hola();
        RCREG = '0';
    }
    
    if (RCREG == '2'){
        menu = 2;
        dato_char('\r');   
        ingresar();
        dato_char('\r');   
         __delay_ms(500);
        if (menu == 2 && PIR1bits.RCIF == 0){
            PORTA = RCREG;
            RCREG = '0';
        }
    }
    
    if (RCREG == '3'){
        menu = 3;
        dato_char('\r');   
        ingresar();
        dato_char('\r');   
         __delay_ms(500);
        if (menu == 3 && PIR1bits.RCIF == 0){
            PORTB = RCREG;
            RCREG = '0';
        }
    }
    
    if (RCREG == '4'){
        dato_char('\r');   
        ascii_hex();
        RCREG = '0';
        
    }
    
    if(RCREG != '1' && RCREG != '2' && RCREG != '3' && RCREG != '0' && RCREG != '4' && menu == 0){
        dato_char('\r');
        error();
        menu = 0;
        RCREG = '0';
    }
}        
    


void ingresar (void){
    dato_char(73);      
    dato_char(110);
    dato_char(103);
    dato_char(114);
    dato_char(101);
    dato_char(103);
    dato_char(101);
    dato_char(32);
    dato_char(100);
    dato_char(97); 
    dato_char(116);
    dato_char(111); 
}

void error (void){
    dato_char(68);      
    dato_char(97);
    dato_char(116);
    dato_char(111);
    dato_char(32);
    dato_char(105);
    dato_char(110);
    dato_char(99);
    dato_char(111);
    dato_char(114); 
    dato_char(114);
    dato_char(101); 
    dato_char(99); 
    dato_char(116);
    dato_char(111); 
}