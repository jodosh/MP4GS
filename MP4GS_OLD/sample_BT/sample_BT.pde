/*
  ASCII table
*/

// first visible ASCIIcharacter '!' is number 33:
// int thisByte = 33; 
//unsigned char file[20000]={0x75};
unsigned long baudRate = 115200;
int inByte;

void setup() 
{ 
  delay(1000);
  pinMode(13, OUTPUT);
  Serial.begin(baudRate);
  Serial3.begin(baudRate); 
  Serial3.print("$$$");
  Serial.print("$$$");
  delay(500);
  while (Serial3.available()) {
    inByte = Serial3.read();
    Serial.print(inByte, BYTE);
  }
  while (true) continue;
  Serial3.println("su,11");
  while (Serial3.available()) {
    inByte = Serial3.read();
    Serial.print(inByte, BYTE);
  }
  Serial3.println("---");
  while (Serial3.available()) {
    inByte = Serial3.read();
    Serial.print(inByte, BYTE);
  }
  Serial.println();
  Serial3.end();
  Serial3.begin(baudRate);
  pinMode(13, OUTPUT);
  establishContact();
} 

void loop() 
{ 
  unsigned long time;
  
  time= print20kBytes();
  printInfo(time);
  delay(500);
  establishContact(); 
/*
  Serial3.println("$$$");
  Serial3.println("su,57");
  Serial3.println("---");
  Serial3.flush();
  Serial.end();
  Serial3.end();
  baudRate = 57600;
  Serial.begin(baudRate);
  Serial3.begin(baudRate);
  digitalWrite(13, HIGH);
  establishContact();
  digitalWrite(13, LOW);
  time = print20kBytes();
  printInfo(time);
*/   
//  digitalWrite(13, HIGH);
  while (true) continue; 
} 

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('A', BYTE);   // send a capital A
    delay(300);
  }
}

unsigned long print20kBytes() {
  unsigned int i;
  unsigned long time1;
  
  time1 = micros();
  for (i = 0; i<20000; i++) {
    Serial3.write(0x75);
  }
  return (micros() - time1);
}

void printInfo(unsigned long time) {
  Serial.println();
  Serial.print("Time to send at ");
  Serial.print(baudRate, DEC);
  Serial.print("bps is (us): ");
  Serial.println(time, DEC);
  delay(100);
  Serial.print("Time required in ms: ");
  Serial.println((int)(time /= 1000L));
}

  

