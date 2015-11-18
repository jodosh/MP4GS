#include <Arm.h>
#include <Servo.h>    // It is necessary to include this file in your sketch because libraries use it!
  
const char jointPin   =  9;
const char basePin    = 10;
const char levelPin   = 11;
const char gripperPin = 12;
const char servoPwr1  = 22;
const char servoPwr2  = 24;
 
// Initialize an instance of Arm library
// Pins to which each servo is connected must be 
// provided in the appropriate order!
Arm arm(jointPin, basePin, levelPin, gripperPin, servoPwr1, servoPwr2); 

const char ledPin = 13;

void setup() 
{ 
  Serial.begin(115200);  //Use serial communication to control
  pinMode(ledPin, OUTPUT);
}

void loop(){
  establish_contact();
// Power servos on and unfold the arm
  arm.unfold();
  Serial.print("Arm unfolded! ");
  establish_contact();
  
// Extend the arm about 5 inches in front of the normal position
  arm.extend();
  Serial.print("Arm extended! ");
  establish_contact();
 
// Retract the arm to normal position in front of robot
  arm.retract();
  Serial.print("Arm back to normal! ");
  establish_contact();
  
// Fold the arm back onto top of the platform and power servos off
  arm.fold();
  Serial.print("Arm folded! ");
}

void establish_contact() {
  Serial.println("Waiting... ");
  while (Serial.available() <= 0) {
  // Flash the LED while we wait for an input to continue  
    digitalWrite(ledPin, HIGH);
    delay(150);
    digitalWrite(ledPin,LOW);
    delay(150);
  }
}
