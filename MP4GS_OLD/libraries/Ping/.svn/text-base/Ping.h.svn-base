/*
  Ping.h - Library for PING object detection sensors
  Author: Alvaro Aguilar
  Date: Feb. 21, 2011
*/

#ifndef Ping_h
#define Ping_h

#include "WProgram.h"

#define mm 0x00
#define in 0x01

class Ping
{
  public:
    Ping(char pin);
    unsigned long get_PING(uint8_t unit);
  private:
    uint8_t _pingPin;
    unsigned long pulseIn(uint8_t pin, uint8_t state, unsigned long timeout, unsigned long timeoutstop);
};

#endif
