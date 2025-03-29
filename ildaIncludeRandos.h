//
//  ildaIncludeRandos.h
//  Exquisite Corpus_beforeAddAUv3
//
//  Created by George Rosar on 3/26/25.
//
//#pragma once
#ifndef _ilda_inclue_Randos_h
#define _ilda_inclue_Randos_h 1
#ifdef __cplusplus
//extern "C" {
#endif

#include <termios.h>

//float ILDA_AxisMax = 32768.0;
//struct colour *colourTable;
//struct termios stdin_orig;  // Structure to save parameters
//int HOUSE_WAIT_MICROS = 1000;
//float HOUSE_SIZE = 0.2;
//float ROOF_SIZE = 0.2; //invertete  (-1 is max 1 is min part of the house)
////#define HOUSE_SIZE 1000
////#define HOUSE_WAIT_MICROS 10000
////#define ROOF_SIZE 500
//int distPerS = 100000;
//
//float ILDA_Colour_Max = 255.0;
extern float ILDA_AxisMax;
extern struct colour *colourTable;
extern struct termios stdin_orig;  // Structure to save parameters
extern int HOUSE_WAIT_MICROS;
extern float HOUSE_SIZE;
extern float ROOF_SIZE; //invertete  (-1 is max 1 is min part of the house)
//#define HOUSE_SIZE 1000
//#define HOUSE_WAIT_MICROS 10000
//#define ROOF_SIZE 500
extern int distPerS;

extern float ILDA_Colour_Max;
#ifdef __cplusplus
//}
#endif
#endif


