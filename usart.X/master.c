
//******************************************************************************
// PIC16F887 Configuration Bit Settings
// 'C' source line config statements
//******************************************************************************

// CONFIG1
#pragma config FOSC = INTRC_NOCLKOUT
#pragma config WDTE = OFF       
#pragma config PWRTE = OFF      
#pragma config MCLRE = OFF      
#pragma config CP = OFF         
#pragma config CPD = OFF        
#pragma config BOREN = OFF      
#pragma config IESO = OFF       
#pragma config FCMEN = OFF      
#pragma config LVP = OFF        

// CONFIG2
#pragma config BOR4V = BOR40V   
#pragma config WRT = OFF        

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

//******************************************************************************
// Includes
//******************************************************************************

#include <xc.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>  
#include <stdbool.h>
#include "USART.h"

//******************************************************************************
// Defines
//******************************************************************************

#define _XTAL_FREQ 4000000

bool    eusart_flag  = false;
uint8_t uart_data = 0;
uint8_t uart_cont = 0;
uint8_t str_pos   = 0;


void setup(void);

void main(void)
{
    setup();
    while(1) 
    {
       
        uart_data = 0;

    }
}

void __interrupt() isr(void)
{

    if (PIE1bits.TXIE && PIR1bits.TXIF)
    {
        if (eusart_flag)
        {
            TXREG = "hola"[str_pos];
        }
        else
        {
            TXREG = "adios"[str_pos];
        }
        str_pos++;

        if (str_pos == 5)
        {
            eusart_flag = !eusart_flag;
            str_pos = 0;
        }
    }

    if (PIR1bits.RCIF)
    {
        uart_data = RCREG;
    }
}

void setup(void)
{
    ANSEL  = 0x03;
    ANSELH = 0x00;
    TRISC = 0x80;
    PORTC = 0;
    
    eusart_init_tx();
    eusart_enable_tx_isr();

    eusart_init_rx();
    eusart_enable_rx_isr();

   
    INTCONbits.GIE = 1;//INTERRUPCIONES GLOBALES
    PIE1bits.ADIE = 0;
    PIE1bits.ADIE = 1;// interrupciones del ADC
    
    
    return;
}
