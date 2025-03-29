#pragma once
//#ifndef ILDANODE_H
//#define ILDANODE_H
#import <Foundation/Foundation.h>
#import <UIKit/UIKey.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreGraphics/CoreGraphics.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <math.h>
//#include <wiringPi.h>
#include <string.h>
//#include <termios.h> 
#import "LaserClient.h"
#import "ildaIncludeRandos.h"
//#import "ltc2656.h"
//#import "ildaNode.h"
#import "ltc2656.h"
#import "ildaFile.h"
//#import "LaserClient.h"



//#include "ltc2656.h"
//#include "ildaFile.h"
//#include "ildaNode.h"
#ifdef __cplusplus
//extern "C" {
#endif

//extern float ILDA_AxisMax;
//extern struct colour *colourTable;
//extern struct termios stdin_orig;  // Structure to save parameters
//extern int HOUSE_WAIT_MICROS;
//extern float HOUSE_SIZE;
//extern float ROOF_SIZE; //invertete  (-1 is max 1 is min part of the house)
////#define HOUSE_SIZE 1000
////#define HOUSE_WAIT_MICROS 10000
////#define ROOF_SIZE 500
//extern int distPerS;
//
//extern float ILDA_Colour_Max;


//chanal number for x movement
static const unsigned char CH_X  = 0x03;
//chanal number for y movement
static const unsigned char CH_Y  = 0x02;
//chanal number for color red
static const unsigned char CH_R  = 0x01;
//chanal number for color green
static const unsigned char CH_G  = 0x00;
//chanal number for color blue
static const unsigned char CH_B  = 0x04;
//chanal number for custom color 1
static const unsigned char CH_C1 = 0x05;
//time for one move in µs
static const int MOVE_TIME_MICROS = 150;


void initILDA(void);
void endILDA(void);
void moveTo(float x, float y);
void moveToTimed(float x, float y, int micros);
void moveToSpeedLimit(float x, float y, int distPerS);
void setColour(float red, float green, float blue);
void cicle(float r, float posX, float posY);
void rotataitingCicle(void);
void hoseOfNicolaus(void);
int selectWhatToDo(void);
void term_reset(void);
void term_nonblocking(void);
void cleanStdin(void);
void options(void);
@class LaserController;
@interface LaserProgram : NSObject
@property (atomic, strong) LaserController *laserController;
@property (nonatomic) float lastX;
@property (nonatomic) float lastY;
@property (nonatomic) float scaleX;
@property (nonatomic) float scaleY;
@property (nonatomic) int delayMicroS;
@property (nonatomic) float lastRed;
@property (nonatomic) float lastGreen;
@property (nonatomic) float lastBlue;
+ (instancetype)sharedInstance;
- (void)runProgram;
- (instancetype)init;
- (void)initILDA;
- (void)endILDA;
- (void)moveTo:(float)x y:(float)y;
- (void)moveToTimed:(float)x y:(float)y micros:(int)micros;
- (void)moveToSpeedLimit:(float)x y:(float)y distPerS:(int)distPerS;
- (void)setColour:(float)red green:(float)green blue:(float)blue;
- (void)cicle:(float)r posX:(float)posX posY:(float)posY;
- (void)rotatingCicle;
- (void)houseOfNicolaus;
- (int)selectWhatToDo;
- (void)options;

@end

/*
 run this before any opration
 */
//void initILDA();
///*
//Set the positon in float values.
//The value 0 is the center.
//1 the max to the right on x and the max to top for y.
//-1 max left on x and max down on y.
//executing takes MOVE_TIME_MICROS µs
//*/
//void moveTo(float x, float y);
///*
//micros this moveTo should take
//seperates the singel movement in multiple moveTo which take MOVE_TIME_MICROS µs
//*/
//void moveToTimed(float x, float y, int micros);
///*
//calculates the move-time based on the distance and distPerS
//distPerS is the distence per second (pps * 4)
//*/
//void moveToSpeedLimit(float x, float y, int distPerS);
///*
//writes the values but not executes them.
//0 is off and 1 full on.
//with the "moveTo" functions the colour is also executed.
//*/
//void setColour(float red, float green, float blue);
//
//void term_nonblocking();
//void term_reset();

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif /*M_PI*/
#ifdef __cplusplus
//}
#endif
//#endif /*ILDANODE_H*/
