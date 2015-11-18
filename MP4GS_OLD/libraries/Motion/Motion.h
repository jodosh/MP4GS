/*

  Motion.h - Library for MP4GS platform movement

  Author: Alvaro Aguilar
  Date: Feb. 21, 2011

*/

#ifndef Motion_h
#define Motion_h

#include "WProgram.h"
#include <Wire.h>

#define MD25  0x58
#define FAST  0x01
#define NORM  0x02
#define SLOW  0x03

#define forw  0x01
#define back  0x02
#define right 0x03
#define left  0x04


class Motion
{
  public:
    Motion();
    void get_encoders();
    long enc2distance();
    bool compare_encoders(char mode);
    void md25_init(unsigned char mode);
    void md25_cmd(unsigned char cmd);
    void mv_forw(unsigned long distance, unsigned char velocity);
    void mv_back(unsigned long distance, unsigned char velocity);
    void mv_left(unsigned long degs);
    void mv_right(unsigned long degs);
//		void mv_lineFollow();
    void mv_stop();
    char check_motor(char motor);
//////////////////////////////////// Variables for robot motion //////////////////////////
    unsigned char motor1, motor2;
    long enc1_before, enc2_before;
   
  private:
    long enc1_after, enc2_after;
    unsigned long enc_dist;
    int i;
    unsigned char thisMD25[16];
};

#endif