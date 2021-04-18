//configuracion del programa 
// CONFIG1
#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits (RCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, RC on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = OFF        // Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Progra
// #pragma config statements should precede project file inludes.
// Use project enums instead of #define for ON and OFF.

#include <xc.h>
#include <stdint.h>
#include "PIC16F887.h"
#define _XTAL_FREQ 8000000
#define _tmr0_value 250
    
void config (void);
void contador (void);
void multiplex (void);
void reset     (void);

int  estado1 = 0;
int  estado2 = 0;
int  x;
int  unidades = 0;
int  decenas = 0;
int  centenas = 0;
unsigned char Display[]={0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F};

void __interrupt()ISR(void){
    
    if (INTCONbits.T0IF){
        
        PORTD++;
        multiplex();
        T0IF = 0;
        TMR0 = _tmr0_value;      
    }
}

void main(void) {
    config();
    while(1){
            if( unidades >9){
            unidades = 0; // Reinicia unidades
            decenas++; //Incrementa decenas
            }
            if (unidades < 0){
            unidades = 9;
            decenas--;
            }
            
            if ( decenas >9){
            decenas = 0; //Reinicia decenas
            centenas++;
            }
             if ( decenas <0)     {
            decenas = 9; //Reinicia decenas
            centenas--;
             }
            if ( centenas >9)   {
            centenas = 0; //Reinicia centenas
            }
             if ( centenas <0)   {
            centenas = 9; //Reinicia centenas
             }
            
           
            
        contador();
        reset(); 
                
    }
}

void config(void){
    
     ANSELH = 0b0000000; //ponemos los puertos como digitales
     ANSEL =  0b0000000; //ponemos los puertos como digitales
     
     TRISA = 0b00000000;
     TRISB = 0b00000011;
     TRISD = 0b00000000;
     TRISC = 0b00000000;
     TRISE = 0B000;
     
     PORTB = 0b00000000; //ponemos los puertos en 0 
     PORTA = 0b00000000; //ponemos los puertos en 0 
     PORTD = 0b00000000;
     PORTC = 0b00000000;
     PORTE = 0b000;
         
     OSCCONbits.IRCF2 = 0;
     OSCCONbits.IRCF1 = 1;
     OSCCONbits.IRCF0 = 0;
     OSCCONbits.SCS = 1;
     
     OPTION_REGbits.T0CS = 0;
     OPTION_REGbits.PSA = 0;
     OPTION_REGbits.PS2 = 1;
     OPTION_REGbits.PS1 = 1;
     OPTION_REGbits.PS0 = 0;
     TMR0  = _tmr0_value;
     
     INTCONbits.T0IF = 0;
     INTCONbits.T0IE = 1;
     INTCONbits.GIE  = 1;
     return;
}

void contador(void){
    
     if (PORTBbits.RB0 == 0){
         estado1 = 1;
     }
     if (PORTBbits.RB0 == 1 && estado1 == 1){ 
         PORTA++; 
         unidades++;
         estado1 = 0;
        }
     if (PORTBbits.RB1 == 0){
         estado2 = 1;
     }
     if (PORTBbits.RB1 == 1 && estado2 == 1){ 
         PORTA--; 
         unidades--;
         estado2 = 0;
        }

}

void multiplex (void){
        PORTC = Display[ unidades] ; //Envia unidades
        PORTEbits.RE2 =1 ;
        __delay_ms(1);
        PORTEbits.RE2 =0 ;
        PORTC = Display[ decenas ] ; //Envia decenas
        PORTEbits.RE1 =1 ;
        __delay_ms(1);
        PORTEbits.RE1 =0 ;
        PORTC = Display[ centenas ] ; //Envia decenas
        PORTEbits.RE0 =1 ;
        __delay_ms(1);
        PORTEbits.RE0 =0 ;
}

void reset (void){
    if ((unidades > 5) && (decenas == 5) && (centenas == 2)){
            unidades = 0;
            decenas = 0;
            centenas = 0;
        }
    
     if ((unidades < 0) && (decenas == 0) && (centenas == 0)){
            unidades = 5;
            decenas = 5;
            centenas = 2;
        }
}