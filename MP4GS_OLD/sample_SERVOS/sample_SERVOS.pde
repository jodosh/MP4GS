#include <Servo.h>

Servo BASE;
Servo JOINT;
Servo LEVEL;
Servo GRIPPER;

const char jointPin   =  9;
const char basePin    = 10;
const char levelPin   = 11;
const char gripperPin = 12;
const char ledPin     = 13;
unsigned int i;

// Moves the arm to a known position in front of robot
// and delays for 15 seconds to allow it to happen
void init_arm() {
  i = 2130;
  BASE.writeMicroseconds(1150);
  LEVEL.writeMicroseconds(1990);
  GRIPPER.writeMicroseconds(1800);
  while (i >= 1550) { 
    JOINT.writeMicroseconds(i);
    delay(10);                    // Takes 10.3 seconds
    i--;
  }
  delay(4700);                    // Wait for 15 seconds in total  
}

void extend_arm() {
  BASE.writeMicroseconds(1000);
  i = 1550;
  while (i >= 875) {
    digitalWrite(ledPin, HIGH);
    JOINT.writeMicroseconds(i);
    delay(5);                  // Takes 3.87 seconds
    i--;
  }
  LEVEL.writeMicroseconds(1300);
  GRIPPER.writeMicroseconds(1800);
  digitalWrite(ledPin, LOW);
} 
  

// Returns the arm to the folded position on top of the 
// robot. Adds a 20 second delay to allow it to happen
void fold_arm() {
  BASE.writeMicroseconds(1450);
  LEVEL.writeMicroseconds(1990);
  GRIPPER.writeMicroseconds(2070);
  delay(13000);                    // Wait 13 seconds before JOINT movement
  JOINT.writeMicroseconds(2090);
  delay (500);
  JOINT.writeMicroseconds(2110);
  delay(500);
  JOINT.writeMicroseconds(2130);
}


void setup() {
  delay(1000);
  BASE.attach(basePin, 950, 1465);
  JOINT.attach(jointPin, 875, 2130);
  LEVEL.attach(levelPin, 1300, 1990);
  GRIPPER.attach(gripperPin, 1600, 2070);
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);
  init_arm();
  Serial.begin(115200);
  Serial.print(JOINT.read(), DEC);
  delay(5000);                  // wait 5 seconds before extending
//  extend_arm();
}

void loop() {
/*  init_arm();
  GRIPPER.writeMicroseconds(2050);
  delay(5000);                    // Wait for 5 seconds with gripper closed
  GRIPPER.writeMicroseconds(1700);
  delay(5000);
  fold_arm(); */
}
  
  
