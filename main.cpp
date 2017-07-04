
#include "Arduino.h"

int main() {

    pinMode(13,OUTPUT);


    for(;;) {
        digitalWrite(13,HIGH);
        _delay_ms(1000);
        digitalWrite(13,LOW);
        _delay_ms(1000);
    }
}