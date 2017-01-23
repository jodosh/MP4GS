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
  controller.enableSpeedRegulation();
  controller.setMode(3); //motor1 is litteral speed in range -128 (full reverse) 0 (stop) 127 (full forward)
						 //motor2 is the turn register, if going forward a positive number will turn left
}

void loop() {
  controller.setMotor1Speed(63); //forward at half speed
  controller.setMotor2Speed(0); //no turn
  delay(1000); //drive for 1 second
  //controller.setMotor1Speed(128); //left motor stop
  controller.setMotor2Speed(10); //left turn
  delay(1000);
  controller.setMotor1Speed(0); //stop
  controller.setMotor2Speed(0); //stop
}