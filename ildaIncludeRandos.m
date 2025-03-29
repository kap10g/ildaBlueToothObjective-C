//
#include "ildaIncludeRandos.h"

float ILDA_AxisMax = 32768.0;
struct colour *colourTable;
struct termios stdin_orig;  // Structure to save parameters
int HOUSE_WAIT_MICROS = 1000;
float HOUSE_SIZE = 0.2;
float ROOF_SIZE = 0.2; //invertete  (-1 is max 1 is min part of the house)
//#define HOUSE_SIZE 1000
//#define HOUSE_WAIT_MICROS 10000
//#define ROOF_SIZE 500
int distPerS = 100000;

float ILDA_Colour_Max = 255.0;//  ildaIncludeRandos.c
//  Exquisite Corpus_beforeAddAUv3
//
//  Created by George Rosar on 3/26/25.
//

