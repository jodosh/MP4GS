/*  Arm.cpp - Library for PING object detection sensors  Author: Alvaro Aguilar  Date: Feb. 21, 2011*/#include "Arm.h"#include "WProgram.h"#include "/home/alvaro/Documents/arduino-0022/libraries/Servo/Servo.h"//#include <pins_arduino.h>			uint8_t _jointPin   = 9;		uint8_t _basePin    = 10;		uint8_t _levelPin   = 11;		uint8_t _gripperPin = 12;		uint8_t _ledPin     = 13;		uint8_t _servoPwr1  = 22;		uint8_t _servoPwr2  = 24;		int jointo = 1385, jointc = 2105, jointx = 1100;		int levelx = 1475, levelo = 1775;		int baseo = 1150, basec = 1450, basex = 1125;		int gripperc = 1600, grippero = 2100;		int bapu = 0, jopu = 0;				Servo base;   		Servo joint;		Servo level;		Servo gripper;Arm::Arm(){  joint.attach(_jointPin, 875, 2120);  base.attach(_basePin, 1150, 1465);  level.attach(_levelPin, 1300, 1990);  gripper.attach(_gripperPin, 1600, 2070);   pinMode(_servoPwr1, OUTPUT);  pinMode(_servoPwr2, OUTPUT);  digitalWrite(_servoPwr1, HIGH);  digitalWrite(_servoPwr2, HIGH);}//***Function to unfold the arm from the folded positionvoid Arm::arm_unfold(){	base.writeMicroseconds(1130);       				//BASE quick move to unfold  level.writeMicroseconds(levelo);     				//Set level servo level for defualt position  gripper.writeMicroseconds(grippero); 				//open gripper    for(jopu = jointc; jopu > jointo; jopu -= 3)  //Unfolds joint gradually    {     joint.writeMicroseconds(jopu);    delay(35);                             }  base.writeMicroseconds(baseo); 						//Final unfolded position to stop Base from fast move  joint.writeMicroseconds(jointo); 					//Resend joint position to try and reduce jittering  delay(4000); 															//Wait 4 seconds for arm to steady }//*************Function for extra extension when arm is already unfoldedvoid Arm::arm_extend(){	base.writeMicroseconds(basex); 						//Base servo to extended position    for(jopu =jointo; jopu > jointx; jopu -= 3)  //Gradually extend joint servo   {     joint.writeMicroseconds(jopu);    delay(15);  }    level.writeMicroseconds(levelx); 					//Set Level for extended position  delay(5000); 															//Wait for arm to settle	}//*************Function to retract arm from extra extension position back to default unfolded positionvoid Arm::arm_retract(){  level.writeMicroseconds(levelo); 				//Set Level for default unfolded position    base.writeMicroseconds(1200);   				//BASE quick move  delay(2500);  base.writeMicroseconds(baseo);  				//Stop Base move   for(jopu = jointx; jopu < jointo; jopu += 3)  //Gradually move joint   {     joint.writeMicroseconds(jopu);    delay(15);  }   delay(2000); 												//Wait for arm to settle}//*************Function to fold arm from default unfolded positionvoid Arm::arm_fold(){  delay(250);  gripper.writeMicroseconds(grippero); 			//Open Gripper  base.writeMicroseconds(1550); 						//Base servo position to move faster  delay(4500); 															//4.5 Second Delay to allow base to move before joint does     for(jopu = jointo; jopu < jointc; jopu += 5)  //Moves the joint servo gradually to folded position   {     joint.writeMicroseconds(jopu);    delay(15);  }  base.writeMicroseconds(basec); 						//Real folded position for Base to stop it in proper place from the fast move  delay(3500); 															//wait 3.5 seconds to let arm settle}//*************Function to control the grippervoid move_grip(unsigned int pulse){  gripper.writeMicroseconds(pulse);	delay(100);}