#include <Ping.h>

Ping basePING(22);        // one PING sensor at PIN 22
Ping armPING(24);         // second PING sensor at PIN 24
unsigned long obj_dist;   // Variable to hold distance from PING

void setup() {
  Serial.begin(115200);
}

void loop() {
  // get_PING(unit) --> could be 'mm', or 'in' for mm, or inches 
  obj_dist = basePING.get_PING(mm);
  Serial.print("Base PING measures: ");
  Serial.print(obj_dist, DEC);
  Serial.println(" mm");
  
  obj_dist = armPING.get_PING(in);
  Serial.print("Arm PING measures: ");
  Serial.print(obj_dist, DEC);
  Serial.println(" in");
  delay (500);  
}
