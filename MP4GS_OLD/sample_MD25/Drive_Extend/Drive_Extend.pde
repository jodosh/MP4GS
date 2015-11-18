#include <Servo.h> 
 
// I2C communication requires pins A5(SCL) and A4(SDA)
#include <Wire.h>

#define MD25 0x58
#define FAST 0x01
#define NORM 0x02
#define SLOW 0x03

// Variables for the compare encoders function
const char forw = 1;
const char back = 2;
const char right = 3;
const char left = 4;

char obj_found, obj_reached;
long enc1_before = 0 , enc2_before = 0, enc1_after, enc2_after;
unsigned long enc_dist;
unsigned char thisMD25[16] = {0};
unsigned char motor1, motor2;
int i, j;
const int ledPin = 13;

Servo base;   
Servo joint;
Servo level;
Servo gripper;
             
int baseo=1150,basec=1450,basex=1125;
int jointo=1370,jointc=2105,jointx=1100;
int levelx=1475,levelo=1775;
int grippero=1600,gripperc=2100;
int bapu = 0;   
int jopu = 0;

void setup() {
  Serial.begin(115200);
  Serial.println("enc1_before        enc2_before");
  delay(2000);
  Wire.begin();
  md25_init();
  md25_cmd(32);                      // Reset encoder count!
  
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);
   pinMode(13, OUTPUT);
  joint.attach(9, 875, 2120);
  base.attach(10, 1150, 1465);
  level.attach(11, 1300, 1990);
  gripper.attach(12, 1600, 2070); 
}

void loop() {
  base.writeMicroseconds(basec);
  joint.writeMicroseconds(jointc);
  mv_forw(1000, SLOW);
  obj_reached = 0;
  while (obj_reached == 0) {
    get_encoders();
    if (compare_encoders(forw)) {
      mv_stop();
      obj_reached = 1;
      digitalWrite(ledPin, HIGH);
    }
  }
  
  digitalWrite(13, HIGH);            // tell servo to go to position in variable 'pos' 
  
  base.writeMicroseconds(1130);       //BASE quick move
  level.writeMicroseconds(levelo);
  gripper.writeMicroseconds(grippero);
  
  for(jopu = jointc; jopu > jointo; jopu -= 3)  // goes from 0 degrees to 180 degrees 
  { 
    joint.writeMicroseconds(jopu);
    delay(35);                       // waits 15ms for the servo to reach the position 
    
  }
  digitalWrite(13, LOW);
  base.writeMicroseconds(baseo);
  joint.writeMicroseconds(jointo);
  delay(6000);
  // DONE EXTEND
  
  delay(2000);
  digitalWrite(ledPin,LOW); 
  mv_back(1000, SLOW);
  obj_reached = 0;
  while (obj_reached==0) {
    get_encoders();
    if (compare_encoders(back)) {
      mv_stop();
      obj_reached = 1;
      digitalWrite(ledPin,HIGH);
    }
  }
  
  gripper.writeMicroseconds(grippero);
  base.writeMicroseconds(1550);
  delay(4500);
  
  digitalWrite(13, HIGH);

   for(jopu = jointo; jopu < jointc; jopu += 5)  // goes from 0 degrees to 180 degrees 
  { 
    joint.writeMicroseconds(jopu);
    delay(15);
  }
  base.writeMicroseconds(basec);
  digitalWrite(13,LOW);
  delay(5000);
  
 delay(2000); 
 
 
} 




     
void get_encoders() {
  Wire.beginTransmission(MD25);
  Wire.send(2);
  Wire.endTransmission();
  enc1_before = 0;
  enc2_before = 0;
  i = 2;
  
  Wire.requestFrom(MD25, 8);
  while(Wire.available()) {
    thisMD25[i++] = Wire.receive();
  }
  for (i=2; i<10; i++) {
    if (i < 6) {
      enc1_before <<=8;
      enc1_before  += thisMD25[i];
    } else {
      enc2_before <<= 8;
      enc2_before += thisMD25[i];
    }
  } 
}

//Compare encoder to encoder values corresponding to distance
char compare_encoders(char mode) {
  switch (mode) {
    case forw :
      if (enc1_after >= enc1_before && enc2_after >= enc2_before) {
        return 0;
      } else { 
        return 1;
      }
      break;
    case back :
      if (enc1_after <= enc1_before && enc2_after <= enc2_before) {
        return 0;
      } else {
        return 1;
      }
      break;
    case right :
      if (enc1_after >= enc1_before && enc2_after <= enc2_before) {
        return 0;
      } else return 1;
      break;
    case left :
      if (enc1_after <= enc1_before && enc2_after >= enc2_before) {
        return 0;
      } else return 1;
      break;
  }
}

//Initialize MD25 to MODE0 operation
void md25_init() {
  Wire.beginTransmission(MD25);
  Wire.send(15);
  Wire.send(0);
  Wire.endTransmission();
}

// Send a custom command to the command register in the MD25 
void md25_cmd(unsigned char cmd) {
  Wire.beginTransmission(MD25);
  Wire.send(16);
  Wire.send(cmd);
  Wire.endTransmission();
}

// Move MP4GS forward at a specified speed
// @params: 'distance' in mm, velocity should be SLOW, NORM or FAST
// @vars: changes global vars enc1_*, enc2_*, enc_distance 
void mv_forw (unsigned long distance, unsigned char velocity) {
  enc_dist = 0;
  get_encoders();
  
  enc_dist = distance * 360 / 314;            // One rotation = 314mm     
  enc1_after = enc_dist + enc1_before;  // Add the wanted distance
  enc2_after = enc_dist + enc2_before;  // to each encoder value
  switch (velocity) {
    case SLOW : 
      motor1 = 170;
      break; 
    case NORM :
      motor1 = 212;
      break;
    case FAST :
      motor1 = 255;
      break;
    default :         // Use NORM speed
      motor1 = 212;
      break;
  }  
  Wire.beginTransmission(MD25);
  Wire.send(0);
  motor2 = motor1;
  Wire.send(motor1);
  Wire.send(motor2);
  Wire.endTransmission();
}

// Move MP4GS backward at a specified speed
// @params: 'distance' in mm, velocity should be SLOW, NORM or FAST
// @vars: changes global vars enc1_*, enc2_*, enc_distance 
void mv_back (unsigned long distance, unsigned char velocity) {
  get_encoders();
  
  enc_dist = distance * 360 / 314;            // One rotation = 314mm     
  enc1_after = enc1_before - enc_dist;  // Subtract the wanted distance
  enc2_after = enc2_before - enc_dist;  // to each encoder value
  switch (velocity) {                   // Decide what speed to use!
    case SLOW : 
      motor1 = 86;
      break; 
    case NORM :
      motor1 = 44;
      break;
    case FAST :
      motor1 = 0;
      break;
    default :        // Use NORM speed
      motor1 = 44;
      break;
  }  
  Wire.beginTransmission(MD25);
  Wire.send(0);                         // Always write to first register
  motor2 = motor1;
  Wire.send(motor1);
  Wire.send(motor2);
  Wire.endTransmission();
}

// Turn MP4GS right by specified degrees
// @params: 'degs' are from 0-3600, velocity: SLOW, NORM or FAST
void mv_left (unsigned long degs, unsigned char velocity) {
  get_encoders(); 
  if (degs > 3600) {
    degs = 3600;
  }
 
  enc_dist = degs * 211 / 10000;        // angle * 2.11 = encoder cnts
  
  enc1_after = enc1_before - enc_dist;  // Add the wanted distance
  enc2_after = enc2_before + enc_dist;  // to each encoder value
  switch (velocity) {
    case SLOW :
      motor1 = 128 - 11; 
      motor2 = 128 + 11;
      break; 
    case NORM :
      motor1 = 128 - 42;
      motor2 = 128 + 42;
      break;
    case FAST :
      motor1 = 128 - 84;
      motor2 = 128 + 84;
      break;
    default :               // Use NORM speed
      motor1 = 128 - 42;
      motor2 = 128 + 42;
      break;
  }
  Wire.beginTransmission(MD25);
  Wire.send(0);
  Wire.send(motor1);
  Wire.send(motor2);
  Wire.endTransmission();
}

// Turn MP4GS left by specified degrees
// @params: 'degs' are from 0-360, velocity: SLOW, NORM or FAST
void mv_right (unsigned long degs, unsigned char velocity) {
  get_encoders(); 
  if (degs > 3600) {
    degs = 3600;
  }
  enc_dist = degs * 211 / 1000;         // degs * 211 = encoder cnt
  
  enc1_after = enc1_before + enc_dist;  // Add the wanted distance
  enc2_after = enc2_before - enc_dist;  // to each encoder value
  switch (velocity) {
    case SLOW :
      motor1 = 128 + 11; 
      motor2 = 128 - 11;
      break; 
    case NORM :
      motor1 = 128 + 42;
      motor2 = 128 - 42;
      break;
    case FAST :
      motor1 = 128 + 84;
      motor2 = 128 - 84;
      break;
    default :             // Use NORM speed
      motor1 = 128 + 42;
      motor2 = 128 - 42;
      break;
  }
  Wire.beginTransmission(MD25);
  Wire.send(0);
  Wire.send(motor1);
  Wire.send(motor2);
  Wire.endTransmission();
}

// Stops MP4GS on the spot
void mv_stop() {
  Wire.beginTransmission(MD25);
  Wire.send(0);
  Wire.send(128);
  Wire.send(128);
  Wire.endTransmission();
}
 
