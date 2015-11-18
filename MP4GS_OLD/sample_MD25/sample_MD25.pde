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
int i, j;
const int ledPin = 13;

void setup() {
  Serial.begin(115200);
  Wire.begin();
  md25_init();
  md25_cmd(32);                      // Reset encoder count!
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);
  right_turn(360, NORM);
  obj_reached = 0;
  while (obj_reached == 0) {
    get_encoders();
    if (compare_encoders(right)) {
      mv_stop();
      obj_reached = 1;
      digitalWrite(ledPin, HIGH);
    }
  }    
  Serial.print("enc1_after: 0x");
  Serial.print(enc1_after, HEX);
  Serial.println();
  Serial.print("enc2_after: 0x");
  Serial.print(enc2_after, HEX);
  Serial.println();
  digitalWrite(ledPin,LOW);
}

void loop() {} 
     
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
void mv_forw (unsigned long distance, unsigned char velocity) {
  enc_dist = 0;
  get_encoders();
  
  enc_dist = distance * 360 / 314;            // One rotation = 314mm     
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
void mv_back (unsigned long distance, unsigned char velocity) {
  get_encoders();
  
  enc_dist = distance * 360 / 314;            // One rotation = 314mm     
  enc1_after = enc1_before - enc_dist;  // Subtract the wanted distance
  enc2_after = enc2_before - enc_dist;  // to each encoder value
  
  Wire.beginTransmission(MD25);
  Wire.send(0);                         // Always write to first register
  switch (velocity) {                   // Decide what speed to use!
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
      Wire.send (44);                  // If something else, use NORM speed
      break;
  }
  Wire.send(128);                       // Turn register is 128 = 0 turn
  Wire.endTransmission();
}

// Turn MP4GS right by specified degrees
// @params: 'degs' are from 0-360, velocity: SLOW, NORM or FAST
void left_turn (unsigned long degs, unsigned char velocity) {
  get_encoders(); 
  
  enc_dist = degs;                      // One rotation = 360 degs
  
  enc1_after = enc1_before - enc_dist;  // Add the wanted distance
  enc2_after = enc2_before + enc_dist;  // to each encoder value
  
  Wire.beginTransmission(MD25);
  Wire.send(0);
  Wire.send(128);
  switch (velocity) {
    case SLOW : 
      Wire.send(110);
      break; 
    case NORM :
      Wire.send(84);
      break;
    case FAST :
      Wire.send(42);
      break;
    default : 
      Wire.send (84);
      break;
  }
  Wire.endTransmission();
}

// Turn MP4GS left by specified degrees
// @params: 'degs' are from 0-360, velocity: SLOW, NORM or FAST
void right_turn (unsigned long degs, unsigned char velocity) {
  get_encoders(); 
  
  enc_dist = degs;                      // One rotation = 360 degs
  
  enc1_after = enc1_before + enc_dist;  // Add the wanted distance
  enc2_after = enc2_before - enc_dist;  // to each encoder value
  
  Wire.beginTransmission(MD25);
  Wire.send(0);
  Wire.send(126);
  switch (velocity) {
    case SLOW : 
      Wire.send(110);
      break; 
    case NORM :
      Wire.send(84);
      break;
    case FAST :
      Wire.send(42);
      break;
    default : 
      Wire.send (84);                 // If default go to NORM speed
      break;
  }
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
 
