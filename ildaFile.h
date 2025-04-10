#ifndef ILDAFILE_H
#define ILDAFILE_H
#import <Foundation/Foundation.h>
#import <UIKit/UIKey.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreGraphics/CoreGraphics.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <termios.h>
#import "ildaIncludeRandos.h"
#import "ltc2656.h"
#import "ildaNode.h"
#import "LaserClient.h"

#ifdef __cplusplus
///extern "C" {
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

struct Colour {
    uint8_t red;
    uint8_t green;
    uint8_t blue;
};

typedef struct Colour Colour;
// StatusCode.h

struct StatusCode {
    BOOL blanking;
    BOOL lastEntry;
};

struct colour {
    char red;
    char green;
    char blue;
};

struct statusCode {
    char blanking;
    char lastEntry;
};

struct coordinateData {
    int x;
    int y;
    int z;
    struct statusCode status;
    //color from color table
    char r;
    char g;
    char b;
};



//struct colour *colourTable;

//int HOUSE_WAIT_MICROS = 1000;
//float HOUSE_SIZE = 0.2;
//float ROOF_SIZE = 0.2; //invertete  (-1 is max 1 is min part of the house)

typedef struct StatusCode StatusCode;
#define PARSE_STATE_SEARCHING_HEADER 0
#define PARSE_STATE_PARSING_HEADER 1

#define ILDA_3D_COORD_HEADER_TYPE 0x00
#define ILDA_2D_COORD_HEADER_TYPE 0x01
#define ILDA_COLOUR_PALETTE_HEADER_TYPE 0x02
#define ILDA_3D_COORD_TRUE_COL_HEADER_TYPE 0x04
#define ILDA_2D_COORD_TRUE_COL_HEADER_TYPE 0x05
static const char HEADER_START[] = {'I','L','D','A',0x00,0x00,0x00};

/*
 Execute this function to parse a ILDA-formated file and run its commands
 */
//void executeIldaFileByName(char fileName[], char loop);

// ilda standard color palette (r,g,b)
static const unsigned char ILDA_DEFAULT_COLOUR_PALETTE[256][3]={
    { 0, 0, 0 }, // Black/blanked (fixed)
    { 255, 255, 255 }, // White (fixed)
    { 255, 0, 0 }, // Red (fixed)
    { 255, 255, 0 }, // Yellow (fixed)
    { 0, 255, 0 }, // Green (fixed)
    { 0, 255, 255 }, // Cyan (fixed)
    { 0, 0, 255 }, // Blue (fixed)
    { 255, 0, 255 }, // Magenta (fixed)
    { 255, 128, 128 }, // Light red
    { 255, 140, 128 },
    { 255, 151, 128 },
    { 255, 163, 128 },
    { 255, 174, 128 },
    { 255, 186, 128 },
    { 255, 197, 128 },
    { 255, 209, 128 },
    { 255, 220, 128 },
    { 255, 232, 128 },
    { 255, 243, 128 },
    { 255, 255, 128 }, // Light yellow
    { 243, 255, 128 },
    { 232, 255, 128 },
    { 220, 255, 128 },
    { 209, 255, 128 },
    { 197, 255, 128 },
    { 186, 255, 128 },
    { 174, 255, 128 },
    { 163, 255, 128 },
    { 151, 255, 128 },
    { 140, 255, 128 },
    { 128, 255, 128 }, // Light green
    { 128, 255, 140 },
    { 128, 255, 151 },
    { 128, 255, 163 },
    { 128, 255, 174 },
    { 128, 255, 186 },
    { 128, 255, 197 },
    { 128, 255, 209 },
    { 128, 255, 220 },
    { 128, 255, 232 },
    { 128, 255, 243 },
    { 128, 255, 255 }, // Light cyan
    { 128, 243, 255 },
    { 128, 232, 255 },
    { 128, 220, 255 },
    { 128, 209, 255 },
    { 128, 197, 255 },
    { 128, 186, 255 },
    { 128, 174, 255 },
    { 128, 163, 255 },
    { 128, 151, 255 },
    { 128, 140, 255 },
    { 128, 128, 255 }, // Light blue
    { 140, 128, 255 },
    { 151, 128, 255 },
    { 163, 128, 255 },
    { 174, 128, 255 },
    { 186, 128, 255 },
    { 197, 128, 255 },
    { 209, 128, 255 },
    { 220, 128, 255 },
    { 232, 128, 255 },
    { 243, 128, 255 },
    { 255, 128, 255 }, // Light magenta
    { 255, 128, 243 },
    { 255, 128, 232 },
    { 255, 128, 220 },
    { 255, 128, 209 },
    { 255, 128, 197 },
    { 255, 128, 186 },
    { 255, 128, 174 },
    { 255, 128, 163 },
    { 255, 128, 151 },
    { 255, 128, 140 },
    { 255, 0, 0 }, // Red (cycleable)
    { 255, 23, 0 },
    { 255, 46, 0 },
    { 255, 70, 0 },
    { 255, 93, 0 },
    { 255, 116, 0 },
    { 255, 139, 0 },
    { 255, 162, 0 },
    { 255, 185, 0 },
    { 255, 209, 0 },
    { 255, 232, 0 },
    { 255, 255, 0 }, //Yellow (cycleable)
    { 232, 255, 0 },
    { 209, 255, 0 },
    { 185, 255, 0 },
    { 162, 255, 0 },
    { 139, 255, 0 },
    { 116, 255, 0 },
    { 93, 255, 0 },
    { 70, 255, 0 },
    { 46, 255, 0 },
    { 23, 255, 0 },
    { 0, 255, 0 }, // Green (cycleable)
    { 0, 255, 23 },
    { 0, 255, 46 },
    { 0, 255, 70 },
    { 0, 255, 93 },
    { 0, 255, 116 },
    { 0, 255, 139 },
    { 0, 255, 162 },
    { 0, 255, 185 },
    { 0, 255, 209 },
    { 0, 255, 232 },
    { 0, 255, 255 }, // Cyan (cycleable)
    { 0, 232, 255 },
    { 0, 209, 255 },
    { 0, 185, 255 },
    { 0, 162, 255 },
    { 0, 139, 255 },
    { 0, 116, 255 },
    { 0, 93, 255 },
    { 0, 70, 255 },
    { 0, 46, 255 },
    { 0, 23, 255 },
    { 0, 0, 255 }, // Blue (cycleable)
    { 23, 0, 255 },
    { 46, 0, 255 },
    { 70, 0, 255 },
    { 93, 0, 255 },
    { 116, 0, 255 },
    { 139, 0, 255 },
    { 162, 0, 255 },
    { 185, 0, 255 },
    { 209, 0, 255 },
    { 232, 0, 255 },
    { 255, 0, 255 }, // Magenta (cycleable)
    { 255, 0, 232 },
    { 255, 0, 209 },
    { 255, 0, 185 },
    { 255, 0, 162 },
    { 255, 0, 139 },
    { 255, 0, 116 },
    { 255, 0, 93 },
    { 255, 0, 70 },
    { 255, 0, 46 },
    { 255, 0, 23 },
    { 128, 0, 0 }, // Dark red
    { 128, 12, 0 },
    { 128, 23, 0 },
    { 128, 35, 0 },
    { 128, 47, 0 },
    { 128, 58, 0 },
    { 128, 70, 0 },
    { 128, 81, 0 },
    { 128, 93, 0 },
    { 128, 105, 0 },
    { 128, 116, 0 },
    { 128, 128, 0 }, // Dark yellow
    { 116, 128, 0 },
    { 105, 128, 0 },
    { 93, 128, 0 },
    { 81, 128, 0 },
    { 70, 128, 0 },
    { 58, 128, 0 },
    { 47, 128, 0 },
    { 35, 128, 0 },
    { 23, 128, 0 },
    { 12, 128, 0 },
    { 0, 128, 0 }, // Dark green
    { 0, 128, 12 },
    { 0, 128, 23 },
    { 0, 128, 35 },
    { 0, 128, 47 },
    { 0, 128, 58 },
    { 0, 128, 70 },
    { 0, 128, 81 },
    { 0, 128, 93 },
    { 0, 128, 105 },
    { 0, 128, 116 },
    { 0, 128, 128 }, // Dark cyan
    { 0, 116, 128 },
    { 0, 105, 128 },
    { 0, 93, 128 },
    { 0, 81, 128 },
    { 0, 70, 128 },
    { 0, 58, 128 },
    { 0, 47, 128 },
    { 0, 35, 128 },
    { 0, 23, 128 },
    { 0, 12, 128 },
    { 0, 0, 128 }, // Dark blue
    { 12, 0, 128 },
    { 23, 0, 128 },
    { 35, 0, 128 },
    { 47, 0, 128 },
    { 58, 0, 128 },
    { 70, 0, 128 },
    { 81, 0, 128 },
    { 93, 0, 128 },
    { 105, 0, 128 },
    { 116, 0, 128 },
    { 128, 0, 128 }, // Dark magenta
    { 128, 0, 116 },
    { 128, 0, 105 },
    { 128, 0, 93 },
    { 128, 0, 81 },
    { 128, 0, 70 },
    { 128, 0, 58 },
    { 128, 0, 47 },
    { 128, 0, 35 },
    { 128, 0, 23 },
    { 128, 0, 12 },
    { 255, 192, 192 }, // Very light red
    { 255, 64, 64 }, // Light-medium red
    { 192, 0, 0 }, // Medium-dark red
    { 64, 0, 0 }, // Very dark red
    { 255, 255, 192 }, // Very light yellow
    { 255, 255, 64 }, // Light-medium yellow
    { 192, 192, 0 }, // Medium-dark yellow
    { 64, 64, 0 }, // Very dark yellow
    { 192, 255, 192 }, // Very light green
    { 64, 255, 64 }, // Light-medium green
    { 0, 192, 0 }, // Medium-dark green
    { 0, 64, 0 }, // Very dark green
    { 192, 255, 255 }, // Very light cyan
    { 64, 255, 255 }, // Light-medium cyan
    { 0, 192, 192 }, // Medium-dark cyan
    { 0, 64, 64 }, // Very dark cyan
    { 192, 192, 255 }, // Very light blue
    { 64, 64, 255 }, // Light-medium blue
    { 0, 0, 192 }, // Medium-dark blue
    { 0, 0, 64 }, // Very dark blue
    { 255, 192, 255 }, // Very light magenta
    { 255, 64, 255 }, // Light-medium magenta
    { 192, 0, 192 }, // Medium-dark magenta
    { 64, 0, 64 }, // Very dark magenta
    { 255, 96, 96 }, // Medium skin tone
    { 255, 255, 255 }, // White (cycleable)
    { 245, 245, 245 },
    { 235, 235, 235 },
    { 224, 224, 224 }, // Very light gray (7/8 intensity)
    { 213, 213, 213 },
    { 203, 203, 203 },
    { 192, 192, 192 }, // Light gray (3/4 intensity)
    { 181, 181, 181 },
    { 171, 171, 171 },
    { 160, 160, 160 }, // Medium-light gray (5/8 int.)
    { 149, 149, 149 },
    { 139, 139, 139 },
    { 128, 128, 128 }, // Medium gray (1/2 intensity)
    { 117, 117, 117 },
    { 107, 107, 107 },
    { 96, 96, 96 }, // Medium-dark gray (3/8 int.)
    { 85, 85, 85 },
    { 75, 75, 75 },
    { 64, 64, 64 }, // Dark gray (1/4 intensity)
    { 53, 53, 53 },
    { 43, 43, 43 },
    { 32, 32, 32 }, // Very dark gray (1/8 intensity)
    { 21, 21, 21 },
    { 11, 11, 11 },
    { 0, 0, 0 } // Black
};

extern void term_reset(void);
extern void term_nonblocking(void);
extern void cleanStdin(void);
extern void options(void);

int readTwoByteInt(FILE *fp);
void executeCoordCommand(struct coordinateData *data);
struct statusCode readStatusCode(FILE *fp);
void parse3DCoordTrueColData(FILE *fp, int numberEntries);
void readRGBByColourIndex(FILE *fp, struct coordinateData *data);
void parse3DCoordData(FILE *fp, int numberEntries);
void parse2DCoordData(FILE *fp, int numberEntries);
void parseColourPaletteData(FILE *fp, int numberEntries);
void parse2DCoordTrueColData(FILE *fp, int numberEntries);
void executeIldaFile(FILE *fp, char loop);
//void executeIldaFileByName(char fileName[], char loop);
void executeIldaFileByName(const char * fileName, char loop);


@interface CoordinateData : NSObject

@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, assign) int z;
@property (nonatomic, assign) StatusCode status;
@property (nonatomic, assign) Colour colour;
+ (instancetype)sharedInstance;
- (instancetype)initWithX:(int)x y:(int)y z:(int)z status:(StatusCode)status colour:(Colour)colour;
- (void)executeCommand:(struct coordinateData *)data;

@end
@interface IldaFileParser : NSObject

@property (nonatomic, strong) NSArray<CoordinateData *> *coordinates;
+ (instancetype)sharedInstance;
- (instancetype)initWithFileURL:(NSURL *)fileURL;
- (BOOL)parseFileWithError:(NSError **)error;

@end
// IldaFileParser.m
#ifdef __cplusplus
//}
#endif
#endif /*ILDAFILE_H*/
