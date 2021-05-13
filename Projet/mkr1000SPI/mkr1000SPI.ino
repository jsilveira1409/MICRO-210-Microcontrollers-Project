#include "pins_arduino.h"
#include "SPI.h"

char buf [100];
volatile byte pos;
volatile boolean process_it;
byte c = SPDR;

void setup (void)
{
  Serial.begin (9600);   // debugging
  // have to send on master in, *slave out*
  pinMode(MISO, OUTPUT);
  // turn on SPI in slave mode
  SPCR |= _BV(SPE);
  // turn on interrupts
  SPCR |= _BV(SPIE);
  pos = 0;
  process_it = false;
}  // end of setup


// SPI interrupt routine
}

// main loop - wait for flag set in interrupt routine
void loop (void){
    if (pos < sizeof buf){
    buf [pos++] = c;
    
    // example: newline means time to process buffer
    if (c == '\n')
      process_it = true;
      
    }  // end of room available

    buf [pos] = 0;  
    Serial.println (buf);
    pos = 0;
    process_it = false;
    }  // end of flag set
    
}
