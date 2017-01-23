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
  controller.setAccelerationRate(3);
}

void loop() {
  controller.setMode(0); //each motor register is litteral speed in range 0 (full reverse) 128 (stop) 255 (full forward)
  controller.setMotor1Speed(191); //left motor half speed
  controller.setMotor2Speed(128); //right motor stop
  delay(1000); //spin for 1 second
  controller.setMotor1Speed(128); //left motor stop
  controller.setMotor2Speed(128); //right motor stop
  delay(500); //stop for 0.5 second
}