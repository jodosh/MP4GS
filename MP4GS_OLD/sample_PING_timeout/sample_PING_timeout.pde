#include <pins_arduino.h>

unsigned long PING_distance;
const char pingPin =  8;
const char ledPin  = 13;
const char mm = 1, in = 2;
char obj_found;

unsigned long get_PING(char unit) {
  long useconds;
  
  // The PING))) is triggered by a HIGH pulse of 2 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
  pinMode(pingPin, OUTPUT);
  digitalWrite(pingPin, LOW);
  delayMicroseconds(2);
  digitalWrite(pingPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(pingPin, LOW);
  
  // The same pin is used to read the signal from the PING))): a HIGH
  // pulse whose duration is the time (in microseconds) from the sending
  // of the ping to the reception of its echo off of an object.
  pinMode(pingPin, INPUT);
  useconds = pulseIn(pingPin, HIGH, 800, 4500);
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

void setup() {
 Serial.begin(9600); 
}

void loop() {
  PING_distance = get_PING(mm);
  Serial.print(PING_distance);
  Serial.print("mm");
  Serial.println();
  
  delay(500);
}

unsigned long pulseIn(uint8_t pin, uint8_t state, unsigned long timeout, unsigned long timeoutstop)
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

	return clockCyclesToMicroseconds(width * 16 + 16);
} 

