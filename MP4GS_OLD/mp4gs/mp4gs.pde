#include <Wire.h>

#define MD25 0x58
#define FAST 0x01
#define NORM 0x02
#define SLOW 0x03

// Global variables
   // I2C communication vars
char obj_found, obj_reached;
long enc1_before = 0 , enc2_before = 0;
long enc1_after, enc2_after;
unsigned long enc_dist;
unsigned char thisMD25[16]={0}; 
int i;
   // PING sensor vars
unsigned long PING_distance; 
const char pingPin = 7;        // PING connected to pin 7
  // Arm servo variables
const char basePin    = 10;
const char jointPin   = 11;
const char levelPin   = 12;
const char gripperPin = 13;

// Read encoder values from MD25 motor driver
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
char compare_encoders() {
  if (enc1_before == enc1_after || enc2_before == enc2_after) {
    mv_stop();
    return 1;
  }
  return 0;
}

//Initialize MD25 to MODE2 operation
void md25_init() {
  Wire.beginTransmission(MD25);
  Wire.send(15);
  Wire.send(2);
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
void mv_forw (unsigned int distance, unsigned char velocity) {
  get_encoders();
  
  enc_dist = distance * 360;            // One rotation = 314mm     
  enc_dist /= 314;
  enc1_after = enc_dist + enc1_before;  // Add the wanted distance
  enc2_after = enc_dist + enc2_before;  // to each encoder value
  
  Wire.beginTransmission(MD25);
  Wire.send(0);
  switch (velocity) {
    case SLOW : 
      Wire.send(170);
      break; 
    case NORM :
      Wire.send(212);
      break;
    case FAST :
      Wire.send(255);
      break;
    default : 
      Wire.send (212);
      break;
  }
  Wire.send(128);
  Wire.endTransmission();
}

// Move MP4GS backward at a specified speed
// @params: 'distance' in mm, velocity should be SLOW, NORM or FAST
// @vars: changes global vars enc1_*, enc2_*, enc_distance 
void mv_back (unsigned int distance, unsigned char velocity) {
  get_encoders();
  
  enc_dist = distance * 360;            // One rotation = 314mm     
  enc_dist /= 314;
  enc1_after = enc1_before - enc_dist;  // Subtract the wanted distance
  enc2_after = enc2_before - enc_dist;  // to each encoder value
  
  Wire.beginTransmission(MD25);
  Wire.send(0);                         // Always write to first register
  switch (velocity) {                   // Decide what speed to use!
    case SLOW : 
      Wire.send(170);
      break; 
    case NORM :
      Wire.send(212);
      break;
    case FAST :
      Wire.send(255);
      break;
    default : 
      Wire.send (212);                  // If something else, use NORM speed
      break;
  }
  Wire.send(128);                       // Turn register is 128 = 0 turn
  Wire.endTransmission();
}

// Turn MP4GS right by specified degrees
// @params: 'degs' are from 0-360, velocity: SLOW, NORM or FAST
void right_turn (unsigned int degs, unsigned char velocity) {
  get_encoders(); 
  
  enc_dist = degs;                      // One rotation = 360 degs
  
  enc1_after = enc_dist + enc1_before;  // Add the wanted distance
  enc2_after = enc_dist - enc2_before;  // to each encoder value
  
  Wire.beginTransmission(MD25);
  Wire.send(0);
  switch (velocity) {
    case SLOW : 
      Wire.send(86);
      break; 
    case NORM :
      Wire.send(44);
      break;
    case FAST :
      Wire.send(0);
      break;
    default : 
      Wire.send (44);
      break;
  }
  Wire.send(192);
  Wire.endTransmission();
}

// Turn MP4GS left by specified degrees
// @params: 'degs' are from 0-360, velocity: SLOW, NORM or FAST
void right_turn (unsigned int degs, unsigned char velocity) {
  get_encoders(); 
  
  enc_dist = degs;                      // One rotation = 360 degs
  
  enc1_after = enc_dist - enc1_before;  // Add the wanted distance
  enc2_after = enc_dist + enc2_before;  // to each encoder value
  
  Wire.beginTransmission(MD25);
  Wire.send(0);
  switch (velocity) {
    case SLOW : 
      Wire.send(170);
      break; 
    case NORM :
      Wire.send(212);
      break;
    case FAST :
      Wire.send(255);
      break;
    default : 
      Wire.send (212);                 // If default go to NORM speed
      break;
  }
  Wire.send(192);                      // Turn register is constant
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

unsigned long get_PING() {
  long duration;
  
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
  duration = pulseIn(pingPin, HIGH, 5000);
  
  // convert the time into a distance
  return duration / 29 / 2;
}
  
void setup() {
  Wire.begin();  //Start Wire library as I2C-bus master
  md25_init();
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);
  Serial.begin(115200);
  // md25_cmd(xxx);   // In case you wanna init md25 to something else
}

void loop() {
  
  right_turn (360, SLOW);
  while (obj_found == 0) {
    PING_distance = get_PING();  //Distance in centimeters
    if (PING_distance) {
      obj_found = 1;
      digitalWrite(ledPin, HIGH);
    } 
    get_encoders();
    if (compare_encoders()) {
      right_turn (360, SLOW);
    }
  }
  mv_stop();
  md25_cmd(32);    // Reset encoder values back to 0
  delay(50);
  digitalWrite(ledPin, LOW);
  
  mv_forw(PING_distance, NORM);
  obj_reached = 0;
  while (obj_reached == 0) {
    PING_distance = get_PING(); 
    if (PING_distance > 0 && PING_distance < 20) {
      obj_reached = 1;
    }
    get_encoders();
    if (compare_encoders()) {
      mv_forw(PING_distance, SLOW);
    }
  }
  mv_stop();
  md25_cmd(32);    // Reset encoder values back to 0
    
}
