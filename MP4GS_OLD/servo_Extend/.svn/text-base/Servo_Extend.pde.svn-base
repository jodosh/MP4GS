#include <Servo.h> 
 
Servo base;   
Servo joint;
Servo level;
Servo gripper;
             
int baseo=1150,basec=1450,basex=1125;
int jointo=1385,jointc=2105,jointx=1100;
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
  
  move_blink();
  move_blink();
  arm_unfold();
  move_blink();
  arm_extend();
  move_blink();
  arm_retract();
  move_blink();
  arm_fold():
  move_blink();
  move_blink();
 
  // DONE EXTEND
  
  
  //DONE EXTRA
  
 
  
  //DONE RETRACT
  
}

//************************FUNCTIONS****************************

//***Function to unfold the arm from the folded position
void arm_unfold (){
  delay(250);
   base.writeMicroseconds(1130);       //BASE quick move to unfold
  level.writeMicroseconds(levelo);     //Set level servo level for defualt position
  gripper.writeMicroseconds(grippero); //open gripper
  
  for(jopu = jointc; jopu > jointo; jopu -= 3)  //Unfolds joint gradually  
  { 
    joint.writeMicroseconds(jopu);
    delay(35);                       
    
  }
  base.writeMicroseconds(baseo); //Final unfolded position to stop Base from fast move
  joint.writeMicroseconds(jointo); //Resend joint position to try and reduce jittering
  delay(4000); //Wait 4 seconds for arm to steady
}

//*************Function for extra extension when arm is already unfolded
void arm_extend(){
  delay(250);
   base.writeMicroseconds(basex); //Base servo to extended position
  
  for(jopu =jointo; jopu > jointx; jopu -= 3)  //Gradually extend joint servo 
  { 
    joint.writeMicroseconds(jopu);
    delay(15);
  }
  
  level.writeMicroseconds(levelx); //Set Level for extended position
  delay(5000); //Wait for arm to settle
}

//*************Function to retract arm from extra extension position back to default unfolded position
void arm_retract(){
  delay(250);
  level.writeMicroseconds(levelo); //Set Level for default unfolded position
  
  base.writeMicroseconds(1200);   //BASE quick move
  delay(2500);
  base.writeMicroseconds(baseo);  //Stop Base move
 
  for(jopu = jointx; jopu < jointo; jopu += 3)  //Gradually move joint 
  { 
    joint.writeMicroseconds(jopu);
    delay(15);
  }
 
  delay(2000); //Wait for arm to settle
}

//*************Function to fold arm from default unfolded position
void arm_fold(){
  delay(250);
  gripper.writeMicroseconds(grippero); //Open Gripper
  base.writeMicroseconds(1550); //Base servo position to move faster
  delay(4500); //4.5 Second Delay to allow base to move before joint does
  
   for(jopu = jointo; jopu < jointc; jopu += 5)  //Moves the joint servo gradually to folded position 
  { 
    joint.writeMicroseconds(jopu);
    delay(15);
  }

  base.writeMicroseconds(basec); //Real folded position for Base to stop it in proper place from the fast move
  delay(3500); //wait 3.5 seconds to let arm settle
}

void move_grip(unsigned long pulse){
  gripper.writeMicroseconds(pulse)
}

void move_blink(){
  delay(250);
  digitalWrite(13, HIGH);
  delay(250):
  digitalWrite(13, LOW);
  delay(250):
  digitalWrite(13, HIGH);
  delay(250);
  digitalWrite(13, LOW):
  delay(100);
}
  

