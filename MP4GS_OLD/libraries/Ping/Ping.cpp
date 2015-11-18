/*
  Ping.cpp - Library for PING object detection sensors
  Author: Alvaro Aguilar
  Date: Feb. 21, 2011
*/

#include "Ping.h"
#include "WProgram.h"
#include <pins_arduino.h>

Ping::Ping(char pin)
{
  _pingPin = pin;
}

unsigned long Ping::get_PING(uint8_t unit)
{
  unsigned long useconds;
  
  // The PING))) is triggered by a HIGH pulse of 2 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:	
  pinMode(_pingPin, OUTPUT);
  digitalWrite(_pingPin, LOW);
  delayMicroseconds(2);
  digitalWrite(_pingPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(_pingPin, LOW);
  
  // The same pin is used to read the signal from the PING))): a HIGH
  // pulse whose duration is the time (in microseconds) from the sending
  // of the ping to the reception of its echo off of an object.
  pinMode(_pingPin, INPUT);
  useconds = pulseIn(_pingPin, HIGH, 800, 6000);
  if (useconds == 0 & useconds == 5000) {
    return useconds;
  }
  // convert the tim (usec) into a distance in mm
  switch (unit) {
    case mm : 
      return useconds / 2 * 10 / 29;
      break;
    case in : 
      return useconds / 74 / 2;
      break;
    default : 
      return useconds / 2 * 10 / 29;
      break;
  }
}

// Private Methods /////////////////////////////////////////////////////////////

unsigned long Ping::pulseIn(uint8_t pin, uint8_t state, unsigned long timeout, unsigned long timeoutstop)
{
	uint8_t bit = digitalPinToBitMask(pin);
	uint8_t port = digitalPinToPort(pin);
	uint8_t stateMask = (state ? bit : 0);
	unsigned long width = 0;

	unsigned long numloops = 0;
	unsigned long maxloops = microsecondsToClockCycles(timeout) / 16;
	unsigned long maxloopsstop = microsecondsToClockCycles(timeoutstop) / 16 ;

	// wait for any previous pulse to end
	while ((*portInputRegister(port) & bit) == stateMask)
		if (numloops++ == maxloops)
			return 0;

	// wait for the pulse to start
	while ((*portInputRegister(port) & bit) != stateMask)
		if (numloops++ == maxloops)
			return 0;

	// wait for the pulse to stop
	while ((*portInputRegister(port) & bit) == stateMask)
                if (width++ == maxloopsstop)
                        return 5000 ;

	return clockCyclesToMicroseconds(width * 20 + 16);
}