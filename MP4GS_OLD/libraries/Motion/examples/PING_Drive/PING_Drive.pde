#include <Motion.h> 
#include <Ping.h>
#include <Arm.h>

#include <Wire.h>           // It is necessary to include this
#include <Servo.h>          // file in your sketch because libraries use it!

// Variables used for robot motion
boolean obj_found, obj_reached;
unsigned long PING_dist, PING_dist_new;
// Variables for pin names
const char ledPin    = 13;
//** Arm Servo pin variables
const char jointPin   =  9;
const char basePin    = 10;
const char levelPin   = 11;
const char gripperPin = 12;
const char servoPwr1  = 22;
const char servoPwr2  = 24;


Motion move;
Ping basePING(28);              // Attach PING to Arduino pin 28
Ping armPING(30);
Arm arm(jointPin, basePin, levelPin, gripperPin, servoPwr1, servoPwr2);

void setup() {
  Serial.begin(115200);
  Wire.begin();
  move.md25_init(0);        // Start MD25 in Mode 0
  move.md25_cmd(32);        // Reset MD25 encoder count
  pinMode(ledPin, OUTPUT);  // Turn the LED pin into an output
}

void loop() {
  PING_dist = basePING.get_PING(mm);          // Get the distance in mm
  while (PING_dist == 5000) {                 // This means the Pulse never returned to Arduino (i.e. object is out of range)
    move.mv_right(3600);                      // Turn 360 degrees, keep doing until not equal to 5000
    PING_dist = basePING.get_PING(mm); 
  }
  if (PING_dist > 300) {
    move.mv_forw((PING_dist - 280), SLOW);     // Approach object
    obj_found = 1;
  }
  
  obj_reached = 0;
  while (!obj_reached) {
    move.get_encoders();
    if (move.compare_encoders(forw)) {        // Possible modes for this functions are: 'forw', 'back', 'left' and 'right'
      move.mv_stop();                         // Stop the motors if we reached desired distance
      obj_reached = 1;
    }
    PING_dist = basePING.get_PING(mm);
    if (PING_dist < 280 && !obj_reached) {
      move.mv_stop();                        // Stop the motors if PING sensor reads anything closer to 28cm (280mm)
      obj_reached = 1;
    }
  }
  
  arm.unfold();
  delay(2500);             // Assure arm is finished!
  PING_dist = armPING.get_PING(mm);
  if (PING_dist > 40) {
    move.mv_forw((PING_dist - 15), SLOW);
  }
  obj_reached = 0;
  while (!obj_reached) {
    move.get_encoders();
    if (move.compare_encoders(forw)) {
      move.mv_stop();
      Serial.println("Encoders found it");
      obj_reached = 1;
    }
    PING_dist = armPING.get_PING(mm);
    if (PING_dist < 40 && !obj_reached) {
      move.mv_stop();
      Serial.println("PING found it");
      obj_reached = 1;
    }
  }
  arm.mv_grip(1950);
  arm.lift();
  arm.lower();
  arm.mv_grip(1650);
  move.mv_back(100, SLOW);
  obj_reached = 0;
  while (!obj_reached) {
    move.get_encoders();
    if (move.compare_encoders(back)) {
      move.mv_stop();
      obj_reached = 1;
    }
  }
  delay(2000);
  arm.fold();
 
  while (true) {
    blinkLED(ledPin);            // Blink the LED when we are close to the object (28 cm away!)
  }
  
}  // end LOOP() function

void blinkLED(char _ledPin) {
  pinMode(_ledPin, OUTPUT);
  digitalWrite(_ledPin, HIGH);
  delay(500);
  digitalWrite(_ledPin, LOW);
  delay(500);
}
