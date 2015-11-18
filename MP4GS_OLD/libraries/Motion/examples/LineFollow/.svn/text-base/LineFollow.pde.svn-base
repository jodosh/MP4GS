#include <Motion.h>
#include <Wire.h>

Motion move;

// Variables for pin names
const char ledPin    = 13;
//** QTI Line sensors **//
const char leftOut  = 3; 
const char leftIn   = 4;
const char midIn    = 5;
const char rightIn  = 6;
const char rightOut = 7;

void setup() {  
  move.md25_init(0);        // Start MD25 in Mode 0
  move.md25_cmd(32);        // Reset MD25 encoder count
}


void loop() {
  // Follow the line, need to specify pins to which QTI line sensors are connected!
  move.mv_lineFollow(leftOut, leftIn, midIn, rightIn, rightOut);
  // This function will retain control until no line is detected (i.e. all sensors detect white)
}
