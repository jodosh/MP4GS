/*
  MD25_Mp4GS_Test.ino - Example for the MD25 on the MP4GS platform library.
  Created by Johnny Haddock, October 27, 2015.
*/

#include <Wire.h>
#include <MD25.h>
#include <I2C.h>

MD25 controller;

void setup() {
  controller = MD25(0xB0 >> 1);
  Wire.begin();
}

void loop() {
  controller.setMode(0);
  controller.setMotor1Speed(164); //half speed
  controller.setMotor2Speed(128); //stop
  delay(1000);
}