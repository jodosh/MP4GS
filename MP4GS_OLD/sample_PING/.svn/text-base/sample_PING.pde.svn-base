#include <Wire.h>

#define MD25 0x58


unsigned long PING_distance;
const char pingPin =  8;
const char ledPin  = 13;
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
  useconds = pulseIn(pingPin, HIGH, 1000);
  
  // convert the time (usec) into a distance in mm
  if (unit == 'mm') {
    return useconds / 2 * 10 / 29;
  }
  else if (unit == 'in') {
    return useconds / 74 / 2;
  }
  else return useconds / 2 * 10 / 29;
}

void setup() {
 Serial.begin(9600); 
}

void loop() {
  PING_distance = get_PING('mm');
  Serial.print(PING_distance);
  Serial.print("mm");
  Serial.println();
  
  delay(500);
}
