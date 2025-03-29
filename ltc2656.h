#pragma once

//#ifndef LTC2656_H
//#define LTC2656_H
#import <Foundation/Foundation.h>
#import <UIKit/UIKey.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreGraphics/CoreGraphics.h>
//#import "ildaIncludeRandos.h"
//#include <termios.h>
#import "ildaIncludeRandos.h"
#import "ildaNode.h"

#import "ildaFile.h"

#import "LaserClient.h"

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
//GPOI pin for LDAC in wireingPi
static const int LDAC_PIN = 7; // = P4
//spi device 0=CS0, 1=CS1
//static const int SPI_DEV = 0;
//SPI BUS SPEED
//static const unsigned int SPI_SPEED = 50000000;//= 50MHz
//SET BITS PER WORD
//static const unsigned char SPI_BITS_PER_WORD = 8;
//static const char *SPIDEV_1_PATH = "/dev/spidev0.1";
//static const char *SPIDEV_0_PATH = "/dev/spidev0.0";
//
//void setChVal(unsigned char channel, unsigned char valUpper, unsigned char valLower);
//void setChVal_int(unsigned char channel, unsigned int val);
//void setChVal_float(unsigned char channel, float val);
//
//void executeValues();
//void initLtc2656();
//void closeLtc2656();

@class LaserClient;
@interface LaserController : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>


@property (atomic, strong) LaserClient *laserClient;
@property (atomic, strong) CBCentralManager *centralManager;
@property (atomic, strong) CBPeripheral *laserPeripheral;
@property (atomic, strong) CBCharacteristic *writeCharacteristic;
@property (atomic, strong) CBCharacteristic *readCharacteristic;

@property (nonatomic) float scaleX;
@property (nonatomic) float scaleY;
@property (nonatomic) int delayMicroS;

//@property (nonatomic, strong) CBCentralManager *centralManager;
//@property (nonatomic, strong) CBPeripheral *laserPeripheral;
//@property (nonatomic, strong) CBCharacteristic *ildaCharacteristic;
//@property (nonatomic, strong) CBCharacteristic *readCharacteristic;
//
//@property (nonatomic, assign) float scaleX;
//@property (nonatomic, assign) float scaleY;
//@property (nonatomic, assign) int delayMicroS;

+ (instancetype)sharedInstance;

- (void)initLaser;
- (void)closeLaser;

// Methods to send commands
- (void)setChVal:(unsigned char)channel valUpper:(unsigned char)valUpper valLower:(unsigned char)valLower;
- (void)setChVal_int:(unsigned char)channel val:(unsigned int)val;
- (void)setChVal_float:(unsigned char)channel val:(float)val;
- (void)executeValues;
- (void)writeDataToLaser:(NSData *)data;
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central;
- (void)startDiscoveringServices;
// CBPeripheralDelegate method
//+ (instancetype)sharedInstance;
//- (void)initLaser;
//- (void)closeLaser;
//- (void)setChVal:(unsigned char)channel valUpper:(unsigned char)valUpper valLower:(unsigned char)valLower;
//- (void)setChVal_int:(unsigned char)channel val:(unsigned int)val;
//- (void)setChVal_float:(unsigned char)channel val:(float)val;
//- (void)executeValues;
//- (void)writeDataToLaser:(NSData *)data;
- (void)setColourWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
- (void)moveToX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
// Laser commands (for non-SPI control)
//- (void)setColourWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
//- (void)moveToX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;

@end

//@interface LaserController : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
//@property (atomic, strong) LaserClient* laserClient;
//@property (nonatomic, strong) CBCentralManager *centralManager;
//@property (nonatomic, strong) CBPeripheral *laserPeripheral;
//@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;
//@property (nonatomic, strong) CBCharacteristic *readCharacteristic;
//
//@property (nonatomic) float scaleX;
//@property (nonatomic) float scaleY;
//@property (nonatomic) int delayMicroS;
//
//
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
//- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary //*)advertisementData RSSI:(NSNumber *)RSSI;
//- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central;
//- (void)startDiscoveringServices;
//// CBPeripheralDelegate method
//+ (instancetype)sharedInstance;
//- (void)initLaser;
//- (void)closeLaser;
//- (void)setChVal:(unsigned char)channel valUpper:(unsigned char)valUpper valLower:(unsigned char)valLower;
//- (void)setChVal_int:(unsigned char)channel val:(unsigned int)val;
//- (void)setChVal_float:(unsigned char)channel val:(float)val;
//- (void)executeValues;
//- (void)writeDataToLaser:(NSData *)data;
//- (void)setColourWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
//- (void)moveToX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
//
//@end
#ifdef __cplusplus
//}
#endif
//#endif /*LTC2656_H*/
