#include <Servo.h> 
 
Servo base;   
Servo joint;
Servo level;
Servo gripper;
             
int baseo=1150,basec=1450,basex=1125;
int jointo=1380,jointc=2105,jointx=1100;
int levelx=1475,levelo=1775;
int grippero=1600,gripperc=2100;
int bapu = 0;   
int jopu = 0;

 
void setup() 
{ 
  pinMode(13, OUTPUT);
  joint.attach(9, 875, 2120);
  base.attach(10, 1150, 1465);
  level.attach(11, 1300, 1990);
  gripper.attach(12, 1600, 2070); 
}

void loop(){
  
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
  delay(8000);
  // DONE EXTEND
  
  base.writeMicroseconds(basex);
  
  for(jopu =jointo; jopu > jointx; jopu -= 3)  // goes from 0 degrees to 180 degrees 
  { 
    joint.writeMicroseconds(jopu);
    delay(15);
  }
  level.writeMicroseconds(levelx);
  delay(2250);
  gripper.writeMicroseconds(gripperc);
  delay(3000);
  //DONE EXTRA
  
 
  delay(250);
  level.writeMicroseconds(levelo);
  
  base.writeMicroseconds(1200);           //BASE quick move
  delay(2500);
  base.writeMicroseconds(baseo);
  for(jopu = jointx; jopu < jointo; jopu += 3)  // goes from 0 degrees to 180 degrees 
  { 
    joint.writeMicroseconds(jopu);
    delay(15);
  }
  delay(2000);
  
  //DONE RETRACT
  gripper.writeMicroseconds(grippero);
  base.writeMicroseconds(basec);
  delay(10000);
  
  digitalWrite(13, HIGH);

   for(jopu = jointo; jopu < jointc; jopu += 5)  // goes from 0 degrees to 180 degrees 
  { 
    joint.writeMicroseconds(jopu);
    delay(15);
  }
  digitalWrite(13,LOW);
  delay(10000);
}

